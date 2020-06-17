//
//  Message.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public class BlaMessage: Codable {
    public var id: String?
    public var authorId: String?
    public var channelId: String?
    public var content: String?
    public var type: BlaMessageType?
    public var isSystemMessage: Bool?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var sentAt: Date?
    public var customData: [String: Any]?
    public var author: BlaUser?
    public var receivedBy = [BlaUser]()
    public var seenBy = [BlaUser]()
    
    public init(dao: BlaMessageDAO) {
        self.id = dao.id
        self.authorId = dao.authorId
        self.channelId = dao.channelId
        self.content = dao.content
        self.isSystemMessage = dao.isSystemMessage
        self.type = BlaMessageType.init(rawValue: dao.type ?? 0)
        if let customData = dao.customData, let data = customData.data(using: .utf8) {
            do {
                self.customData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                self.customData = [String: Any]()
            }
        }

        self.createdAt = dao.createdAt
        self.sentAt = dao.sentAt
    }
    
    public init(id: String?, author_id: String?, channel_id: String?, content: String?, type: Int?, is_system_message: Bool?, created_at: Double?, updated_at: Double?, sent_at: Double?, custom_data: String?) {
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
            self.type = BlaMessageType.init(rawValue: type)
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
        if let customData = custom_data, let data = customData.data(using: .utf8) {
            do {
                self.customData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                self.customData = [String: Any]()
            }
        }
        if let isSystemMessage = is_system_message {
            self.isSystemMessage = isSystemMessage
        }
    }
    
    public init(id: String, content: String) {
        self.id = id
        self.content = content
    }
    
    required public init(from decoder: Decoder) throws {
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StaticCodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.authorId, forKey: .authorId)
        try container.encode(self.channelId, forKey: .channelId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.type?.rawValue ?? 0, forKey: .type)
        try container.encode(isSystemMessage, forKey: .isSystemMessage)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.updatedAt, forKey: .updatedAt)
        try container.encode(self.sentAt, forKey: .sentAt)
        try encodeCustomdata(to: container.superEncoder(forKey: .customData))
        try container.encode(self.author, forKey: .author)
        try container.encode(self.receivedBy, forKey: .receivedBy)
        try container.encode(self.seenBy, forKey: .seenBy)
    }
    
    static func decodeCustomdata(from decoder: Decoder) throws -> [String: Any] {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var result: [String: Any] = [:]
        for key in container.allKeys {
            if let double = try? container.decode(Double.self, forKey: key) {
                result[key.stringValue] = double
            } else if let string = try? container.decode(String.self, forKey: key) {
                result[key.stringValue] = string
            }
        }
        return result
    }
    
    func encodeCustomdata(to encoder: Encoder) throws {
        if let customData = customData {
            var container = encoder.container(keyedBy: DynamicCodingKeys.self)
            for (key, value) in customData {
                switch value {
                case let double as Double:
                    try container.encode(double, forKey: DynamicCodingKeys(stringValue: key)!)
                case let string as String:
                    try container.encode(string, forKey: DynamicCodingKeys(stringValue: key)!)
                default:
                    fatalError("unexpected type")
                }
            }
        }
    }
    
    private enum StaticCodingKeys: String, CodingKey {
        case id, authorId, channelId, content, type, isSystemMessage, createdAt, updatedAt, sentAt, customData, author, receivedBy, seenBy
    }
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        
        init?(intValue: Int) {
            self.init(stringValue: "")
            self.intValue = intValue
        }
    }
}
