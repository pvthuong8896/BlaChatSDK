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
}

public enum BlaMessageType: Int {
    case TEXT = 0
}

public enum BlaEventType {
    case START
    case STOP
}
