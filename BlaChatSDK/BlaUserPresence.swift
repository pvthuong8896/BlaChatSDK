//
//  BlaUserPresence.swift
//  ChatSDK
//
//  Created by Os on 5/13/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit

public class BlaUserPresence: Codable {
    public var user: BlaUser?
    public var state: BlaPresenceState
    
    public init(user: BlaUser, state: BlaPresenceState) {
        self.user = user
        self.state = state
    }
}
