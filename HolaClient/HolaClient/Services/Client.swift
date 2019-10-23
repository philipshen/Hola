//
//  BrowserService.swift
//  HolaClient
//
//  Created by Phil Shen on 10/22/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation
import os.log

class Client: NSObject {
    
    private enum Status {
        /// Indicates the Client is waiting to start searching for Hola services
        case uninitialized
        
        /// Indicates the client is currently resolving the server's host
        case resolving
        
        /// Indicates the client has finished resolving the server's host
        case resolved(String)
        
        /// Indicates the client failed to resolve with a given error
        case error(Error)
    }
    
    static let shared = Client()
    
    private var status: Status = .uninitialized
    private var service: NetService?
    private lazy var getURLCallbacks = [((String?, Error?) -> Void)]()
    
    private let browser: NetServiceBrowser
    
    private init(browser: NetServiceBrowser = NetServiceBrowser()) {
        self.browser = browser
        super.init()
        self.browser.delegate = self
    }
    
}

// MARK: - API
extension Client {
    
    // TODO: Need to implement timeout. This can hang forever.
    func getURL(completion: @escaping (String?, Error?) -> Void) {
        switch status {
        case .uninitialized, .error(_):
            beginResolution()
            fallthrough
        case .resolving:
            getURLCallbacks.append(completion)
        case .resolved(let url):
            completion(url, nil)
        }
    }
    
}

// MARK: - NetServiceBrowserDelegate
extension Client: NetServiceBrowserDelegate {
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if self.service == nil {
            if isHolaService(service) {
                os_log("Found Hola service \"%@\"", service.name)
                self.service = service
                service.delegate = self
                service.resolve(withTimeout: 10)
            } else if !moreComing {
                // Finish with timeout error
            }
        } else {
            os_log("Already have a service; ignoring \"%@\"", service.name)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {}
    
}

extension Client: NetServiceDelegate {
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String:NSNumber]) {
        // Fail each completion handler
        let domain = errorDict["NSNetServicesErrorDomain"]!
        let errorCode = errorDict["NSNetServicesErrorCode"]!
        let error = HolaClientError.failedToResolve(domain: domain, code: errorCode)
        getURLCallbacks.forEach { $0(nil, error) }
        getURLCallbacks.removeAll()
        status = .error(error)
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let url = sender.urlString else {
            fatalError("Resolved address, but unable to find the service")
        }
        
        getURLCallbacks.forEach { $0(url, nil) }
        getURLCallbacks.removeAll()
        status = .resolved(url)
    }
    
}

// MARK: - Private Utility Methods
private extension Client {
    
    func isHolaService(_ service: NetService) -> Bool {
        return service.name.hasPrefix("hola")
    }
    
    func beginResolution() {
        status = .resolving
        if let service = service {
            service.resolve(withTimeout: 10)
        } else {
            browser.searchForServices(ofType: "_https._tcp", inDomain: "local.")
        }
    }
    
}
