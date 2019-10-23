//
//  NetService.swift
//  HolaClient
//
//  Created by Phil Shen on 10/23/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

extension NetService {
    
    var urlString: String? {
        if let address = firstAddress {
            return "http://\(address):\(port)"
        } else {
            return nil
        }
    }
    
    /**
     Just gets the first address, which is most likely IPv4
     */
    var firstAddress: String? {
        var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        guard let data = addresses?.first else { return nil }
        data.withUnsafeBytes { ptr in
            guard let sockaddr_ptr = ptr.baseAddress?.assumingMemoryBound(to: sockaddr.self) else {
                return
            }

            let sockAddr = sockaddr_ptr.pointee
            guard getnameinfo(sockaddr_ptr, socklen_t(sockAddr.sa_len), &hostName, socklen_t(hostName.count), nil, 0, NI_NUMERICHOST) == 0 else {
                return
            }
        }
        
        let ipAddress = String(cString: hostName)
        return ipAddress.isEmpty ? nil : ipAddress
    }
    
}
