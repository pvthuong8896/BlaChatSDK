//
//  Message.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public class BlaMessage: NSObject {
    public var id: String?
    public var authorId: String?
    public var channelId: String?
    public var content: String?
    public var type: Int?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var sentAt: Date?
    public var customData: String?
    public var author: BlaUser?
    public var receivedBy = [BlaUser]()
    public var seenBy = [BlaUser]()
    
    init(dao: BlaMessageDAO) {
        self.id = dao.id
        self.authorId = dao.authorId
        self.channelId = dao.channelId
        self.content = dao.content
        self.type = dao.type
        self.customData = dao.customData
        self.createdAt = dao.createdAt
        self.sentAt = dao.sentAt
    }
    
    public init(id: String?, author_id: String?, channel_id: String?, content: String?, type: Int?, created_at: Double?, updated_at: Double?, sent_at: Double?, custom_data: String?) {
        if let id = id {
            self.id = id
        }
        if let author_id = author_id {
            self.authorId = author_id
        }
        if let channel_id = channel_id {
            self.channelId = channel_id
        }
        if let content = content {
            self.content = content
        }
        if let type = type {
            self.type = type
        }
        if let created_at = created_at {
            self.createdAt = Date.init(timeIntervalSince1970: created_at)
        }
        if let updated_at = updated_at {
            self.updatedAt = Date.init(timeIntervalSince1970: updated_at)
        }
        if let sent_at = sent_at {
            self.sentAt = Date.init(timeIntervalSince1970: sent_at)
        }
        if let custom_data = custom_data {
            self.customData = custom_data
        }
    }
    
    public init(id: String, content: String) {
        self.id = id
        self.content = content
    }
}
