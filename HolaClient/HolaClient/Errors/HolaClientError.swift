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
    case failedToSearchForServices(domain: NSNumber, code: NSNumber)
    case serverIDNotSet
    case noHolaServicesFound(id: String)
    case getURLTimeout
    
    static func failedToResolve(errorDict: [String:NSNumber]) -> HolaClientError {
        guard let info = errorDict.netServiceErrorInfo else {
            fatalError("Invalid error dict: \(errorDict)")
        }
        
        return .failedToResolve(domain: info.domain, code: info.code)
    }
    
    static func failedToSearch(errorDict: [String:NSNumber]) -> HolaClientError {
        guard let info = errorDict.netServiceErrorInfo else {
            fatalError("Invalid error dict: \(errorDict)")
        }
        
        return .failedToSearchForServices(domain: info.domain, code: info.code)
    }
    
    public var errorDescription: String? {
        switch self {
        case .failedToResolve(let domain, let code):
            return "Failed to resolve service (domain: \(domain), errorCode: \(code))"
        case .failedToSearchForServices(let domain, let code):
            return "Failed to search for services (domain: \(domain), errorCode: \(code))"
        case .serverIDNotSet:
            return "Environment variable \"holaServerID\" must be set."
        case .noHolaServicesFound(let id):
            return "No Hola services found with id \"\(id)\"."
        case .getURLTimeout:
            return "Timed out."
        }
    }
    
}
