//
//  ClientSocketManager.swift
//  HolaClient
//
//  Created by Phil Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

/**
 Manages a socket between the client and the service, which can be used for passing messages.
 */
class ClientSocketManager {
    
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private var areStreamsOpen = false
    
    func connectTo(service: NetService) {
        let success = service.getInputStream(&inputStream, outputStream: &outputStream)
        if !success {
            
        }
    }
    
}
