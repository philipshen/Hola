//
//  NSData+Utils.swift
//  HolaClient
//
//  Created by Phil Shen on 10/23/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

extension NSData {
    
    func getCPointer<T>() -> T {
        let size = MemoryLayout<T.Type>.size
        let mem = UnsafeMutablePointer<T>.allocate(capacity: size)
        getBytes(mem, length: size)
        return mem.move()
    }
    
}
