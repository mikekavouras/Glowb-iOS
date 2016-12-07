//
//  Device.swift
//  Glowb
//
//  Created by Michael Kavouras on 12/5/16.
//  Copyright © 2016 Michael Kavouras. All rights reserved.
//

import Alamofire
import PromiseKit

enum DeviceConnectionStatus {
    case connected
    case disconnected
}

struct Device {
    let name: String
    let connectionStatus: DeviceConnectionStatus = .disconnected
    
    init(name: String) {
        self.name = name
    }
    
    static func create(deviceID: String) -> Promise<Device> {
        return Promise { fulfill, reject in
            
        }
    }
}
