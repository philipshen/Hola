//
//  HolaClientError.swift
//  HolaClient
//
//  Created by Phil Shen on 10/23/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

public enum HolaClientError: LocalizedError {
    
    case failedToResolve(domain: NSNumber, code: NSNumber)
    case noHolaServicesFound
    case getURLTimeout
    
    public var errorDescription: String? {
        switch self {
        case .failedToResolve(let domain, let code):
            return "Failed to resolve service (domain: \(domain), errorCode: \(code)."
        case .noHolaServicesFound:
            return "No Hola services found."
        case .getURLTimeout:
            return "Timed out."
        }
    }
    
}
