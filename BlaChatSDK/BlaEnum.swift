//
//  BlaEnum.swift
//  ChatSDK
//
//  Created by Os on 5/7/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit

public enum BlaChannelType: Int {
    case GROUP = 1
    case DIRECT = 2
    
    public init(rawValue: Int) {
        switch rawValue {
        case 1:
            self = .GROUP
            break
        case 2:
            self = .DIRECT
            break
        default:
            self = .GROUP
            break
        }
    }
}

public enum BlaMessageType: Int {
    case TEXT = 0
    case IMAGE = 1
    case OTHER = 2
    
    public init(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .TEXT
            break
        case 1:
            self = .IMAGE
            break
        case 2:
            self = .OTHER
            break
        default:
            self = .TEXT
            break
        }
    }
}

public enum BlaEventType {
    case START
    case STOP
}
