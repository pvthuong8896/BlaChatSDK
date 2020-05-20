//
//  BlaUserDAO.swift
//  ChatSDK
//
//  Created by Os on 5/11/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

class BlaUserDAO: NSObject {
    var id: String?
    var name: String?
    var avatar: String?
    var updateAt: Date?
    var createAt: Date?
    var customData: String?
    
    init(json: JSON) {
        id = json[""].stringValue
        name = json[""].stringValue
        avatar = json[""].stringValue
    }
}
