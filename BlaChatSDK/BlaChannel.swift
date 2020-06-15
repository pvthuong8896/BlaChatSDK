//
//  Channel.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public class BlaChannel: Codable {
    public var id: String?
    public var name: String?
    public var avatar: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var type: Int?
    public var customData: String?
    public var lastMessage: BlaMessage?
    public var lastMessageId: String?
    public var numberMessageNotSeen: Int = 0
    
    public init(dao: BlaChannelDAO) {
        self.id = dao.id
        self.name = dao.name
        self.avatar = dao.avatar
        self.createdAt = dao.createdAt
        self.updatedAt = dao.updatedAt
        self.customData = dao.customData
        self.type = dao.type
        if let lastMessages = dao.lastMessages, lastMessages.count > 0 {
            self.lastMessage = BlaMessage(dao: lastMessages[0])
            self.lastMessageId = lastMessages[0].id
        }
    }
    
    public init(id: String?, name: String?, avatar: String?, createdAt: Double?, updatedAt: Double?, type: Int?, lastMessageId: String?, customData: String?) {
        if let id = id {
            self.id = id
        }
        if let name = name {
            self.name = name
        }
        if let avatar = avatar {
            self.avatar = avatar
        }
        if let createdAt = createdAt {
            self.createdAt = Date.init(timeIntervalSince1970: createdAt)
        }
        if let updatedAt = updatedAt {
            self.updatedAt = Date.init(timeIntervalSince1970: updatedAt)
        }
        if let type = type {
            self.type = type
        }
        if let customData = customData {
            self.customData = customData
        }
        if let lastMessageId = lastMessageId {
            self.lastMessageId = lastMessageId
        }
    }
    
    public init(id: String, lastMessageId: String, updatedAt: Date) {
        self.id = id
        self.lastMessageId = lastMessageId
        self.updatedAt = updatedAt
    }
}
