//
//  BlaUser.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public class BlaUser: Codable {
    public var id: String?
    public var name: String?
    public var avatar: String?
    public var lastActiveAt: Date?
    public var customData: String?
    public var online = false
    
    public init(id: String?, name: String?, avatar: String?, lastActiveAt: Double?, customData: String?) {
        self.id = id
        self.name = name
        self.avatar = avatar
        if let lastActive = lastActiveAt {
            self.lastActiveAt = Date.init(timeIntervalSince1970: lastActive)
        }
        self.customData = customData
    }
    
    public init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.avatar = json["avatar"].stringValue
    }
}

