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
    private let socketManager: ServerSocketManager
    private let logService: LogService?
    
    init(service: NetService, socketManager: ServerSocketManager, logService: LogService?) {
        self.service = service
        self.socketManager = socketManager
        self.logService = logService
        super.init()
        
        service.delegate = self
    }
    
    convenience init(name: String? = nil, logService: LogService? = nil) {
        let name = name ?? "hola_\(getServerIdentifier())"
        let service = NetService(domain: "local.", type: "_http._tcp.", name: name, port: 0)
        
        self.init(service: service,
                  socketManager: ServerSocketManager(),
                  logService: logService)
    }
    
    func publish() {
        log(.default(.publishing, "Publishing Hola service \"\(service.name)\""))
        service.publish(options: .listenForConnections)
    }
    
}

// MARK: - NetServiceDelegate
extension HolaServer: NetServiceDelegate {
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        socketManager.addConnection(service: sender,
                                    inputStream: inputStream,
                                    outputStream: outputStream)
    }
    
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
