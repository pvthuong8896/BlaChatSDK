//
//  Users.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class UsersRemote: BaseRepositoryRemote {

    func getUserInChannel(channel_id: String, completion: @escaping(JSON?, Error?) -> Void) {
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/channels/members/\(channel_id)",
            method: .get,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func getUserByIds(ids: [String], completion: @escaping(JSON?, Error?) -> Void) {
        var params = [String: Any]()
        params["ids"] = ids
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/members/gets",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func setUserOnline(userId: String, completion: @escaping(JSON?, Error?) -> Void) {
        var params = [String: Any]()
        params["id"] = userId
        params["type"] = "2"
        let request = alamoFireManager.request(
            Constants.domainPresence + "/update",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
    
    func getUserStutus(userIds: [String], completion: @escaping(JSON?, Error?) -> Void) {
        let ids = userIds.joined(separator: ",")
        var params = [String: Any]()
        params["ids"] = ids
        let request = alamoFireManager.request(
            Constants.domainPresence + "/get-by-ids",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: nil
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
}

