//
//  HolaClientDelegate.swift
//  HolaClient
//
//  Created by Philip Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

protocol HolaClientDelegate {
    
    func holaClient(_ holaClient: HolaClient, didFind service: NetService)
    
}
