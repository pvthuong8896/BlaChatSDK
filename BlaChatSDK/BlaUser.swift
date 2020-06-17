//
//  BlaUser.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public class BlaUser: Codable {
    public var id: String?
    public var name: String?
    public var avatar: String?
    public var lastActiveAt: Date?
    public var customData: [String: Any]?
    public var online = false
    
    public init(id: String?, name: String?, avatar: String?, lastActiveAt: Double?, customData: String?) {
        self.id = id
        self.name = name
        self.avatar = avatar
        if let lastActive = lastActiveAt {
            self.lastActiveAt = Date.init(timeIntervalSince1970: lastActive)
        }
        if let customData = customData, let data = customData.data(using: .utf8) {
            do {
                self.customData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                self.customData = [String: Any]()
            }
        }
    }
    
    public init(dao: BlaUserDAO) {
        self.id = dao.id
        self.name = dao.name
        self.avatar = dao.avatar
        if let customData = dao.customData, let data = customData.data(using: .utf8) {
            do {
                self.customData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                self.customData = [String: Any]()
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
        try container.encode(self.lastActiveAt, forKey: .lastActiveAt)
        try encodeCustomdata(to: container.superEncoder(forKey: .customData))
        try container.encode(self.online, forKey: .online)
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
        case id, name, avatar, lastActiveAt, customData, online
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

