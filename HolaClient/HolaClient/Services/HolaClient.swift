//
//  BrowserService.swift
//  HolaClient
//
//  Created by Phil Shen on 10/22/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation
import os.log

class HolaClient: NSObject {
    
    typealias Callback = (String?, Error?) -> Void
    
    static let shared = HolaClient()
    
    private var service: NetService?
    private var hasBegunSearching = false
    private lazy var callbacks = [UUID:Callback]()
    private lazy var callbackThread = DispatchQueue.global(qos: .background)
    
    private let browser: ServiceBrowser
    
    private init(browser: ServiceBrowser = ServiceBrowser()) {
        self.browser = browser
        super.init()
        self.browser.delegate = self
    }
    
}

// MARK: - API
extension HolaClient {
    
    /**
     Searches for Hola services. This must execute on the main thread, making it very easy to lead to deadlocks.
     */
    func beginSearching() {
        if hasBegunSearching { return }
        hasBegunSearching = true
        browser.searchForServices(ofType: "_https._tcp", inDomain: "local.")
    }
    
    /**
     Gets the URL of the Hola server. Client.shared.beginSearching() must be called before this. If no service has been found, or the service's URL has not been resolved, the completion handler will be queued wait for it to complete.
     
     - Parameter timeout: Timeout (in seconds)
     - Parameter completion: Will be called once finished
     */
    func getURL(timeout: Double, completion: @escaping Callback) {
        guard hasBegunSearching else {
            fatalError("beginSearching() must be called before a host can be resolved")
        }
        
        if let url = service?.urlString {
            completion(url, nil)
        } else {
            os_log("Service has not been resolved. Waiting.")
            enqueueCallback(completion, timeout: timeout)
        }
    }
    
}

// MARK: - Private Utility Methods
private extension HolaClient {
    
    func isHolaService(_ service: NetService) -> Bool {
        return service.name.hasPrefix("hola_")
    }
    
    func invokeCallbacks(url: String? = nil, error: HolaClientError? = nil) {
        guard url != nil || error != nil else {
            assertionFailure("invokeCallbacks() must be passed a URL or error")
            return
        }
        
        callbackThread.sync {
            callbacks.values.forEach { $0(url, error) }
            callbacks.removeAll()
        }
    }
    
    func enqueueCallback(_ callback: @escaping Callback, timeout: Double) {
        let id = UUID()
        beginTimeoutTimer(callbackID: id, timeout: timeout)
        
        callbackThread.sync {
            callbacks[id] = callback
        }
    }
    
    func dequeueCallback(id: UUID) {
        callbackThread.sync {
            if let callback = callbacks.removeValue(forKey: id) {
                callback(nil, HolaClientError.getURLTimeout)
            }
        }
    }
    
    func beginTimeoutTimer(callbackID: UUID, timeout: Double) {
        let queue = DispatchQueue.global(qos: .background)
        let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        let timeoutMsInt = Int(timeout * 100)
        timer.schedule(deadline: .now() + .milliseconds(timeoutMsInt))
        timer.setEventHandler { [weak self] in
            self?.dequeueCallback(id: callbackID)
        }
        timer.resume()
    }
    
}

// MARK: - NetServiceBrowserDelegate
extension HolaClient: ServiceBrowserDelegate {
    
    func serviceBrowser(_ browser: ServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        invokeCallbacks(error: .failedToSearch(errorDict: errorDict))
    }
    
    /**
     Connect to the first Hola service found. If none are found, return an error to the callbacks
     */
    func serviceBrowser(_ browser: ServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if service === self.service {
            self.service = nil
        }
    }
    
    func serviceBrowser(_ browser: ServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if let currentService = self.service {
            os_log("Already connected to service \"%@\"; ignoring \"%@\"", currentService.name, service.name)
        } else {
            if isHolaService(service) {
                os_log("Found Hola service \"%@\"", service.name)
                self.service = service
                service.delegate = self
                service.resolve(withTimeout: 10)
                browser.stop()
            } else if !moreComing {
                invokeCallbacks(error: .noHolaServicesFound)
            }
        }
    }
    
}

// MARK: - NetServiceDelegate
extension HolaClient: NetServiceDelegate {
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String:NSNumber]) {
        invokeCallbacks(error: .failedToResolve(errorDict: errorDict))
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let url = sender.urlString else {
            fatalError("Resolved address, but unable to find the service")
        }
        
        invokeCallbacks(url: url)
    }
    
}
