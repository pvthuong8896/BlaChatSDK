//
//  MessageModels.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit

class MessageModels: NSObject {
    var messageLocal = MessagesLocal()
    var messageRemote = MessagesRemote()
    var channelLocal = ChannelsLocal()
    
    func sendMessage(channelId: String, type: Int, message: String, completion: @escaping(BlaMessage?, Error?) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")
        let tmpId = UUID().uuidString
        messageLocal.insertMessage(id: tmpId, author_id: userId, channel_id: channelId, content: message, type: type, created_at: Date(), updated_at: Date(), sent_at: nil, custom_data: nil) { (messLocal, error) in
            if let err = error {
                completion(nil, err)
            } else {
                self.channelLocal.updateLastMessageChannel(channel: BlaChannel(id: channelId, lastMessageId: tmpId, updatedAt: Date())) { (channel, error) in
                }
                let sentAt = Date().timeIntervalSince1970
                self.messageRemote.sendMessage(channelId: channelId, message: message, sentAt: sentAt) { (json, error) in
                    if let err = error {
                        completion(BlaMessage(id: tmpId, author_id: userId, channel_id: channelId, content: message, type: type, created_at: sentAt, updated_at: sentAt, sent_at: nil, custom_data: nil), err)
                    }
                    if let json = json {
                        let dao = BlaMessageDAO(json: json["data"])
                        let mess = BlaMessage(dao: dao)
                        self.messageLocal.replaceMessage(idLocal: tmpId, message: mess) { (message, error) in
                        }
                        self.channelLocal.updateLastMessageChannel(channel: BlaChannel(id: channelId, lastMessageId: mess.id!, updatedAt: Date())) { (result, error) in
                        }
                        completion(mess, error)
                    }
                }
            }
        }
    }
    
    func syncMessage(message: BlaMessage, completion: @escaping(BlaMessage?, Error?) -> Void) {
        self.messageRemote.sendMessage(channelId: message.channelId!, message: message.content!, sentAt: message.createdAt?.timeIntervalSince1970 ?? Date().timeIntervalSince1970) { (json, error) in
            if let err = error {
                completion(nil, err)
            }
            if let json = json {
                let dao = BlaMessageDAO(json: json["data"])
                let mess = BlaMessage(dao: dao)
                self.messageLocal.replaceMessage(idLocal: message.id!, message: mess) { (message, error) in
                }
                self.channelLocal.updateChannel(channel: BlaChannel(id: mess.channelId!, lastMessageId: mess.id!, updatedAt: Date()))
                completion(mess, error)
            }
        }
    }
    
    func replaceMessage(idLocal: String, message: BlaMessage) {
        self.messageLocal.replaceMessage(idLocal: idLocal, message: message) { (message, error) in
        }
    }
    
    func getMessage(channelId: String, lastId: String?, limit: Int, completion: @escaping([BlaMessage]?, Error?) -> Void) {
        self.messageLocal.getMessages(channel_id: channelId, limit: limit, lastId: lastId) { (messages, error) in
            var listMessageResult = [BlaMessage]()
            if let messages = messages {
                listMessageResult = messages
                completion(listMessageResult, error)
            } else {
                self.messageRemote.getMessages(channelId: channelId, lastId: lastId) { (json, error) in
                    if let json = json {
                        for subJson in json["data"].arrayValue {
                            let dao = BlaMessageDAO(json: subJson)
                            let mess = BlaMessage(dao: dao)
                            self.messageLocal.saveMessage(message: mess)
                            listMessageResult.append(mess)
                        }
                        completion(listMessageResult, nil)
                    } else {
                        completion(listMessageResult, error)
                    }
                }
            }
        }
    }
    
    func getMessageById(messageId: String, completion: @escaping (BlaMessage?, Error?) -> Void) {
        self.messageLocal.getMessageById(messageId: messageId) { (message, error) in
            completion(message, error)
        }
    }
    
    func getMessageNotSent(completion: @escaping([BlaMessage]?, Error?) -> Void) {
        self.messageLocal.getAllMessageNotSent { (messages, error) in
            completion(messages, error)
        }
    }
    
    func saveMessage(message: BlaMessage) {
        messageLocal.saveMessage(message: message)
    }
    
    func markReceiveMessage(channelId: String, messageId: String, receiveId: String, completion: @escaping(Bool?, Error?) -> Void) {
        messageRemote.markReceiveMessage(channelId: channelId, messageId: messageId, receiveId: receiveId) { (json, error) in
            if let err = error {
                completion(false, err)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func markSeenMessage(channelId: String, messageId: String, receiveId: String, completion: @escaping(Bool?, Error?) -> Void) {
        messageRemote.markSeenMessage(channelId: channelId, messageId: messageId, receiveId: receiveId) { (json, error) in
            if let err = error {
                completion(false, err)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func updateMessage(channelId: String, messageId: String, content: String, completion: @escaping (Bool?, Error?) -> Void) {
        self.messageRemote.updateMessage(messageId: messageId, channelId: channelId, content: content) { (json, error) in
            if let err = error {
                completion(nil, err)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func deleteMessage(channelId: String, messageId: String, completion: @escaping (Bool?, Error?) -> Void) {
        self.messageRemote.deleteMessage(channelId: channelId, messageId: messageId) { (json, error) in
            if let err = error {
                completion(nil, err)
            } else {
                self.messageLocal.removeMessage(messageId: messageId)
                completion(true, nil)
            }
        }
    }
    
    func deleteMessageLocal(messageId: String) {
        self.messageLocal.removeMessage(messageId: messageId)
    }
}