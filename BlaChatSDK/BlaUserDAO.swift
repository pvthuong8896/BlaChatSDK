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
    public var updateAt: Date?
    public var createAt: Date?
    public var customData: String?
    
    public init(json: JSON) {
        id = json[""].stringValue
        name = json[""].stringValue
        avatar = json[""].stringValue
    }
}
