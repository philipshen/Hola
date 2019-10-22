//
//  Log.swift
//  Hola
//
//  Created by Philip Shen on 10/21/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

struct Log {
    
    enum Domain {
        case initialization
        case publishing
        case connecting
        case streaming
        
        var displayName: String {
            switch self {
            case .initialization:
                return "Init"
            case .publishing:
                return "Publish"
            case .connecting:
                return "Connect"
            case .streaming:
                return "Stream"
            }
        }
    }
    
    enum Category {
        case success, error, `default`
    }
    
    static func success(_ domain: Domain, _ message: String) -> Log {
        return Log(message: message, domain: domain, category: .success)
    }
    
    static func error(_ domain: Domain, _ message: String) -> Log {
        return Log(message: message, domain: domain, category: .error)
    }
    
    static func `default`(_ domain: Domain, _ message: String) -> Log {
        return Log(message: message, domain: domain, category: .default)
    }
    
    let message: String
    let domain: Domain
    let category: Category
    
    init(message: String, domain: Domain, category: Category = .default) {
        self.message = message
        self.domain = domain
        self.category = category
    }
    
    func formatted() -> String {
        return "[\(domain.displayName)] \(message)"
    }
    
}
