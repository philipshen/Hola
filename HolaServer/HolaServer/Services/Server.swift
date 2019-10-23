//
//  BonjourService.swift
//  BonjourPlayground
//
//  Created by Philip Shen on 10/21/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

class Server: NSObject {
    
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private var openedStreams = 0
    
    // Dependencies
    private let service: NetService
    private let logService: LogService?
    
    init(service: NetService, logService: LogService?) {
        self.service = service
        self.logService = logService
        super.init()
        
        service.delegate = self
    }
    
    convenience init(name: String? = nil, logService: LogService? = nil) {
        let name = name ?? "hola_\(Int.random(in: 1000..<9999))"
        let service = NetService(domain: "local.", type: "_https._tcp.", name: name, port: 0)
        self.init(service: service, logService: logService)
    }
    
    func publish() {
        log(.default(.publishing, "Publishing Hola service \"\(service.name)\""))
//        service.resolve(withTimeout: 10)
        service.publish(options: .listenForConnections)
    }
    
}

extension Server: NetServiceDelegate {
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        if let inputStream = self.inputStream {
            inputStream.open()
            inputStream.close()
            outputStream.open()
            outputStream.close()
            log(.error(.connecting, "Unable to connect to \(sender.name): connection already open."))
        } else {
            self.inputStream = open(stream: inputStream)
            self.outputStream = open(stream: outputStream)
            log(.success(.connecting, "Connection to \(service.name) accepted"))
        }
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String:NSNumber]) {
        log(.error(.publishing, getErrorMessage(errorDict)))
    }
    
    func netServiceDidPublish(_ sender: NetService) {
        log(.success(.publishing, "Published Bonjour service \"\(sender.name)\" to \(sender.domain):\(sender.port)"))
    }
    
    func netServiceDidStop(_ sender: NetService) {
        log(.error(.service, "Service stopped"))
    }
    
}

// MARK: - Stream Delegate
extension Server: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode.contains(.openCompleted) {
            openedStreams += 1
            
            // Once we have both streams open, stop the service
            if openedStreams == 2 {
                log(.success(.connecting, "Successfully opened input and output streams"))
                service.stop()
            }
        }
        
        if eventCode.contains(.hasBytesAvailable) {
            guard let inputStream = inputStream else {
                log(.error(.streaming, "Handling input stream, however no input stream set"))
                return
            }
            
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
            
            log(.default(.streaming, "Received message from client: \(message)"))
        }
    }
    
}

// MARK: - Private Utility Methods
private extension Server {
    
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
    
    func log(_ log: Log) {
        logService?.log(log)
    }
    
    func getErrorMessage(_ errorDict: [String:NSNumber]) -> String {
        let domain = errorDict["NSNetServicesErrorDomain"]!
        let errorCode = errorDict["NSNetServicesErrorCode"]!
        return "Failed with domain: \(domain) and error code: \(errorCode)"
    }
    
}
