//
//  BonjourService.swift
//  BonjourPlayground
//
//  Created by Philip Shen on 10/21/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

class HolaServer: NSObject {
    
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
        let name = name ?? "hola_\(getServerIdentifier())"
        let service = NetService(domain: "local.", type: "_http._tcp.", name: name, port: 0)
        self.init(service: service, logService: logService)
    }
    
    func publish() {
        log(.default(.publishing, "Publishing Hola service \"\(service.name)\""))
        service.publish(options: .listenForConnections)
    }
    
}

// MARK: - NetServiceDelegate
extension HolaServer: NetServiceDelegate {
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String:NSNumber]) {
        log(.error(.publishing, "Failed to publish service: \(getErrorMessage(errorDict))"))
    }
    
    func netServiceDidPublish(_ sender: NetService) {
        log(.success(.publishing, "Published Bonjour service \"\(sender.name)\" to \(sender.domain):\(sender.port)"))
    }
    
    func netServiceDidStop(_ sender: NetService) {
        log(.error(.service, "Service stopped"))
    }
    
}

// MARK: - Stream Delegate
extension HolaServer: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode.contains(.hasBytesAvailable) {
            guard let inputStream = aStream as? InputStream else {
                log(.error(.streaming, "Error reading stream: stream must be of type InputStream"))
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
private extension HolaServer {
    
    func log(_ log: Log) {
        logService?.log(log)
    }
    
    func getErrorMessage(_ errorDict: [String:NSNumber]) -> String {
        let domain = errorDict[NetService.errorDomain]!
        let errorCode = errorDict[NetService.errorCode]!
        return "Failed with domain: \(domain) and error code: \(errorCode)"
    }
    
}
