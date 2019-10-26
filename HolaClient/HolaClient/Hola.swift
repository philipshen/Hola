//
//  Hola.swift
//  HolaClient
//
//  Created by Phil Shen on 10/23/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

public let Hola = HolaInterface.shared

/**
 This class maintains a global state for the HolaClient.
 */
public class HolaInterface {
    
    // TODO: The shared name should be unique to the device & host app
    fileprivate static let shared = HolaInterface(name: "shared")
    
    private let client: HolaClient
    private let socketManager: ClientSocketManager
    
    /**
     Initializer to support the creation of multiple Hola clients within the same project. Each will communicate with the server independently.
     */
    // TODO: Named clients!
    public convenience init(_ name: String) {
        self.init(name: name)
    }
    
    private init(
        name: String,
        client: HolaClient = HolaClient(),
        socketManager: ClientSocketManager = ClientSocketManager()
    ) {
        self.client = client
        self.socketManager = socketManager
        
        self.client.delegate = self
    }
    
    /**
     Gets the URL of the Hola server that (1) matches the holaServerIdentifier set in the client's environment variables and (2) is on the same network as the client.
     
     - Returns:The URL of the Hola server
     */
    public func getURL(timeout: Double = 10) throws -> String {
        let group = DispatchGroup()
        
        var url: String?
        var error: Error?
        
        client.beginSearching(serverID: try getServerID())
        
        group.enter()
        getURLAsync(timeout: timeout) { fetchedUrl, fetchedError in
            url = fetchedUrl
            error = fetchedError
            group.leave()
        }
        group.wait()
        
        if let url = url {
            return url
        } else {
            throw error!
        }
    }
    
    public func getURLAsync(timeout: Double = 10, completion: @escaping (String?, Error?) -> Void) {
        do {
            let serverID = try getServerID()
            client.beginSearching(serverID: serverID)
            client.getURL(timeout: timeout, completion: completion)
        }
        catch let error {
            completion(nil, error)
        }
    }
    
}

// MARK: - HolaClientDelegate
extension HolaInterface: HolaClientDelegate {
    
    func holaClient(_ holaClient: HolaClient, didFind service: NetService) {
        try! socketManager.connect(to: service)
    }
    
}

// MARK: - Helper Methods
private extension HolaInterface {
    
    func getServerID() throws -> String {
        guard let id = ProcessInfo.processInfo.environment["holaServerIdentifier"] else {
            throw HolaClientError.serverIDNotSet
        }
        
        return id
    }
    
}
