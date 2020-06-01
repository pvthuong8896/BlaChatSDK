//
//  BlaChannelDAO.swift
//  ChatSDK
//
//  Created by Os on 5/11/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public class BlaChannelDAO: NSObject {
    public var id: String?
    public var name: String?
    public var avatar: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var isDeleted: Bool?
    public var type: Int?
    public var customData: String?
    public var lastMessages: [BlaMessageDAO]?
    
    public init(json: JSON) {
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
