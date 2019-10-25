//
//  HTTPError.swift
//  HolaTester
//
//  Created by Phil Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

struct HTTPError: LocalizedError {
    
    let statusCode: Int
    var message: String?
    
    var errorDescription: String? {
        if let message = message, !message.isEmpty {
            return message
        } else {
            return "HTTP Error \(statusCode)"
        }
    }
    
    init(statusCode: Int, message: String? = nil) {
        self.statusCode = statusCode
        self.message = message
    }
    
}
