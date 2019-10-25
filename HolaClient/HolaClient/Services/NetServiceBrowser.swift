//
//  NetServiceBrowser.swift
//  HolaClient
//
//  Created by Phil Shen on 10/24/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import CoreFoundation
import Foundation
import dnssd

/**
 Custom implementation of the NetServiceBrowser that runs completely in the background. It includes a subset of Apple's NetServiceBrowser API.
 */
class ServiceBrowser {
    
    private static let browseCallback: DNSServiceBrowseReply = { sdRef, flags, interfaceIndex, errorCode, name, regtype, domain, context in
        let browser: ServiceBrowser = Unmanaged.fromOpaque(context!).takeUnretainedValue()
        guard errorCode == kDNSServiceErr_NoError else {
            return browser.didNotSearch(error: Int(errorCode))
        }
        
        let name = String(cString: name!)
        let domain = String(cString: domain!)
        let regtype = String(cString: regtype!)
        let flags = ServiceFlags(rawValue: flags)
        let service = NetService(domain: domain, type: regtype, name: name)
        
        if flags.contains(.add) {
            browser.didFind(service: service, moreComing: flags.contains(.moreComing))
        } else {
            browser.didRemove(service: service, moreComing: flags.contains(.moreComing))
        }
    }
    
    private var serviceRef: DNSServiceRef?
    
    var delegate: ServiceBrowserDelegate?
    
    init() {}
    
    public func searchForServices(ofType type: String, inDomain domain: String) {
        guard serviceRef == nil else {
            return didNotSearch(error: .activityInProgress)
        }
        
//        browse {
//            DNSServiceBrowse(&serviceRef, 0, 0, domain, <#T##domain: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>, <#T##callBack: DNSServiceBrowseReply!##DNSServiceBrowseReply!##(DNSServiceRef?, DNSServiceFlags, UInt32, DNSServiceErrorType, UnsafePointer<Int8>?, UnsafePointer<Int8>?, UnsafePointer<Int8>?, UnsafeMutableRawPointer?) -> Void#>, <#T##context: UnsafeMutableRawPointer!##UnsafeMutableRawPointer!#>)
//        }
    }
    
    private func browse(setup: () -> DNSServiceErrorType) {
        
    }
    
    // MARK: Delegated Methods
    private func didFind(service: NetService, moreComing: Bool) {
        delegate?.netServiceBrowser(self, didFind: service, moreComing: moreComing)
    }
    
    private func didRemove(service: NetService, moreComing: Bool) {
        delegate?.netServiceBrowser(self, didRemove: service, moreComing: moreComing)
    }
    
    private func didNotSearch(error: NetService.ErrorCode) {
        didNotSearch(error: error.rawValue)
    }
    
    private func didNotSearch(error: Int) {
        delegate?.netServiceBrowser(self, didNotSearch: [
            NetService.errorDomain: NSNumber(value: 10),
            NetService.errorCode: NSNumber(value: error)
        ])
    }
    
}
