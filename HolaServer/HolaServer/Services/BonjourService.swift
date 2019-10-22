//
//  BonjourService.swift
//  BonjourPlayground
//
//  Created by Philip Shen on 10/21/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation
import os.log

class BonjourService: NSObject {
    
    private var inputStream: InputStream?
    private var ouputStream: OutputStream?
    
    // Dependencies
    private let service: NetService
    private let logService: LogService
    
    init(service: NetService, logService: LogService) {
        self.service = service
        self.logService = logService
        super.init()
        
        service.delegate = self
    }
    
    convenience init(name: String, logService: LogService) {
        let service = NetService(domain: "local.", type: "_myservice._tcp.", name: name)
        self.init(service: service, logService: logService)
    }
    
    func publish() {
        service.publish(options: .listenForConnections)
    }
    
}

extension BonjourService: NetServiceDelegate {
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        OperationQueue.main.addOperation { [weak self] in
            if let inputStream = self?.inputStream {
                inputStream.open()
                inputStream.close()
                outputStream.open()
                outputStream.close()
                
            }
        }
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        let domain = errorDict["NSNetServicesErrorDomain"]!
        let errorCode = errorDict["NSNetServicesErrorCode"]!
        logService.log(.error(.publishing, "Failed with domain: \(domain) and error code: \(errorCode)"))
    }
    
    func netServiceDidPublish(_ sender: NetService) {
        logService.log(.success(.publishing, "Published Bonjour service \"\(sender.name)\" to \(sender.domain):\(sender.port)"))
    }
    
}
