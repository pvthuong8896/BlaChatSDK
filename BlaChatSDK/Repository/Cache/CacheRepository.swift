//
//  CacheRepository.swift
//  ChatSDK
//
//  Created by Os on 4/16/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit

class CacheRepository: NSObject {

    var validUsers = [BlaUser]()
    var vallidChannels = [BlaChannel]()
    
    static var shareInstance: CacheRepository = {
        let instance = CacheRepository()
        return instance
    }()
    
}
