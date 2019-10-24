//
//  Hola.swift
//  HolaClient
//
//  Created by Phil Shen on 10/23/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

public class Hola {
    
    public static var defaultTimeout: Double = 10
    
    /**
     Gets the url string, synchronously.
     
     - Returns:
     */
    public static func getURL(timeout: Double = Hola.defaultTimeout) -> String {
        let group = DispatchGroup()
        
        var url: String?
        var error: Error?
        
        Client.shared.beginSearching()
        
        group.enter()
        Hola.getURLAsync(timeout: timeout) { fetchedUrl, fetchedError in
            url = fetchedUrl
            error = fetchedError
            group.leave()
        }
        group.wait()
        
        if let url = url {
            return url
        } else {
            fatalError("Failed to retrieve URL: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    public static func getURLAsync(timeout: Double = Hola.defaultTimeout, completion: @escaping (String?, Error?) -> Void) {
        Client.shared.beginSearching()
        Client.shared.getURL(timeout: timeout, completion: completion)
    }
    
}
