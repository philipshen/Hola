//
//  HTTPRequestError.swift
//  HolaTester
//
//  Created by Phil Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

enum HTTPRequestError: LocalizedError {
    
    case noURL
    
    var errorDescription: String? {
        switch self {
        case .noURL:
            return "No URL set"
        }
    }
    
}
