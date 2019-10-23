//
//  BonjourService.swift
//  BonjourPlayground
//
//  Created by Philip Shen on 10/21/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation
import os.log

class BonjourServer: NSObject {
    
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private var areStreamsOpen = false
    
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
        let name = name ?? "hola"
        let service = NetService(domain: "local.", type: "_https._tcp.", name: name)
        self.init(service: service, logService: logService)
    }
    
    func publish() {
        service.publish(options: .listenForConnections)
    }
    
}

extension BonjourServer: NetServiceDelegate {
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        OperationQueue.main.addOperation { [weak self] in
            if let inputStream = self?.inputStream {
                inputStream.open()
                inputStream.close()
                outputStream.open()
                outputStream.close()
                self?.logService?.log(.default(.connecting, "Accepted connection from \"\(sender.name)\", however another connection was already open."))
            } else {
                self?.service.stop()
                self?.inputStream = self?.open(stream: inputStream)
                self?.outputStream = self?.open(stream: outputStream)
            }
        }
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        let domain = errorDict["NSNetServicesErrorDomain"]!
        let errorCode = errorDict["NSNetServicesErrorCode"]!
        logService?.log(.error(.publishing, "Failed with domain: \(domain) and error code: \(errorCode)"))
    }
    
    func netServiceDidPublish(_ sender: NetService) {
        logService?.log(.success(.publishing, "Published Bonjour service \"\(sender.name)\" to \(sender.domain):\(sender.port)"))
    }
    
}

// MARK: - Stream Delegate
extension BonjourServer: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode.contains(.hasBytesAvailable) {
            guard let inputStream = self.inputStream else {
                logService?.log(.error(.streaming, "Handling input stream, however no input stream set"))
                return
            }
            
            let bufferSize = 4096
            var buffer = Array<UInt8>(repeating: 0, count: bufferSize)
            var message = ""
            
            while inputStream.hasBytesAvailable {
                let len = inputStream.read(&buffer, maxLength: bufferSize)
                if len < 0 {
                    logService?.log(.error(.streaming, "Error reading stream. Closing streams."))
                    return self.closeStreams()
                }
                
                if len > 0 {
                    message += String(bytes: buffer, encoding: .utf8)!
                }
                
                if len == 0 { break }
            }
            
            logService?.log(.default(.streaming, "Received message: \(message)"))
        }
    }
    
}

// MARK: - Private Utility Methods
private extension BonjourServer {
    
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
