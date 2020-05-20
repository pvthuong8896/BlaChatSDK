//
//  UserInChannel.swift
//  ChatSDK
//
//  Created by Os on 4/14/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public class BlaUserInChannel {
    public var id: String?
    public var channelId: String?
    public var userId: String?
    public var lastSeen: Date?
    public var lastReceive: Date?
    
    public init(channelId: String?, userId: String?, lastSeen: Double?, lastReceive: Double?) {
        if let id = id {
            self.id = id
        }
        if let channelId = channelId {
            self.channelId = channelId
        }
        if let userId = userId {
            self.userId = userId
        }
        if let lastSeen = lastSeen {
            self.lastSeen = Date(timeIntervalSince1970: lastSeen)
        }
        if let lastReceive = lastReceive {
            self.lastReceive = Date(timeIntervalSince1970: lastReceive)
        }
    }
    
    init(json: JSON, channelId: String) {
        self.channelId = channelId
        self.userId = json["member_id"].stringValue
        self.lastReceive = Date.init(timeIntervalSince1970: json["last_receive"].doubleValue)
        self.lastSeen = Date.init(timeIntervalSince1970: json["last_seen"].doubleValue)
    }
    
}
