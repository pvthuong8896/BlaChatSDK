//
//  Messages.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class MessagesRemote: BaseRepositoryRemote {
    
    func sendMessage(channelId: String, message: String, sentAt: Double, type: Int, customData: [String: Any]?, completion: @escaping(JSON?, Error?) -> Void) {
        var param = [String: Any]()
        param["channel_id"] = channelId
        param["message"] = message
        param["sent_at"] = Int(sentAt)
        param["type"] = type
        if let customData = customData {
            if let theJSONData = try?  JSONSerialization.data(
                withJSONObject: customData ?? [String: Any](),
              options: .prettyPrinted
              ),
              let jsonString = String(data: theJSONData,
                                       encoding: String.Encoding.utf8) {
                 param["custom_data"] = jsonString
            }
        }
        
        let request = alamoFireManager.request(
            Constants.domain + "/v1/messages/create",
            method: .post,
            parameters: param, 
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func getMessages(channelId: String, lastId: String?, completion: @escaping(JSON?, Error?) -> Void) {
        let request = alamoFireManager.request(
            Constants.domain + "/v1/messages/channel/\(channelId)?lastId=\(lastId ?? "")",
            method: .get,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func markReceiveMessage(channelId: String, messageId: String, receiveId: String, completion: @escaping(JSON?, Error?) -> Void) {
        var param = [String: Any]()
        param["message_id"] = messageId
        param["channel_id"] = channelId
        param["receive_id"] = receiveId
        let request = alamoFireManager.request(
            Constants.domain + "/v1/messages/mark-receive",
            method: .post,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func markSeenMessage(channelId: String, messageId: String, receiveId: String, completion: @escaping(JSON?, Error?) -> Void) {
        var param = [String: Any]()
        param["message_id"] = messageId
        param["channel_id"] = channelId
        param["receive_id"] = receiveId
        let request = alamoFireManager.request(
            Constants.domain + "/v1/messages/mark-seen",
            method: .post,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func updateMessage(messageId: String, channelId: String, content: String, completion: @escaping (JSON?, Error?) -> Void) {
        var param = [String: Any]()
        param["message_id"] = messageId
        param["channel_id"] = channelId
        param["content"] = content
        let request = alamoFireManager.request(
            Constants.domain + "/v1/messages/update",
            method: .put,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func deleteMessage(channelId: String, messageId: String, completion: @escaping(JSON?, Error?) -> Void) {
        var param = [String: Any]()
        param["message_id"] = messageId
        param["channel_id"] = channelId
        let request = alamoFireManager.request(
            Constants.domain + "/v1/messages/update",
            method: .put,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
}
