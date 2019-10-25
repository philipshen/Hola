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
    public static func getURL(timeout: Double = Hola.defaultTimeout) throws -> String {
        let group = DispatchGroup()
        
        var url: String?
        var error: Error?
        
        HolaClient.shared.beginSearching()
        
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
            throw error!
        }
    }
    
    public static func getURLAsync(timeout: Double = Hola.defaultTimeout, completion: @escaping (String?, Error?) -> Void) {
        HolaClient.shared.beginSearching()
        HolaClient.shared.getURL(timeout: timeout, completion: completion)
    }
    
}
