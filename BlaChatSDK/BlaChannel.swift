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
    public var type: BlaChannelType?
    public var customData: [String: Any]?
    public var lastMessage: BlaMessage?
    public var lastMessageId: String?
    public var numberMessageUnread: String = "0"
    
    public init(dao: BlaChannelDAO) {
        self.id = dao.id
        self.name = dao.name
        self.avatar = dao.avatar
        self.createdAt = dao.createdAt
        self.updatedAt = dao.updatedAt
        if let customData =  dao.customData, let data = customData.data(using: .utf8) {
            do {
                self.customData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                self.customData = [String: Any]()
            }
        } else {
            self.customData = [String: Any]()
        }
        self.type = BlaChannelType.init(rawValue: dao.type ?? 0)
        if let lastMessages = dao.lastMessages, lastMessages.count > 0 {
            self.lastMessage = BlaMessage(dao: lastMessages[0])
            self.lastMessageId = lastMessages[0].id
        }
    }
    
    public init(json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.avatar = json["avatar"].stringValue
        self.createdAt = Date.init(timeIntervalSince1970: json["createdAt"].doubleValue)
        self.updatedAt = Date.init(timeIntervalSince1970: json["updatedAt"].doubleValue)
        self.type = BlaChannelType.init(rawValue: json["type"].intValue)
        if let data = json["customData"].stringValue.data(using: .utf8) {
            do {
                self.customData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                self.customData = [String: Any]()
            }
        } else {
            self.customData = [String: Any]()
        }
        self.lastMessage = BlaMessage.init(json: json["lastMessage"])
        self.lastMessageId = json["id"].stringValue
        self.numberMessageUnread = json["id"].stringValue
    }
     
    public init(id: String?, name: String?, avatar: String?, createdAt: Double?, updatedAt: Double?, type: Int?, lastMessageId: String?, customData: String?, number_message_unread: Int?) {
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
            self.type = BlaChannelType.init(rawValue: type)
        }
        if let customData = customData, let data = customData.data(using: .utf8) {
            do {
                self.customData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                self.customData = [String: Any]()
            }
        }
        if let lastMessageId = lastMessageId {
            self.lastMessageId = lastMessageId
        }
        if let numberMessageUnread = number_message_unread {
            if numberMessageUnread >= 20 {
                self.numberMessageUnread = "20+"
            } else {
                self.numberMessageUnread = "\(numberMessageUnread)"
            }
        }
    }
    
    required public init(from decoder: Decoder) throws {
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StaticCodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.avatar, forKey: .avatar)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.updatedAt, forKey: .updatedAt)
        try container.encode(self.type!.rawValue, forKey: .type)
        try encodeCustomdata(to: container.superEncoder(forKey: .customData))
        try container.encode(self.lastMessage, forKey: .lastMessage)
        try container.encode(self.lastMessageId, forKey: .lastMessageId)
        try container.encode(self.numberMessageUnread, forKey: .numberMessageUnread)
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
        case id, name, avatar, createdAt, updatedAt, type, customData, lastMessage, lastMessageId, numberMessageUnread
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
