//
//  BlaMessageDAO.swift
//  ChatSDK
//
//  Created by Os on 5/11/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public class BlaMessageDAO: NSObject {
    public var id: String?
    public var authorId: String?
    public var channelId: String?
    public var content: String?
    public var type: Int?
    public var isSystemMessage: Bool?
    public var createdAt: Date?
    public var sentAt: Date?
    public var customData: String?
    
    public init(json: JSON) {
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
