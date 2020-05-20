//
//  BlaChannelDAO.swift
//  ChatSDK
//
//  Created by Os on 5/11/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

class BlaChannelDAO: NSObject {
    var id: String?
    var name: String?
    var avatar: String?
    var createdAt: Date?
    var updatedAt: Date?
    var isDeleted: Bool?
    var type: Int?
    var customData: String?
    var lastMessages: [BlaMessageDAO]?
    
    init(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        avatar = json["avatar"].stringValue
        createdAt = Date.init(timeIntervalSince1970: json["created_at"].doubleValue)
        updatedAt = Date.init(timeIntervalSince1970: json["updated_at"].doubleValue)
        isDeleted = json["is_deleted"].boolValue
        customData = json["custom_data"].stringValue
        type = json["type"].intValue
        if json["last_messages"] != JSON.null {
            lastMessages = [BlaMessageDAO]()
            for subJson in json["last_messages"].arrayValue {
                let message = BlaMessageDAO(json: subJson)
                lastMessages?.append(message)
            }
        }
    }
}
