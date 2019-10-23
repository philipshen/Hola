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
    
    private enum Status: String {
        case uninitialized
        case searchingForServices
        case openingStreams
        case openedStreams
    }
    
    static let shared = Client()
    
    private var service: NetService?
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private var status: Status = .uninitialized {
        didSet {
            os_log("Client status changed to \"%@\"", status.rawValue)
        }
    }
    private var openedStreams = 0 {
        didSet { assert(openedStreams >= 0 && openedStreams <= 2) }
    }
    private var streamsConnectedCompletion: (() -> Void)?
    
    private let browser: NetServiceBrowser
    
    private init(browser: NetServiceBrowser = NetServiceBrowser()) {
        self.browser = browser
        super.init()
        browser.delegate = self
    }
    
}

// MARK: - API
extension Client {
    
    func initialize() {
        browser.searchForServices(ofType: "_https._tcp", inDomain: "local.")
        status = .searchingForServices
    }
    
    func send(message: String) {
        guard openedStreams == 2 else {
            return os_log("Attempt to send message failed: only %d open streams", openedStreams)
        }
        
        guard outputStream?.hasSpaceAvailable == true else {
            return os_log("Attempt to send message failed: no space available in output stream")
        }
        
        guard let data = message.data(using: .utf8) else {
            return os_log("Attempt to send message failed: unable to encode message as utf8 data")
        }
        
        let bytesWritten = data.withUnsafeBytes {
            outputStream?.write($0, maxLength: data.count)
        }
        
        if bytesWritten == data.count {
            os_log("Sent message to server: %@", message)
        } else {
            fatalError("Undefined behavior: bytes written to the output stream did not match the size of the message.")
        }
    }
    
}

// MARK: - NetServiceBrowserDelegate
extension Client: NetServiceBrowserDelegate {
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if status == .searchingForServices && isHolaService(service) {
            os_log("Connecting to service \"%@\"", service.name)
            self.service = service
            service.delegate = self
            service.resolve(withTimeout: 10)
            print("Done")
//            connect(to: service)
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
        print(sender.hostName)
        sender.addresses?.forEach({
            print(String(data: $0, encoding: .utf8)!)
        })
        
        // NEED TO CONVERT THE ADDRESSES TO IP. NO NEED TO MESS AROUND
        // WITH THAT SOCKET STUFF...
    }
    
}

extension Client: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode.contains(.openCompleted) {
            openedStreams += 1
        } else {
            open(stream: aStream)
        }
        
        if eventCode.contains(.hasSpaceAvailable) {
            if openedStreams == 2 && status != .openedStreams {
                os_log("Streams connected")
                status = .openedStreams
            } else {
                assertionFailure()
            }
        }
    }
    
}

// MARK: - Private Utility Methods
private extension Client {
    
    func isHolaService(_ service: NetService) -> Bool {
        return service.name.hasPrefix("hola")
    }
    
    func connect(to service: NetService) {
        self.service = service
        let success = service.getInputStream(&inputStream, outputStream: &outputStream)
        
        if success {
            inputStream = open(stream: inputStream)
            outputStream = open(stream: outputStream)
            status = .openingStreams
        } else {
            os_log("Could not connect to service \"%@\"", service.name)
        }
    }
    
    /**
     Opens a stream and sets its delegate to self, then returns it.
     */
    @discardableResult
    func open<T: Stream>(stream: T?) -> T? {
        guard let stream = stream else { return nil }
        stream.delegate = self
        stream.schedule(in: .current, forMode: .default)
        stream.open()
        return stream
    }
    
    /**
     Returns the IPv4 address, or IPv6 if it's present
     */
    func getAddress(data: [Data]) -> String {
        // Get both IPv4 and IPv6
        for case let addressData as NSData in data {
            
        }
    }
    
}
