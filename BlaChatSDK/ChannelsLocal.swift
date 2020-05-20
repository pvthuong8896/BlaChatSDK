//
//  Channel.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SQLite

class ChannelsLocal: NSObject {
    
    static var shareInstance: ChannelsLocal = {
        let instance = ChannelsLocal()
        return instance
    }()
    
    private let tblChannel = Table("tblChannel")
    private let id = Expression<String?>("id")
    private let name = Expression<String?>("name")
    private let avatar = Expression<String?>("avatar")
    private let created_at = Expression<Double?>("created_at")
    private let updated_at = Expression<Double?>("updated_at")
    private let type = Expression<Int?>("type")
    private let last_message_id = Expression<String?>("last_message_id")
    private let custom_data = Expression<String?>("custom_data")
    
    //Message
    let tblMessage = Table("tblMessage")
    
    private let author_id = Expression<String?>("author_id")
    private let channel_id = Expression<String?>("channel_id")
    private let content = Expression<String?>("content")
    private let sent_at = Expression<Double?>("sent_at")
    
    override init() {
        super.init()
        createTable()
    }
    
    func createTable() {
        do {
            if let connection = DbConnection.shareInstance.connection {
                try connection.run(self.tblChannel.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                    table.column(self.id)
                    table.column(self.name)
                    table.column(self.avatar)
                    table.column(self.created_at)
                    table.column(self.updated_at)
                    table.column(self.type)
                    table.column(self.last_message_id)
                    table.column(self.custom_data)
                }))
                try connection.run(self.tblChannel.createIndex(self.updated_at))
                print("Create table tblChannel success")
            }
        } catch {
            print("Create table tblChannel fail ", error)
        }
    }

    func insertChannel(id: String?, name: String?, avatar: String?, created_at: Date?, updated_at: Date?, type: Int?, last_message_id: String?, customData: String?, completion: @escaping(BlaChannel?, Error?) -> Void) {
        do {
            let insert = tblChannel.insert(
                self.id <- id,
                self.name <- name,
                self.avatar <- avatar,
                self.created_at <- created_at?.timeIntervalSince1970,
                self.updated_at <- updated_at?.timeIntervalSince1970,
                self.type <- type,
                self.last_message_id <- last_message_id,
                self.custom_data <- customData
            )
            let channel = try DbConnection.shareInstance.connection?.run(insert)
            print("Insert channel success", channel)
        } catch {
            print("insert channel error ", error)
        }
    }
    
    func getChannel(limit: Int, lastId: String?, completion: @escaping([BlaChannel]?, Error?) -> Void) {
        do {
            var filter = tblChannel.limit(limit)
            if let lastId = lastId {
                let rowLastChannel = try DbConnection.shareInstance.connection?.pluck(tblChannel.filter(self.id == lastId))
                if let rowLastChannel = rowLastChannel, let rowUpdatedAt = rowLastChannel[self.updated_at] {
                    filter = tblChannel.limit(limit).filter(tblChannel[updated_at] < rowUpdatedAt)
                }
            }
            let channels = try
                DbConnection.shareInstance.connection?.prepare(filter
                    .join(.leftOuter, tblMessage, on: tblMessage[id]==tblChannel[last_message_id])
            )
            var listChannel = [BlaChannel]()
            if let sequence: AnySequence<Row> = channels {
                for row in sequence {
                    // Row for channel
                    let channelId = try row.get(tblChannel[id])
                    let channelName = try row.get(tblChannel[name])
                    let channelAvatar = try row.get(tblChannel[avatar])
                    let channelCreatedAt = try row.get(tblChannel[created_at])
                    let channelUpdatedAt = try row.get(tblChannel[updated_at])
                    let channelType = try row.get(tblChannel[type])
                    let channelLastMessageId = try row.get(tblChannel[last_message_id])
                    let channelCustomData = try row.get(tblChannel[custom_data])
                    
                    let messageId = try row.get(tblMessage[id])
                    
                    let channel = BlaChannel(id: channelId, name: channelName, avatar: channelAvatar, createdAt: channelCreatedAt, updatedAt: channelUpdatedAt, type: channelType, lastMessageId: channelLastMessageId, customData: channelCustomData)
                    if messageId != nil {
                        // Row for lastMessage
                        let messageId = try row.get(tblMessage[id])
                        let messageAuthorId = try row.get(tblMessage[author_id])
                        let messageChannelId = try row.get(tblMessage[channel_id])
                        let messageContent = try row.get(tblMessage[content])
                        let messageType = try row.get(tblMessage[type])
                        let messageCreatedAt = try row.get(tblMessage[created_at])
                        let messageUpdatedAt = try row.get(tblMessage[updated_at])
                        let messageSentAt = try row.get(tblMessage[sent_at])
                        let messageCustomData = try row.get(tblMessage[custom_data])
                        
                        let message = BlaMessage(id: messageId, author_id: messageAuthorId, channel_id: messageChannelId, content: messageContent, type: messageType, created_at: messageCreatedAt, updated_at: messageUpdatedAt, sent_at: messageSentAt, custom_data: messageCustomData)
                        
                        channel.lastMessage = message
                    }
                    listChannel.append(channel)
                }
            }
            completion(listChannel, nil)
        } catch {
            print("run get channel error ", error)
            completion(nil, error)
        }
    }
    
    func getChannelById(channelId: String, completion: @escaping(BlaChannel?, Error?) -> Void) {
        do {
            let row = try
                DbConnection.shareInstance.connection?.pluck(tblChannel
                    .filter(tblChannel[id] == channelId)
                    .join(.leftOuter, tblMessage, on: tblMessage[id]==tblChannel[last_message_id])
            )
            // Row for channel
            if let row = row {
                let channelId = row[tblChannel[id]]
                let channelName = row[tblChannel[name]]
                let channelAvatar = try row.get(tblChannel[avatar])
                let channelCreatedAt = try row.get(tblChannel[created_at])
                let channelUpdatedAt = try row.get(tblChannel[updated_at])
                let channelType = try row.get(tblChannel[type])
                let channelLastMessageId = try row.get(tblChannel[last_message_id])
                let channelCustomData = try row.get(tblChannel[custom_data])

                let messageId = try row.get(tblMessage[id])

                let channel = BlaChannel(id: channelId, name: channelName, avatar: channelAvatar, createdAt: channelCreatedAt, updatedAt: channelUpdatedAt, type: channelType, lastMessageId: channelLastMessageId, customData: channelCustomData)
                if messageId != nil {
                    // Row for lastMessage
                    let messageId = try row.get(tblMessage[id])
                    let messageAuthorId = try row.get(tblMessage[author_id])
                    let messageChannelId = try row.get(tblMessage[channel_id])
                    let messageContent = try row.get(tblMessage[content])
                    let messageType = try row.get(tblMessage[type])
                    let messageCreatedAt = try row.get(tblMessage[created_at])
                    let messageUpdatedAt = try row.get(tblMessage[updated_at])
                    let messageSentAt = try row.get(tblMessage[sent_at])
                    let messageCustomData = try row.get(tblMessage[custom_data])

                    let message = BlaMessage(id: messageId, author_id: messageAuthorId, channel_id: messageChannelId, content: messageContent, type: messageType, created_at: messageCreatedAt, updated_at: messageUpdatedAt, sent_at: messageSentAt, custom_data: messageCustomData)

                    channel.lastMessage = message
                    completion(channel, nil)
                }
            }
        } catch {
            print("run get channel error ", error)
            completion(nil, error)
        }
    }
    
    func updateChannel(channel: BlaChannel) {
        do {
            let channelFilter = self.tblChannel.filter(self.id == channel.id!)
            var setter:[SQLite.Setter] = [SQLite.Setter]()
            if let name = channel.name {
                setter.append(self.name <- name)
            }
            if let avatar = channel.avatar {
                setter.append(self.avatar <- avatar)
            }
            setter.append(self.updated_at <- Date().timeIntervalSince1970)
            if let type = channel.type {
                setter.append(self.type <- type)
            }
            if let last_message_id = channel.lastMessageId {
                setter.append(self.last_message_id <- last_message_id)
            }
            if let custom_data = channel.customData {
                setter.append(self.custom_data <- custom_data)
            }
            let update = channelFilter.update(setter)
            
            let result = try DbConnection.shareInstance.connection?.run(update)
            print("Update channel success ", result)
        } catch {
            print("Update channel error ", error)
        }
    }
    
    func updateLastMessageChannel(channel: BlaChannel, completion: @escaping(BlaChannel?, Error?) -> Void) {
        do {
            let channelFilter = self.tblChannel.filter(self.id == channel.id!)
            var setter:[SQLite.Setter] = [SQLite.Setter]()
            setter.append(self.updated_at <- Date().timeIntervalSince1970)
            if let last_message_id = channel.lastMessageId {
                setter.append(self.last_message_id <- last_message_id)
            }
            setter.append(self.updated_at <- Date().timeIntervalSince1970)
            let update = channelFilter.update(setter)
            
            try DbConnection.shareInstance.connection?.run(update)
            self.getChannelById(channelId: channel.id!) { (channel, error) in
                completion(channel, error)
            }
        } catch {
            print("Update channel error ", error)
        }
    }
    
    func saveChannel(channel: BlaChannel) {
        do {
            try DbConnection.shareInstance.connection?.transaction {
                let channelFilter = self.tblChannel.filter(self.id == channel.id!)
                let resultFilter = try DbConnection.shareInstance.connection?.pluck(channelFilter)
                if let _ = resultFilter {
                    print("run update channel ", channel)
                    self.updateChannel(channel: channel)
                } else {
                    print("run insert channel ")
                    self.insertChannel(id: channel.id, name: channel.name, avatar: channel.avatar, created_at: channel.createdAt, updated_at: channel.updatedAt, type: channel.type, last_message_id: channel.lastMessageId, customData: channel.customData) { (channel, error) in
                    }
                }
            }
        } catch {
            print("Error to save channel")
        }
    }
    
    func removeChannel(channelId: String) {
        do {
            let filter = self.tblChannel.filter(self.id == channelId).delete()
            try DbConnection.shareInstance.connection?.run(filter)
        } catch {
            print("Error to delete channel")
        }
    }
}
