//
//  SocketError.swift
//  HolaClient
//
//  Created by Philip Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

enum ClientSocketError: LocalizedError {
    
    case alreadyConnected(to: NetService)
    
    var errorDescription: String? {
        switch self {
        case .alreadyConnected(let service):
            return "Already connected to service \(service.name)"
        }
    }
    
}
