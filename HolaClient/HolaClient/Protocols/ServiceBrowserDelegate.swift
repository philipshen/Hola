//
//  NetServiceBrowserDelegate.swift
//  HolaClient
//
//  Created by Phil Shen on 10/24/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

protocol ServiceBrowserDelegate: class {
    
    func netServiceBrowser(_ browser: ServiceBrowser,
                           didNotSearch errorDict: [String:NSNumber])
    
    func netServiceBrowser(_ browser: ServiceBrowser,
                           didRemove service: NetService,
                           moreComing: Bool)
    
    func netServiceBrowser(_ browser: ServiceBrowser,
                           didFind service: NetService,
                           moreComing: Bool)
    
}
