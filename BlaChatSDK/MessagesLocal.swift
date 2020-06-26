//
//  Message.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SQLite

class MessagesLocal: NSObject {
    
    static var shareInstance: MessagesLocal = {
        let instance = MessagesLocal()
        return instance
    }()
    
    private let tblMessage = Table("tblMessage")
    
    private let id = Expression<String?>("id")
    private let author_id = Expression<String?>("author_id")
    private let channel_id = Expression<String?>("channel_id")
    private let is_system_message = Expression<Bool?>("is_system_message")
    private let content = Expression<String?>("content")
    private let type = Expression<Int?>("type")
    private let created_at = Expression<Double?>("created_at")
    private let updated_at = Expression<Double?>("updated_at")
    private let sent_at = Expression<Double?>("sent_at")
    private let custom_data = Expression<String?>("custom_data")
    private let last_message_id = Expression<String?>("last_message_id")
    
    override init() {
        super.init()
        self.createTable()
    }
    
    func createTable() {
        do {
            if let connection = DbConnection.shareInstance.connection {
                try connection.run(self.tblMessage.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                    table.column(self.id)
                    table.column(self.author_id)
                    table.column(self.channel_id)
                    table.column(self.content)
                    table.column(self.type)
                    table.column(self.is_system_message)
                    table.column(self.created_at)
                    table.column(self.updated_at)
                    table.column(self.sent_at)
                    table.column(self.custom_data)
                }))
                try connection.run(self.tblMessage.createIndex(self.created_at, ifNotExists: true))
                print("Create table tblMesage success")
            }
        } catch {
            print("Create table tblMesage fail ", error)
        }
    }
    
    func getAllMessageNotSent(completion: @escaping([BlaMessage]?, Error?) -> Void) {
        do {
            let filter = tblMessage.filter(self.sent_at == nil)
            let messsages = try DbConnection.shareInstance.connection?.prepare(filter.order(self.created_at.desc))
            var listMessages = [BlaMessage]()
            if let sequence: AnySequence<Row> = messsages {
                for row in sequence {
                    listMessages.append(BlaMessage(id: row[self.id], author_id: row[self.author_id], channel_id: row[self.channel_id], content: row[self.content], type: row[self.type], is_system_message: row[self.is_system_message], created_at: row[self.created_at], updated_at: row[self.updated_at], sent_at: row[self.sent_at], custom_data: row[self.custom_data]))
                }
            }
            completion(listMessages, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func insertMessage(id: String?, author_id: String?, channel_id: String?, content: String?, type: Int?, created_at: Date?, updated_at: Date?, sent_at: Date?, custom_data: [String: Any]?, isSystemMessage: Bool?, completion: @escaping(Bool?, Error?) -> Void) {
        do {
            var customDataString = ""
            if let theJSONData = try?  JSONSerialization.data(
                withJSONObject: custom_data ?? [String: Any](),
                options: []
                ),
                let jsonString = String(data: theJSONData,
                                        encoding: String.Encoding.utf8) {
                customDataString = jsonString
            }
            let insert = tblMessage.insert(
                self.id <- id,
                self.author_id <- author_id,
                self.channel_id <- channel_id,
                self.content <- content,
                self.type <- type,
                self.created_at <- created_at?.timeIntervalSince1970,
                self.updated_at <- updated_at?.timeIntervalSince1970,
                self.sent_at <- sent_at?.timeIntervalSince1970,
                self.custom_data <- customDataString,
                self.is_system_message <- isSystemMessage
            )
            try DbConnection.shareInstance.connection?.run(insert)
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
    
    func replaceMessage(idLocal: String, message: BlaMessage, completion: @escaping(BlaMessage?, Error?) -> Void) {
        do {
            try DbConnection.shareInstance.connection?.transaction {
                let filter = tblMessage.filter(self.id == idLocal)
                let resultFilter = try DbConnection.shareInstance.connection?.pluck(filter)
                if let _ = resultFilter {
                    let messageFilter = tblMessage.filter(self.id == idLocal)
                    var customData = ""
                    if let theJSONData = try?  JSONSerialization.data(
                        withJSONObject: message.customData ?? [String: Any](),
                        options: .prettyPrinted
                        ),
                        let theJSONText = String(data: theJSONData,
                                                 encoding: String.Encoding.utf8) {
                        customData = theJSONText
                    }
                    let update = messageFilter.update(
                        self.id <- message.id,
                        self.author_id <- message.authorId,
                        self.channel_id <- message.channelId,
                        self.content <- message.content,
                        self.type <- message.type?.rawValue ?? 0,
                        self.created_at <- message.createdAt?.timeIntervalSince1970,
                        self.updated_at <- message.updatedAt?.timeIntervalSince1970,
                        self.sent_at <- message.sentAt?.timeIntervalSince1970,
                        self.custom_data <- customData
                    )
                    try DbConnection.shareInstance.connection?.run(update)
                }
            }
        } catch {
            completion(nil, error)
        }
    }
    
    func getMessages(channel_id: String, limit: Int, lastId: String?, completion: @escaping([BlaMessage]?, Error?) -> Void) {
        do {
            var filter = tblMessage.filter(self.channel_id == channel_id).order(self.created_at.desc)
            if let lastId = lastId {
                let rowLastMessage = try DbConnection.shareInstance.connection?.pluck(tblMessage.filter(self.id == lastId))
                if let rowLastMessage = rowLastMessage, let rowCreatedAt = rowLastMessage[self.created_at] {
                    filter = filter.filter(self.created_at < rowCreatedAt)
                }
            }
            let messsages = try DbConnection.shareInstance.connection?.prepare(filter.limit(limit, offset: 0).order(self.created_at.desc))
            var listMessages = [BlaMessage]()
            if let sequence: AnySequence<Row> = messsages {
                for row in sequence {
                    listMessages.append(BlaMessage(id: row[self.id], author_id: row[self.author_id], channel_id: row[self.channel_id], content: row[self.content], type: row[self.type], is_system_message: row[self.is_system_message], created_at: row[self.created_at], updated_at: row[self.updated_at], sent_at: row[self.sent_at], custom_data: row[self.custom_data]))
                }
            }
            completion(listMessages, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func getMessageById(messageId: String, completion: @escaping(BlaMessage?, Error?) -> Void) {
        do {
            let filter = tblMessage.filter(self.id == messageId)
            let result = try DbConnection.shareInstance.connection?.pluck(filter)
            if let row = result {
                let message = BlaMessage(id: row[self.id], author_id: row[self.author_id], channel_id: row[self.channel_id], content: row[self.content], type: row[self.type], is_system_message: row[self.is_system_message], created_at: row[self.created_at], updated_at: row[self.updated_at], sent_at: row[self.sent_at], custom_data: row[self.custom_data])
                completion(message, nil)
            }
        } catch {
            print("Get Messages error ", error)
            completion(nil, error)
        }
    }
    
    func getLastestMessage(channelId: String, completion: @escaping(BlaMessage?, Error?) -> Void) {
        do {
            let filter = tblMessage.filter(self.channel_id == channelId)
            let result = try DbConnection.shareInstance.connection?.pluck(filter)
            if let row = result {
                let message = BlaMessage(id: row[self.id], author_id: row[self.author_id], channel_id: row[self.channel_id], content: row[self.content], type: row[self.type], is_system_message: row[self.is_system_message], created_at: row[self.created_at], updated_at: row[self.updated_at], sent_at: row[self.sent_at], custom_data: row[self.custom_data])
                completion(message, nil)
            }
        } catch {
            completion(nil, error)
        }
    }
    
    func updateMessage(message: BlaMessage, completion: @escaping(BlaMessage?, Error?) -> Void) {
        do {
            let mesageFilter = self.tblMessage
                .filter(self.id == message.id!)
            var setter:[SQLite.Setter] = [SQLite.Setter]()
            if let author_id = message.authorId {
                setter.append(self.author_id <- author_id)
            }
            if let channel_id = message.channelId {
                setter.append(self.channel_id <- channel_id)
            }
            if let content = message.content {
                setter.append(self.content <- content)
            }
            if let type = message.type?.rawValue {
                setter.append(self.type <- type)
            }
            setter.append(self.updated_at <- Date().timeIntervalSince1970)
            if let sent_at = message.sentAt {
                setter.append(self.sent_at <- sent_at.timeIntervalSince1970)
            }
            if let theJSONData = try?  JSONSerialization.data(
                withJSONObject: message.customData ?? [String: Any](),
                options: .prettyPrinted
                ),
                let customData = String(data: theJSONData,
                                        encoding: String.Encoding.utf8) {
                setter.append(self.custom_data <- customData)
            }
            let update = mesageFilter.update(setter)
            
            try DbConnection.shareInstance.connection?.run(update)
        } catch {
            
        }
    }
    
    func saveMessage(message: BlaMessage) {
        do {
            let filter = tblMessage.filter(self.id == message.id!)
            let resultFilter = try DbConnection.shareInstance.connection?.pluck(filter)
            if let _ = resultFilter {
                self.updateMessage(message: message) { (result, error) in
                }
            } else {
                self.insertMessage(id: message.id, author_id: message.authorId, channel_id: message.channelId, content: message.content, type: message.type?.rawValue ?? 0, created_at: message.createdAt, updated_at: message.updatedAt, sent_at: message.sentAt, custom_data: message.customData, isSystemMessage: message.isSystemMessage) { (message, error) in
                }
            }
        } catch {
        }
    }
    
    func removeMessage(messageId: String) {
        do {
            let filter = tblMessage.filter(self.id == messageId).delete()
            try DbConnection.shareInstance.connection?.run(filter)
        } catch {
            print("remove message error")
        }
    }
    
    func removeAllMessage() {
        do {
            let filter = tblMessage.delete()
            try DbConnection.shareInstance.connection?.run(filter)
        } catch {
            print("remove message error")
        }
    }
}
