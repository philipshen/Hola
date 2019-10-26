//
//  ClientSocketManager.swift
//  HolaClient
//
//  Created by Phil Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation
import os.log

/**
 Manages a socket between the client and the service, which can be used for passing messages.
 */
class ClientSocketManager: NSObject {
    
    private var service: NetService?
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private var isInputStreamOpen = false {
        didSet {
            if isInputStreamOpen {
                os_log("Input stream to \"%@\" open", service?.name ?? "")
            }
        }
    }
    private var isOutputStreamOpen = false {
        didSet {
            if isInputStreamOpen {
                os_log("Output stream to \"%@\" open", service?.name ?? "")
            }
        }
    }
    
    private var areStreamsOpen: Bool {
        isInputStreamOpen && isOutputStreamOpen
    }
    
    /**
     Opens a socket with the NetService.
     
     - Parameters:
        - service: The NetService to open a socket with
        - override: If there is already a service connected, setting this paramter to `true` will disconnect the client from that service and connect to the new socket. Otherwise, attempting to connect to the new service will throw an error. This is set to `false` by default.
     */
    func connect(to service: NetService, override: Bool = false) throws {
        if let currentService = self.service {
            throw ClientSocketError.alreadyConnected(to: currentService)
        }
        
        self.service = service
        let success = service.getInputStream(&inputStream,
                                             outputStream: &outputStream)
            
        if success {
            open(stream: inputStream)
            open(stream: outputStream)
            os_log("Connected to service \"%@\"", service.name)
        } else {
            os_log("Failed to connect to service \"%@\"", service.name)
        }
    }
    
    /**
     Opens a stream and sets its delegate to self, then returns it
     */
    @discardableResult
    func open<T: Stream>(stream: T?) -> T? {
        guard let stream = stream else { return nil }
        stream.delegate = self
        stream.schedule(in: .current, forMode: .default)
        stream.open()
        return stream
    }
    
}

extension ClientSocketManager: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode.contains(.openCompleted) {
            if aStream === inputStream { isInputStreamOpen = true }
            if aStream === outputStream { isOutputStreamOpen = true }
        }
    }
    
}
