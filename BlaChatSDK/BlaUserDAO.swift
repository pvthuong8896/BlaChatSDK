//
//  BlaUserDAO.swift
//  ChatSDK
//
//  Created by Os on 5/11/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public class BlaUserDAO: NSObject {
    public var id: String?
    public var name: String?
    public var avatar: String?
    public var updatedAt: Date?
    public var createdAt: Date?
    public var customData: String?
    
    public init(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        avatar = json["avatar"].stringValue
        createdAt = Date.init(timeIntervalSince1970: json["created_at"].doubleValue)
        updatedAt = Date.init(timeIntervalSince1970: json["updated_at"].doubleValue)
        customData = json["custom_data"].stringValue
    }
}
