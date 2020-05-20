//
//  BlaMessageDAO.swift
//  ChatSDK
//
//  Created by Os on 5/11/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

class BlaMessageDAO: NSObject {
    var id: String?
    var authorId: String?
    var channelId: String?
    var content: String?
    var type: Int?
    var isSystemMessage: Bool?
    var createdAt: Date?
    var sentAt: Date?
    var customData: String?
    
    init(json: JSON) {
        id = json["id"].stringValue
        authorId = json["author_id"].stringValue
        channelId = json["channel_id"].stringValue
        content = json["content"].stringValue
        type = json["type"].intValue
        isSystemMessage = json["is_system_message"].boolValue
        self.createdAt = Date.init(timeIntervalSince1970: json["created_at"].doubleValue)
        self.sentAt = Date.init(timeIntervalSince1970: json["sent_at"].doubleValue)
        customData = json["custom_data"].stringValue
    }
}
