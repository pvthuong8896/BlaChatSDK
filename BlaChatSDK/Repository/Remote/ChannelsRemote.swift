//
//  Channels.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ChannelsRemote: BaseRepositoryRemote {
    
    func createChannel(name: String, userIds: [String], type: Int, completion: @escaping (JSON?, Error?) -> Void) {
        var param = [String: Any]()
        param["name"] = name
        param["userIds"] = userIds
        param["type"] = type
        
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/create",
            method: .post,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func getChannel(lastId: String?, limit: Int, completion: @escaping (JSON?, Error?) -> Void) {
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/me?pageSize=\(limit)&lastId=\(lastId ?? "")",
            method: .get,
            encoding: URLEncoding.default,
            headers: self.headers
        )
        requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func getChannelFromId(channelId: String, completion: @escaping (JSON?, Error?) -> Void) {
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/me?channelId=\(channelId)",
            method: .get,
            encoding: URLEncoding.default,
            headers: self.headers
        )
        requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func getChannelsByIds(channelIds: [String], completion: @escaping (JSON?, Error?) -> Void) {
        var params = [String: Any]()
        params["channelIds"] = channelIds
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/multi-channel",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func getUserInChannel(channelId: String, completion: @escaping (JSON?, Error?) -> Void) {
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/members/\(channelId)",
            method: .get,
            encoding: URLEncoding.default,
            headers: self.headers
        )
        requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func getUserInMultiChannel(ids: [String], completion: @escaping(JSON?, Error?) -> Void) {
        var params = [String: Any]()
        params["channelIds"] = ids
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/members",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func updateChannel(channelId: String, name: String, avatar: String, completion: @escaping (JSON?, Error?) -> Void) {
        var param = [String: Any]()
        param["name"] = name
        param["avatar"] = avatar
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/channel/\(channelId)",
            method: .put,
            parameters: param,
            encoding: URLEncoding.default,
            headers: self.headersWithoutJson
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func deleteChannel(channelId: String, completion: @escaping (JSON?, Error?) -> Void) {
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/delete/\(channelId)",
            method: .delete,
            encoding: URLEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func sendTypingEvent(channelId: String, completion: @escaping(JSON?, Error?) -> Void) {
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/events/typing/\(channelId)",
            method: .put,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func sendStopTypingEvent(channelId: String, completion: @escaping(JSON?, Error?) -> Void) {
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/events/stop-typing/\(channelId)",
            method: .put,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func inviteUserToChannel(channelId: String, userIds: [String], completion: @escaping (JSON?, Error?) -> Void) {
        var param = [String: Any]()
        param["ids"] = userIds
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/invite/\(channelId)",
            method: .post,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: self.headersWithoutJson
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func removeUserFromChannel(channelId: String, userId: String, completion: @escaping (JSON?, Error?) -> Void) {
        var param = [String: Any]()
        param["channel_id"] = channelId
        param["user_id"] = userId
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/remove-user",
            method: .delete,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
}
