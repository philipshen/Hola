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
 
 Shoutout to Bouke on Github! This implementation would have been a huge pain if he hadn't done it first.
 */
class ServiceBrowser {
    
    private var serviceRef: DNSServiceRef?
    private var socket: CFSocket?
    private var source: CFRunLoopSource?
    
    var delegate: ServiceBrowserDelegate?
    
    init() {}
    
    // MARK: - API
    func searchForServices(ofType type: String, inDomain domain: String) {
        guard serviceRef == nil else {
            return didNotSearch(error: .activityInProgress)
        }
        
        browse {
            DNSServiceBrowse(&serviceRef, 0, 0, type, domain,
                             ServiceBrowser.browseCallback,
                             Unmanaged.passUnretained(self).toOpaque())
        }
    }
    
    func stop() {
        assert(serviceRef != nil, "Browser already stopped")
        CFRunLoopSourceInvalidate(source)
        CFSocketInvalidate(socket)
        DNSServiceRefDeallocate(serviceRef)
    }
    
    // MARK: - Private Methods
    private func browse(setup: () -> DNSServiceErrorType) {
        let error = setup()
        guard error == 0 else { return didNotSearch(error: Int(error)) }
        start()
    }
    
    private func start() {
        if serviceRef == nil {
            fatalError("Attempted to start browsing, but service ref has not been initialized")
        }
        
        let fd = DNSServiceRefSockFD(serviceRef)
        let info = Unmanaged.passUnretained(self).toOpaque()
        
        var context = CFSocketContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
        socket = CFSocketCreateWithNative(nil, fd, CFOptionFlags(CFSocketCallBackType.readCallBack.rawValue), ServiceBrowser.processResult, &context)
        
        // Don't close the underlying socket on invalidate; it's owned by dnssd
        var socketFlags = CFSocketGetSocketFlags(socket)
        socketFlags &= ~CFOptionFlags(kCFSocketCloseOnInvalidate)
        CFSocketSetSocketFlags(socket, socketFlags)
        
        source = CFSocketCreateRunLoopSource(nil, socket, 0)
        // DO THIS IN THE BACKGROUND BY USING A BACKGROUND RUN LOOP??
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, CFRunLoopMode.commonModes)
    }
    
    private func processResult() {
        DNSServiceProcessResult(serviceRef)
    }
    
    // MARK: Static Callbacks
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
    
    private static let processResult: CFSocketCallBack = { s, type, address, data, info in
        let browser: ServiceBrowser = Unmanaged.fromOpaque(info!).takeUnretainedValue()
        browser.processResult()
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