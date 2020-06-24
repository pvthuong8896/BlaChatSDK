
//
//  ChatSDKController.swift
//  ChatSDK
//
//  Created by Os on 4/1/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

public protocol BlaMessageDelegate: NSObjectProtocol {
    func onNewMessage(message: BlaMessage)
    func onUpdateMessage(message: BlaMessage)
    func onDeleteMessage(messageId: String)
    func onUserSeen(message: BlaMessage, user: BlaUser, seenAt: Date)
    func onUserReceive(message: BlaMessage, user: BlaUser, receivedAt: Date)
}

public protocol BlaChannelDelegate: NSObjectProtocol {
    func onNewChannel(channel: BlaChannel)
    func onUpdateChannel(channel: BlaChannel)
    func onDeleteChannel(channelId: String)
    func onTyping(channel: BlaChannel, user: BlaUser, type: BlaEventType)
    func onMemberJoin(channel: BlaChannel, user: BlaUser)
    func onMemberLeave(channel: BlaChannel, user: BlaUser)
}

public protocol BlaPresenceListener: NSObjectProtocol {
    func onUpdate(userPresence: [BlaUser])
}

public class ChatSDK: NSObject {
    private var channelModels: ChannelModels?
    private var messageModels: MessageModels?
    private var userModels: UserModels?
    private var client: CentrifugeClient?
    private var sub: CentrifugeSubscription?
    private var isConnected: Bool = false
    private var subscriptionCreated: Bool = false
    
    private var messageDelegates = [BlaMessageDelegate]()
    private var channelDelegates = [BlaChannelDelegate]()
    private var presenceDelegates = [BlaPresenceListener]()
    
    override init() {
        super.init()
    }
    
    public static var shareInstance: ChatSDK = {
        let instance = ChatSDK()
        return instance
    }()
    
    public func initBlaChatSDK(userId: String, token: String, completion: @escaping (Bool?, Error?) -> Void) {
        CacheRepository.shareInstance.userId = userId
        CacheRepository.shareInstance.token = token
        userModels = UserModels()
        channelModels = ChannelModels(userModel: userModels!)
        messageModels = MessageModels()
        CentrifugoController.shareInstance.delegate = self
        self.getAllUser()
        self.syncMessage()
        self.getMissingEvent()
    }
    
    private func getMissingEvent() {
        if let lastEventId = UserDefaults.standard.string(forKey: "lastEventId") {
            self.channelModels!.getMissingEvent(lastEventId: lastEventId) { (json, error) in
                if let json = json {
                    if json["data"].arrayValue.count > Constants.numberEventResetDatabase {
                        self.removeAllDoucumentLocal()
                    } else {
                        for item in json["data"].arrayValue {
                            UserDefaults.standard.setValue(json["id"].stringValue, forKey: "lastEventId")
                            let event = JSON.init(parseJSON: item["payload"].stringValue)
                            self.handleEvent(event: event)
                        }
                    }
                }
            }
        }
    }
    
    private func intervalSetOnline() {
        let timer = Timer.scheduledTimer(withTimeInterval: Constants.intervalSetOnlineTime, repeats: true) { (timer) in
            self.userModels!.setUserStatus(userId: CacheRepository.shareInstance.userId)
        }
        timer.fire()
        let timer2 = Timer.scheduledTimer(withTimeInterval: Constants.intervalGetPresenceTime, repeats: true) { (timer) in
            self.intervalGetStatusUser()
        }
        timer2.fire()
    }
    
    private func intervalGetStatusUser() {
        var userIds = [String]()
        for item in CacheRepository.shareInstance.validUsers {
            userIds.append(item.id!)
        }
        self.userModels!.getStatusUserByIds(userIds: userIds) { (result, error) in
            if let result = result {
                var userPresences = [BlaUser]()
                for (index,user) in CacheRepository.shareInstance.validUsers.enumerated() {
                    if let indexStatus = result.firstIndex(where: {$0.userId == user.id && $0.isOnline != user.online}) {
                        let userx = BlaUser(id: CacheRepository.shareInstance.validUsers[index].id, name: CacheRepository.shareInstance.validUsers[index].name, avatar: CacheRepository.shareInstance.validUsers[index].avatar, lastActiveAt: Date().timeIntervalSince1970, customData: nil)
                        CacheRepository.shareInstance.validUsers[index].online = result[indexStatus].isOnline
                        CacheRepository.shareInstance.validUsers[index].lastActiveAt = Date()
                        userPresences.append(userx)
                        self.userModels!.saveUser(user: CacheRepository.shareInstance.validUsers[index])
                    }
                }
                for delegate in self.presenceDelegates {
                    delegate.onUpdate(userPresence: userPresences)
                }
            }
        }
    }
    
    public func addMessageListener(delegate: BlaMessageDelegate) {
        self.messageDelegates.append(delegate)
    }
    
    public func addChannelListener(delegate: BlaChannelDelegate) {
        self.channelDelegates.append(delegate)
    }
    
    public func addPresenceListener(delegate: BlaPresenceListener) {
        self.presenceDelegates.append(delegate)
    }
    
    public func removeMessageListener(delegate: BlaMessageDelegate) {
        for (index, item) in self.messageDelegates.enumerated() {
            if (item as AnyObject === delegate as AnyObject) {
                self.messageDelegates.remove(at: index)
                break
            }
        }
    }
    
    public func removeChannelListener(delegate: BlaChannelDelegate) {
        for (index, item) in self.channelDelegates.enumerated() {
            if (item as AnyObject === delegate as AnyObject) {
                self.channelDelegates.remove(at: index)
                break
            }
        }
    }
    
    public func removePresenceListener(delegate: BlaPresenceListener) {
        for (index, item) in self.presenceDelegates.enumerated() {
            if (item as AnyObject === delegate as AnyObject) {
                self.presenceDelegates.remove(at: index)
                break
            }
        }
    }
    
    public func getChannels(lastId: String?, limit: Int, completion: @escaping ([BlaChannel]?, Error?) -> Void) {
        channelModels!.getChannel(lastId: lastId, limit: limit) { (channels, error) in
            if let channels = channels {
                self.handleChannel(channels: channels) { (result) in
                    completion(result, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    public func getUserInChannel(channelId: String, completion: @escaping ([BlaUser]?, Error?) -> Void) {
        self.channelModels!.getUserInChannel(channelId: channelId) { (users, error) in
            if let err = error {
                completion(nil, err)
            } else {
                var listUserId = [String]()
                for user in users! {
                    if listUserId.firstIndex(of: user.userId!) == nil {
                        listUserId.append(user.userId!)
                    }
                }
                self.userModels!.getUserByIds(ids: listUserId) { (users, error) in
                    completion(users, error)
                }
            }
        }
    }
    
    public func getUsers(userIds: [String], completion: @escaping ([BlaUser]?, Error?) -> Void) {
        self.userModels!.getUserByIds(ids: userIds) { (users, error) in
            completion(users, error)
        }
    }
    
    public func getMessages(channelId: String, lastId: String, limit: Int, completion: @escaping([BlaMessage]?, Error?) -> Void) {
        messageModels!.getMessage(channelId: channelId, lastId: lastId, limit: limit) { (messages, error) in
            if let err = error {
                completion(nil, err)
            } else {
                self.addInfoMessages(messages: messages ?? []) { (result) in
                    completion(result, error)
                }
            }
        }
    }
    
    public func createChannel(name: String, avatar: String, userIds: [String], type: BlaChannelType, customData: [String: Any], completion: @escaping (BlaChannel?, Error?) -> Void) {
        channelModels!.createChannel(name: name, avatar: avatar, userIds: userIds, type: type.rawValue, customData: customData) { (channel, error) in
            completion(channel, error)
        }
    }
    
    public func updateChannel(channel: BlaChannel, completion: @escaping (BlaChannel?, Error?) -> Void) {
        channelModels!.updateChannel(channelId: channel.id!, name: channel.name ?? "", avatar: channel.avatar ?? "") { (channel, error) in
            completion(channel, error)
        }
    }
    
    public func deleteChannel(channel: BlaChannel, completion: @escaping (BlaChannel?, Error?) -> Void) {
        channelModels!.deleteChannel(channelId: channel.id!) { (result, error) in
            if let err = error {
                completion(nil, err)
            } else {
                completion(channel, nil)
            }
        }
    }
    
    public func sendStartTyping(channelId: String, completion: @escaping(Bool?, Error?) -> Void) {
        channelModels!.sendTypingEvent(channelId: channelId) { (result, error) in
            completion(result, error)
        }
    }
    
    public func sendStopTyping(channelId: String, completion: @escaping(Bool?, Error?) -> Void) {
        channelModels!.sendStopTypingEvent(channelId: channelId) { (result, error) in
            completion(result, error)
        }
    }
    
    public func markReceiveMessage(messageId: String, channelId: String, completion: @escaping(Bool?, Error?) -> Void) {
        messageModels!.markReceiveMessage(channelId: channelId, messageId: messageId) { (result, error) in
            completion(result, error)
        }
    }
    
    public func markSeenMessage(messageId: String, channelId: String, completion: @escaping(Bool?, Error?) -> Void) {
        self.channelModels!.updateNumberMessageUnread(channelId: channelId, isResetCount: true) {(channel, error) in
            if let channel = channel {
                for delegate in self.channelDelegates {
                    delegate.onUpdateChannel(channel: channel)
                }
            }
        }
        messageModels!.markSeenMessage(channelId: channelId, messageId: messageId) { (result, error) in
            completion(result, error)
        }
    }
    
    public func createMessage(content: String, channelId: String, type: BlaMessageType, customData: [String : Any]?, completion: @escaping(BlaMessage?, Error?) -> Void) {
        messageModels!.sendMessage(channelId: channelId, type: type.rawValue, message: content, customData: customData) { (message, error) in
            if let message = message {
                self.addInfoMessages(messages: [message]) { (result) in
                    completion(result[0], nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    public func updateMessage(message: BlaMessage, completion: @escaping (BlaMessage?, Error?) -> Void) {
        self.messageModels!.updateMessage(channelId: message.channelId!, messageId: message.id!, content: message.content!) { (result, error) in
            if let err = error {
                completion(nil, err)
            } else {
                completion(message, nil)
            }
        }
    }
    
    public func deleteMessage(message: BlaMessage, completion: @escaping (BlaMessage?, Error?) -> Void) {
        self.messageModels!.deleteMessage(channelId: message.channelId!, messageId: message.id!) { (result, error) in
            if let err = error {
                completion(nil, err)
            } else {
                completion(message, nil)
            }
        }
    }
    
    public func inviteUserToChannel(userIds: [String], channelId: String, completion: @escaping(Bool?, Error?) -> Void) {
        self.channelModels!.inviteUserToChannel(channelId: channelId, userIds: userIds) { (result, error) in
            completion(result, error)
        }
    }
    
    public func removeUserFromChannel(userId: String, channelId: String, completion: @escaping(Bool?, Error?) -> Void) {
        self.channelModels!.removeUserFromChannel(channelId: channelId, userId: userId) { (result, error) in
            completion(result, error)
        }
    }
    
    public func searchChannels(query: String, completion: @escaping([BlaChannel]?, Error?) -> Void) {
        self.channelModels?.searchChannels(query: query, completion: { (channels, error) in
            completion(channels, error)
        })
    }
    
    public func getUserPresence(completion: @escaping([BlaUser]?, Error?) -> Void) {
        var userIds = [String]()
        for item in CacheRepository.shareInstance.validUsers {
            userIds.append(item.id!)
        }
        self.userModels!.getStatusUserByIds(userIds: userIds) { (result, error) in
            var userPresences = [BlaUser]()
            if let result = result {
                for (index,user) in CacheRepository.shareInstance.validUsers.enumerated() {
                    if let indexStatus = result.firstIndex(where: {$0.userId == user.id && $0.isOnline != user.online}) {
                        if result[indexStatus].isOnline {
                            CacheRepository.shareInstance.validUsers[index].online = true
                            userPresences.append(CacheRepository.shareInstance.validUsers[index])
                        } else {
                            CacheRepository.shareInstance.validUsers[index].online = false
                            userPresences.append(CacheRepository.shareInstance.validUsers[index])
                        }
                    } else {
                        CacheRepository.shareInstance.validUsers[index].online = false
                        userPresences.append(CacheRepository.shareInstance.validUsers[index])
                    }
                }
            }
            completion(userPresences, error)
        }
    }
    
    private func getAllUser() {
        userModels!.getAllUser { (users, error) in
            self.intervalSetOnline()
            self.intervalGetStatusUser()
        }
    }
    
    private func syncMessage() {
        self.messageModels!.getMessageNotSent { (messages, error) in
            if let messages = messages {
                for message in messages {
                    self.messageModels!.syncMessage(message: message) { (message, error) in
                    }
                }
            }
        }
    }
    
    private func removeAllDoucumentLocal() {
        self.channelModels?.removeAllChannel()
        self.messageModels?.removeAllmessage()
        self.userModels?.removeAllUser()
        UserDefaults.standard.setValue("", forKey: "lastEventId")
    }
    
    private func handleChannel(channels: [BlaChannel], completion: @escaping ([BlaChannel]) -> Void) {
        var channelIds = [String]()
        for item in channels {
            channelIds.append(item.id!)
        }
        self.channelModels!.getUserInMultiChannel(channelIds: channelIds) { (result, error) in
            if let userInChannels = result {
                var userIds = [String]()
                for item in userInChannels {
                    if userIds.firstIndex(of: item.userId!) == nil {
                        userIds.append(item.userId!)
                    }
                }
                self.userModels!.getUserByIds(ids: userIds) { (users, error) in
                    for item in channels {
                        if let lastMessage = item.lastMessage {
                            lastMessage.author = users.first(where: {$0.id == lastMessage.authorId})
                            if let sentAt = lastMessage.sentAt {
                                for userInChannel in userInChannels {
                                    if userInChannel.channelId == item.id {
                                        if let date = userInChannel.lastReceive,
                                            date.timeIntervalSince1970 > sentAt.timeIntervalSince1970 {
                                            if let user = users.first(where: {$0.id == userInChannel.userId}) {
                                                lastMessage.receivedBy.append(user)
                                            }
                                        }
                                        if let date = userInChannel.lastSeen,
                                            date.timeIntervalSince1970 > sentAt.timeIntervalSince1970 {
                                            if let user = users.first(where: {$0.id == userInChannel.userId}) {
                                                lastMessage.seenBy.append(user)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    completion(channels)
                }
            } else {
                completion(channels)
            }
        }
    }
    
    private func addInfoMessages(messages: [BlaMessage], completion: @escaping ([BlaMessage]) -> Void) {
        if messages.count > 0 {
            self.channelModels!.getUserInChannel(channelId: messages[0].channelId!) { (result, error) in
                if let userInChannels = result {
                    var userIds = [String]()
                    for item in messages {
                        if userIds.firstIndex(of: item.authorId!) == nil {
                            userIds.append(item.authorId!)
                        }
                    }
                    self.userModels!.getUserByIds(ids: userIds) { (users, error) in
                        for item in messages {
                            item.author = users.first(where: {$0.id == item.authorId})
                            if let sentAt = item.sentAt {
                                for userInChannel in userInChannels {
                                    if userInChannel.userId != CacheRepository.shareInstance.userId {
                                        if let date = userInChannel.lastReceive, date.timeIntervalSince1970 > sentAt.timeIntervalSince1970 {
                                            if let user = users.first(where: {$0.id == userInChannel.userId}) {
                                                item.receivedBy.append(user)
                                            }
                                        }
                                        if let date = userInChannel.lastSeen, date.timeIntervalSince1970 > sentAt.timeIntervalSince1970 {
                                            if let user = users.first(where: {$0.id == userInChannel.userId}) {
                                                item.seenBy.append(user)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        completion(messages)
                    }
                } else {
                    completion(messages)
                }
            }
        } else {
            completion(messages)
        }
    }
    
    func handleEvent(event: JSON) {
        UserDefaults.standard.setValue(event["event_id"].stringValue, forKey: "lastEventId")
        switch (event["type"]) {
        case "new_message":
            let dao = BlaMessageDAO(json: event["payload"])
            let message = BlaMessage(dao: dao)
            channelModels!.updateLastMessage(channelId: message.channelId!, lastMessageId: message.id!) { (channel, error) in
            }
            messageModels!.saveMessage(message: message)
            if (message.authorId != CacheRepository.shareInstance.userId) {
                self.markReceiveMessage(messageId: event["payload"]["id"].stringValue, channelId: event["payload"]["channel_id"].stringValue) { (result, error) in
                }
                self.channelModels!.updateNumberMessageUnread(channelId: event["payload"]["channel_id"].stringValue, isResetCount: false) {(channel, error) in
                    if let channel = channel {
                        for delegate in self.channelDelegates {
                            delegate.onUpdateChannel(channel: channel)
                        }
                    }
                }
            } else {
                self.channelModels!.updateNumberMessageUnread(channelId: event["payload"]["channel_id"].stringValue, isResetCount: true) {(channel, error) in
                    if let channel = channel {
                        for delegate in self.channelDelegates {
                            delegate.onUpdateChannel(channel: channel)
                        }
                    }
                }
            }
            self.addInfoMessages(messages: [message]) { (result) in
                if result.count > 0 {
                    for item in self.messageDelegates {
                        item.onNewMessage(message: result[0])
                    }
                }
            }
            break;
        case "typing_event":
            let channelId = event["payload"]["channel_id"].stringValue
            self.channelModels!.getChannelById(channelId: channelId) { (channel, error) in
                if let channel = channel {
                    self.userModels!.getUserById(user_id: event["payload"]["user_id"].stringValue) { (user) in
                        for item in self.channelDelegates {
                            if event["payload"]["is_typing"].boolValue == true {
                                item.onTyping(channel: channel, user: user, type: BlaEventType.START)
                            } else {
                                item.onTyping(channel: channel, user: user, type: BlaEventType.STOP)
                            }
                        }
                    }
                }
            }
            break;
        case "new_channel":
            let channel = BlaChannel(dao: BlaChannelDAO(json: event["payload"]));
            channelModels!.saveChannel(channel: channel)
            self.getUserInChannel(channelId: channel.id!) { (result, error) in
            }
            self.handleChannel(channels: [channel]) { (result) in
                if result.count > 0 {
                    for item in self.channelDelegates {
                        item.onNewChannel(channel: result[0])
                    }
                }
            }
            break;
        case "mark_seen":
            self.messageModels!.getMessageById(messageId: event["payload"]["message_id"].stringValue) { (result, error) in
                if let mess = result {
                    let userInChannel = BlaUserInChannel(channelId: event["payload"]["channel_id"].stringValue, userId: event["payload"]["actor_id"].stringValue, lastSeen: event["payload"]["time"].doubleValue, lastReceive:  event["payload"]["time"].doubleValue)
                    self.channelModels?.saveUserInChannel(userInChannel: userInChannel)
                    self.addInfoMessages(messages: [mess]) { (messages) in
                        self.userModels!.getUserById(user_id: event["payload"]["actor_id"].stringValue) { (user) in
                            for item in self.messageDelegates {
                                item.onUserSeen(message: messages[0], user: user, seenAt: Date.init(timeIntervalSince1970: event["payload"]["time"].doubleValue))
                            }
                        }
                    }
                }
            }
            break;
            
        case "mark_receive":
            self.messageModels!.getMessageById(messageId: event["payload"]["message_id"].stringValue) { (result, error) in
                if let mess = result {
                    let userInChannel = BlaUserInChannel(channelId: event["payload"]["channel_id"].stringValue, userId: event["payload"]["actor_id"].stringValue, lastSeen: nil, lastReceive:  event["payload"]["time"].doubleValue)
                    self.channelModels?.saveUserInChannel(userInChannel: userInChannel)
                    self.addInfoMessages(messages: [mess]) { (messages) in
                        self.userModels!.getUserById(user_id: event["payload"]["actor_id"].stringValue) { (user) in
                            for item in self.messageDelegates {
                                item.onUserReceive(message: messages[0], user: user, receivedAt: Date.init(timeIntervalSince1970: event["payload"]["time"].doubleValue))
                            }
                        }
                    }
                }
            }
            break;
        case "update_channel":
            let channel = BlaChannel(dao: BlaChannelDAO(json: event["payload"]))
            self.channelModels!.saveChannel(channel: channel)
            for item in channelDelegates {
                item.onNewChannel(channel: channel)
            }
            break;
        case "update_content_message":
            self.messageModels!.getMessageById(messageId: event["payload"]["message_id"].stringValue) { (message, error) in
                if let message = message {
                    message.content = event["payload"]["content"].stringValue
                    self.messageModels!.saveMessage(message: message)
                    for delegate in self.messageDelegates {
                        delegate.onUpdateMessage(message: message)
                    }
                }
            }
            break;
        case "delete_message":
            self.messageModels!.deleteMessageLocal(messageId: event["payload"]["message_id"].stringValue)
            for delegate in self.messageDelegates {
                delegate.onDeleteMessage(messageId: event["payload"]["message_id"].stringValue)
            }
            break;
        case "delete_channel":
            self.channelModels!.removeChannelLocal(channelId: event["payload"]["channel_id"].stringValue)
            for delegate in self.channelDelegates {
                delegate.onDeleteChannel(channelId: event["payload"]["channel_id"].stringValue)
            }
            break;
        case "remove_user_from_channel":
            self.channelModels!.removeUserInChannelLocal(channelId: event["payload"]["channel_id"].stringValue, userId: event["payload"]["user_id"].stringValue)
            self.channelModels!.getChannelById(channelId: event["payload"]["channel_id"].stringValue) { (channel, error) in
                if let channel = channel {
                    self.userModels!.getUserById(user_id: event["payload"]["user_id"].stringValue) { (user) in
                        for delegate in self.channelDelegates {
                            delegate.onMemberLeave(channel: channel, user: user)
                        }
                    }
                }
            }
            break;
        case "invite_user":
            self.channelModels!.getChannelById(channelId: event["payload"]["channel_id"].stringValue) { (channel, error) in
                if let channel = channel {
                    for item in event["payload"]["user_ids"].arrayValue {
                        let userInChannel = BlaUserInChannel(channelId: event["payload"]["channel_id"].stringValue, userId: item.stringValue, lastSeen: channel.createdAt?.timeIntervalSince1970, lastReceive: channel.createdAt?.timeIntervalSince1970)
                        self.channelModels?.saveUserInChannel(userInChannel: userInChannel)
                        self.userModels!.getUserById(user_id: item.stringValue) { (user) in
                            for delegate in self.channelDelegates {
                                delegate.onMemberLeave(channel: channel, user: user)
                            }
                        }
                    }
                }
            }
            break;
        default:
            break
        }
    }
}

extension ChatSDK: CentrifugoControllerDelegate {
    func onPublish(_ sub: CentrifugeSubscription, _ e: CentrifugePublishEvent) {
        let data = String(data: e.data, encoding: .utf8) ?? ""
        let event = JSON.init(parseJSON: data)
        print("new event SDK ", event)
        self.handleEvent(event: event)
    }
}
