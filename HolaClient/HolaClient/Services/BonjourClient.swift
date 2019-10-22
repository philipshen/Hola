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
 Connects to the first "hola" client it can find. THIS IS SUBJECT TO CHANGE. Ideally, server/clients would pair
 automatically when run together, even when run from the same machine...
 */
class BonjourClient: NSObject {
    
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    
    private let browser: NetServiceBrowser
    
    var areStreamsOpen: Bool {
        return inputStream != nil && outputStream != nil
    }
    
    init(browser: NetServiceBrowser = NetServiceBrowser()) {
        self.browser = browser
        super.init()
        
        self.browser.delegate = self
        self.browser.searchForServices(ofType: "_https._tcp", inDomain: "local.")
    }
    
}

// MARK: - NetServiceBrowserDelegate
extension BonjourClient: NetServiceBrowserDelegate {
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if !areStreamsOpen && isHolaService(service) {
            connect(to: service)
        } else {
            os_log("Ignoring service \"%@\"", service.name)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {}
    
}

extension BonjourClient: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
    }
    
}

// MARK: - Private Utility Methods
private extension BonjourClient {
    
    func isHolaService(_ service: NetService) -> Bool {
        return service.name.hasPrefix("hola")
    }
    
    func connect(to service: NetService) {
        var input: InputStream?
        var output: OutputStream?
        let success = service.getInputStream(&input, outputStream: &output)
        
        if !success {
            return os_log("Could not connect to service \"%@\"", service.name)
        }
        
        inputStream = open(stream: input)
        outputStream = open(stream: output)
    }
    
    func closeStreams() {
        close(stream: &inputStream)
        close(stream: &outputStream)
    }
    
    /**
     Opens a stream and sets its delegate to self, then returns it.
     */
    func open<T: Stream>(stream: T?) -> T? {
        guard let stream = stream else { return nil }
        stream.delegate = self
        stream.schedule(in: .current, forMode: .default)
        stream.open()
        return stream
    }
    
    /**
     Closes and nullifies a stream
     */
    func close<T: Stream>(stream: inout T?) {
        stream?.remove(from: .current, forMode: .default)
        stream?.close()
        stream = nil
    }
    
}
