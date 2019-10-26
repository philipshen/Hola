//
//  ServerIdentifierManager.swift
//  HolaServer
//
//  Created by Philip Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

func getServerIdentifier() -> String {
    return ServerIdentifierManager.shared.get()
}

/**
 Singleton class that manages the Server Identifier, which clients use to identify the correct Hola server to connect to.
 */
class ServerIdentifierManager {
    
    static let shared = ServerIdentifierManager()
    
    private struct Constants {
        static let key = "serverIdentifier"
    }
    
    private let userDefaults: UserDefaults
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func get() -> String {
        if let id = userDefaults.string(forKey: Constants.key) {
            return id
        } else {
            let id = generate()
            userDefaults.set(id, forKey: Constants.key)
            return id
        }
    }
    
    private func generate() -> String {
        return String(Int.random(in: 10000..<99999))
    }
    
}
