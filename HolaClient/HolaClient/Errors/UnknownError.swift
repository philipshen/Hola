//
//  UnknownError.swift
//  HolaClient
//
//  Created by Phil Shen on 10/23/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

public struct UnknownError: LocalizedError {
    
    public var errorDescription: String?
    
    init(_ description: String? = nil) {
        errorDescription = description
    }
    
}
