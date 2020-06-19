//
//  CacheRepository.swift
//  ChatSDK
//
//  Created by Os on 4/16/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit

class CacheRepository: NSObject {

    var token: String = ""
    var userId: String = ""
    var validUsers = [BlaUser]()
    
    static var shareInstance: CacheRepository = {
        let instance = CacheRepository()
        return instance
    }()
    
}
