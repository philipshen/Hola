//
//  BrowserService.swift
//  HolaClient
//
//  Created by Phil Shen on 10/22/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation
import os.log

/**
 Connects to the first "hola" client it can find. THIS IS SUBJECT TO CHANGE. Ideally, server/clients would pair automatically when run together, even when run from the same machine...
 
 This class is a singleton; apps that depend on Hola will interact with the API, most of which goes through
 this client.
 */
class Client: NSObject {
    
    private struct Constants {
        static let defaultTimeout = 10
    }
    
    static let shared = Client()
    
    private var service: NetService? {
        didSet {
            
        }
    }
    private let browser: NetServiceBrowser
    
    private init(browser: NetServiceBrowser = NetServiceBrowser()) {
        self.browser = browser
        super.init()
        browser.delegate = self
        browser.searchForServices(ofType: "_https._tcp", inDomain: "local.")
    }
    
}

// MARK: - API
extension Client {
    
    func getURL(timeout: Int = Constants.defaultTimeout, completion: (String?, Error?) -> Void) {
        
    }
    
}

// MARK: - NetServiceBrowserDelegate
extension Client: NetServiceBrowserDelegate {
    
    // TODO: Gracefully handle multiple services... there should really only be one
    // that we match, though.
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if service == nil && isHolaService(service) {
            os_log("Found Hola service \"%@\"", service.name)
            self.service = service
            service.delegate = self
            service.resolve(withTimeout: 10)
        } else {
            os_log("Ignoring service \"%@\"", service.name)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {}
    
}

extension Client: NetServiceDelegate {
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String:NSNumber]) {
        print(errorDict)
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print(sender.urlString)
    }
    
}

// MARK: - Private Utility Methods
private extension Client {
    
    func isHolaService(_ service: NetService) -> Bool {
        return service.name.hasPrefix("hola")
    }
    
}
