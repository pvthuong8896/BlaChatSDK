//
//  ChannelModels.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChannelModels: NSObject {
    let messageLocal = MessagesLocal()
    var channelLocal = ChannelsLocal()
    let channelRemote = ChannelsRemote()
    let userInChannelLocal = UserInChannelLocal()
    var userModel: UserModels?
    
    init(userModel: UserModels) {
        self.userModel = userModel
    }
    
    func createChannel(name: String, avatar: String, userIds: [String], type: Int, customData: [String: Any], completion: @escaping (BlaChannel?, Error?) -> Void) {
        channelRemote.createChannel(name: name, avatar: avatar, userIds: userIds, type: type, customData: customData) { (json, error) in
            guard let json = json else {
                completion(nil , error)
                return
            }
            let dao = BlaChannelDAO(json: json["data"])
            let channel = BlaChannel(dao: dao)
            self.channelLocal.insertChannel(id: channel.id!, name: channel.name ?? "", avatar: channel.avatar ?? "", created_at: channel.createdAt, updated_at: channel.updatedAt, type: channel.type?.rawValue ?? 0, last_message_id: channel.lastMessageId, customData: channel.customData, numberMessageUnread: 0) { (channel, error) in
            }
            completion(channel, nil)
        }
    }
    
    func getChannel(lastId: String?, limit: Int, completion: @escaping ([BlaChannel]?, Error?) -> Void) {
        channelLocal.getChannel(limit: limit, lastId: lastId) { (channels, error) in
            if let channels = channels, channels.count > 0 {
                var channelIds = [String]()
                for item in channels {
                    channelIds.append(item.id!)
                }
                self.getUserInMultiChannel(channelIds: channelIds) { (result, error) in
                }
                completion(channels, error)
            } else {
                self.channelRemote.getChannel(lastId: lastId, limit: limit) { (json, error) in
                    guard let json = json else {
                        completion(nil, error)
                        return
                    }
                    var channels = [BlaChannel]()
                    var channelIds = [String]()
                    for subJson in json["data"].arrayValue {
                        let dao = BlaChannelDAO(json: subJson)
                        if let lastMessages = dao.lastMessages, lastMessages.count > 0 {
                            for item in lastMessages {
                                let mess = BlaMessage(dao: item)
                                self.messageLocal.saveMessage(message: mess)
                            }
                        }
                        let channel = BlaChannel(dao: dao)
                        channels.append(channel)
                        channelIds.append(channel.id!)
                    }
                    self.getUserInMultiChannel(channelIds: channelIds) { (result, error) in
                        guard let result = result else {
                            completion(nil, error)
                            return
                        }
                        var userIds = [String]()
                        for item in result {
                            userIds.append(item.userId!)
                        }
                        self.userModel?.getUserByIds(ids: userIds, completion: { (users, error) in
                            for (index, channel) in channels.enumerated() {
                                if channel.type == BlaChannelType.DIRECT {
                                    let userInChannel = result.first(where: {$0.channelId == channel.id && $0.userId != CacheRepository.shareInstance.userId})
                                    
                                    let user = users.first(where: {$0.id == userInChannel?.userId})
                                    if (user != nil) {
                                        channels[index].name = user?.name
                                        channels[index].avatar = user?.avatar
                                    }
                                }
                                self.saveChannel(channel: channel)
                            }
                            completion(channels, nil)
                        })
                    }
                    
                }
            }
        }
    }
    
    func updateChannel(channelId: String, name: String?, avatar: String?, customData: [String: Any]?, completion: @escaping (BlaChannel?, Error?) -> Void) {
        channelRemote.updateChannel(channelId: channelId, name: name, avatar: avatar, customData: customData) { (json, error) in
            if let json = json {
                let channel = BlaChannel(dao: BlaChannelDAO(json: json["data"]))
                completion(channel, error)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func deleteChannel(channelId: String, completion: @escaping (Bool?, Error?) -> Void) {
        channelRemote.deleteChannel(channelId: channelId) { (json, error) in
            if let err = error {
                completion(nil, err)
            } else {
                self.channelLocal.removeChannel(channelId: channelId)
                self.userInChannelLocal.removeAllUserInChannel(channelId: channelId)
                completion(true, error)
            }
        }
    }
    
    func saveChannel(channel: BlaChannel) {
        self.channelLocal.saveChannel(channel: channel)
    }
    
    func getUserInChannel(channelId: String, completion: @escaping ([BlaUserInChannel]?, Error?) -> Void) {
        self.userInChannelLocal.getUserInChannel(channel_id: channelId) { (result, error) in
            if let result = result, result.count > 0 {
                completion(result, nil)
            } else {
                self.channelRemote.getUserInChannel(channelId: channelId) { (json, error) in
                    if let json = json {
                        var userInChannels = [BlaUserInChannel]()
                        for subJson in json["data"].arrayValue {
                            let item = BlaUserInChannel(json: subJson, channelId: channelId)
                            userInChannels.append(item)
                            self.saveUserInChannel(userInChannel: item)
                        }
                        completion(userInChannels, error)
                    } else {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    func getUserInMultiChannel(channelIds: [String], completion: @escaping ([BlaUserInChannel]?, Error?) -> Void) {
        self.userInChannelLocal.getUserInMultiChannel(ids: channelIds) { (result, error) in
            if let result = result, result.count > 0 {
                completion(result, error)
            } else {
                self.channelRemote.getUserInMultiChannel(ids: channelIds) { (json, error) in
                    if let json = json {
                        var result = [BlaUserInChannel]()
                        for subJson in json["data"].arrayValue {
                            let tmpChannelId = subJson["channel_id"].stringValue
                            for item in subJson["list_member"].arrayValue {
                                let userInChannel = BlaUserInChannel(json: item, channelId: tmpChannelId)
                                result.append(userInChannel)
                                self.saveUserInChannel(userInChannel: userInChannel)
                            }
                        }
                        completion(result, error)
                    } else {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    
    
    func saveUserInChannel(userInChannel: BlaUserInChannel) {
        self.userInChannelLocal.saveUserInChannel(userInChannel: userInChannel)
    }
    
    func getChannelById(channelId: String, completion: @escaping(BlaChannel?, Error?) -> Void) {
        self.channelLocal.getChannelById(channelId: channelId) { (channel, error) in
            if let channel = channel {
                completion(channel, nil)
            } else {
                self.channelRemote.getChannelsByIds(channelIds: [channelId]) { (json, error) in
                    if let json = json {
                        if (json["data"].arrayValue.count > 0) {
                            let channel = BlaChannel(dao: BlaChannelDAO(json: json["data"].arrayValue[0]))
                            completion(channel, nil)
                        } else {
                            completion(nil, error)
                        }
                    } else {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    func updateLastMessage(channelId: String, lastMessageId: String, completion: @escaping(BlaChannel?, Error?) -> Void) {
        channelLocal.updateLastMessageChannel(channelId: channelId, messageId: lastMessageId) { (channel, error) in
            completion(channel, error)
        }
    }
    
    func sendTypingEvent(channelId: String, completion: @escaping(Bool?, Error?) -> Void) {
        channelRemote.sendTypingEvent(channelId: channelId) { (json, error) in
            if let err = error {
                completion(false, err)
            } else {
                completion(true, error)
            }
        }
    }
    
    func sendStopTypingEvent(channelId: String, completion: @escaping(Bool?, Error?) -> Void) {
        channelRemote.sendStopTypingEvent(channelId: channelId) { (json, error) in
            if let err = error {
                completion(false, err)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func searchChannels(query: String, completion: @escaping ([BlaChannel]?, Error?) -> Void) {
        channelLocal.searchChannels(query: query) { (channels, error) in
            completion(channels, error)
        }
    }
    
    func inviteUserToChannel(channelId: String, userIds: [String], completion: @escaping(Bool?, Error?) -> Void) {
        channelRemote.inviteUserToChannel(channelId: channelId, userIds: userIds) { (json, error) in
            if let err = error {
                completion(false, err)
            } else {
                for subJson in json!["data"].arrayValue {
                    let userInChannel = BlaUserInChannel(json: subJson, channelId: channelId)
                    self.saveUserInChannel(userInChannel: userInChannel)
                }
                completion(true, nil)
            }
        }
    }
    
    func removeUserFromChannel(channelId: String, userId: String, completion: @escaping(Bool?, Error?) -> Void) {
        channelRemote.removeUserFromChannel(channelId: channelId, userId: userId) { (json, error) in
            if let err = error {
                completion(false, err)
            } else {
                self.userInChannelLocal.removeUserInChannel(channelId: channelId, userId: userId)
                completion(true, nil)
            }
        }
    }
    
    func removeChannelLocal(channelId: String) {
        self.channelLocal.removeChannel(channelId: channelId)
    }
    
    func removeUserInChannelLocal(channelId: String, userId: String) {
        self.userInChannelLocal.removeUserInChannel(channelId: channelId, userId: userId)
    }
    
    func updateNumberMessageUnread(channelId: String, isResetCount: Bool, completion: @escaping(BlaChannel?, Error?) -> Void) {
        self.channelLocal.updateNumberMessageUnread(channelId: channelId, isResetCount: isResetCount) {(result) in
            self.getChannelById(channelId: channelId) { (channel, error) in
                completion(channel, error)
            }
        }
    }
    
    func removeAllChannel() {
        self.channelLocal.removeAllChannel()
        self.userInChannelLocal.removeAllUserInChannel()
    }
}
