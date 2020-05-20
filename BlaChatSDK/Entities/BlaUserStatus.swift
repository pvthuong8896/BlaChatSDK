
//
//  UserStatus.swift
//  ChatSDK
//
//  Created by Os on 4/28/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public class BlaUserStatus: NSObject {
    public var userId: String?
    public var isOnline = false
    
    public init(json: JSON) {
        userId = json["ID"].stringValue
        if json["Status"].intValue == 2 {
            isOnline = true
        } else {
            isOnline = false
        }
    }
}
