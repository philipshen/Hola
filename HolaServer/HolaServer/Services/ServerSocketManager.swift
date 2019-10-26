//
//  ServerSocketManager.swift
//  HolaServer
//
//  Created by Philip Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

// TODO: Messages should be passed to a delegate. That includes HTTP requests
// and other messages.
class ServerSocketManager: NSObject {
    
//    private var inputStreams = Set<InputStream>()
//    private var outputStreams = Set<OutputStream>()
    private var service: NetService?
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private lazy var openedStreams = 0
    
}

// MARK: - API
extension ServerSocketManager {
    
    func addConnection(service: NetService, inputStream: InputStream, outputStream: OutputStream) {
        if let stream = self.inputStream {
            stream.open()
            stream.close()
            outputStream.open()
            outputStream.close()
            return
        }
        
        self.service = service
        self.inputStream = open(stream: inputStream)
        self.outputStream = open(stream: outputStream)
    }
    
}

// MARK: - Private Methods
extension ServerSocketManager {
    
    func openAndClose(stream: Stream) {
        open(stream: stream)
        close(stream: stream)
    }
    
    @discardableResult
    func open<T: Stream>(stream: T) -> T {
        stream.delegate = self
        stream.schedule(in: .current, forMode: .default)
        stream.open()
        return stream
    }
    
    func close(stream: Stream) {
        stream.remove(from: .current, forMode: .default)
        stream.close()
    }
    
}

// MARK: Stream Delegate
extension ServerSocketManager: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if
            let inputStream = inputStream,
            eventCode.contains(.hasBytesAvailable)
        {
            let bufferSize = 4096
            var buffer = Array<UInt8>(repeating: 0, count: bufferSize)
            var message = ""
            
            while inputStream.hasBytesAvailable {
                let len = inputStream.read(&buffer, maxLength: bufferSize)
                if len < 0 {
                    fatalError("Error reading stream: buffer length cannot be less than 0")
                }
                
                if len > 0 {
                    message += String(bytes: buffer, encoding: .utf8)!
                }
                
                if len == 0 { break }
            }
        }
    }
    
}
