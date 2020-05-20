//
//  UserModels.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit

class UserModels: NSObject {
    static var validUsers = [BlaUser]()
    private var userLocal = UsersLocal()
    private var userRemote = UsersRemote()
    
    func getAllUser(completion: @escaping ([BlaUser], Error?) -> Void) {
        userLocal.getAllUser { (users, error) in
            for item in users {
                CacheRepository.shareInstance.validUsers.append(item)
            }
            completion(users, error)
        }
    }
    
    func setUserStatus(userId: String) {
        userRemote.setUserOnline(userId: userId) { (json, erro) in
        }
    }
    
    func getStatusUserByIds(userIds: [String], completion: @escaping([BlaUserStatus]?, Error?) -> Void) {
        userRemote.getUserStutus(userIds: userIds) { (json, error) in
            if let json = json {
                var listUserStatus = [BlaUserStatus]()
                for item in json["data"].arrayValue {
                    listUserStatus.append(BlaUserStatus(json: item))
                }
                completion(listUserStatus, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getUserById(user_id: String, completion: @escaping (BlaUser) -> Void) {
        self.getUserByIds(ids: [user_id]) { (result, error) in
            completion(result[0])
        }
    }
    
    func getUserByIds(ids: [String], completion: @escaping([BlaUser], Error?) -> Void) {
        var idsNotValid = [String]()
        var listUserResult = [BlaUser]()
        for userId in ids {
            if let index = CacheRepository.shareInstance.validUsers.firstIndex(where: {$0.id == userId}) {
                listUserResult.append(CacheRepository.shareInstance.validUsers[index])
            } else {
                idsNotValid.append(userId)
            }
        }
        if idsNotValid.count > 0 {
            self.userLocal.getUserByIds(ids: idsNotValid) { (users, error) in
                if let users = users, users.count > 0 {
                    for user in users {
                        listUserResult.append(user)
                        CacheRepository.shareInstance.validUsers.append(user)
                    }
                    var tmpNotValid = [String]()
                    for item in idsNotValid {
                        if listUserResult.firstIndex(where: {$0.id == item}) == nil {
                            tmpNotValid.append(item)
                        }
                    }
                    if tmpNotValid.count > 0 {
                        self.userRemote.getUserByIds(ids: tmpNotValid) { (json, error) in
                            if let _ = error {
                                for item in ids {
                                    listUserResult.append(BlaUser(id: item, name: "", avatar: "", lastActiveAt: 0, customData: ""))
                                }
                                completion(listUserResult, nil)
                            } else {
                                for subJson in json!["data"].arrayValue {
                                    let user = BlaUser(subJson)
                                    listUserResult.append(user)
                                    CacheRepository.shareInstance.validUsers.append(user)
                                    self.userLocal.saveUser(user: user)
                                }
                                for item in idsNotValid {
                                    if let _ = listUserResult.firstIndex(where: {$0.id == item}) {
                                    } else {
                                        listUserResult.append(BlaUser(id: item, name: "", avatar: "", lastActiveAt: 0, customData: ""))
                                    }
                                }
                                completion(listUserResult, nil)
                            }
                        }
                    } else {
                        completion(listUserResult, nil)
                    }
                } else {
                    self.userRemote.getUserByIds(ids: idsNotValid) { (json, error) in
                        if let _ = error {
                            for item in ids {
                                listUserResult.append(BlaUser(id: item, name: "", avatar: "", lastActiveAt: 0, customData: ""))
                            }
                            completion(listUserResult, nil)
                        } else {
                            for subJson in json!["data"].arrayValue {
                                let user = BlaUser(subJson)
                                listUserResult.append(user)
                                CacheRepository.shareInstance.validUsers.append(user)
                                self.userLocal.saveUser(user: user)
                            }
                            for item in idsNotValid {
                                if let _ = listUserResult.firstIndex(where: {$0.id == item}) {
                                } else {
                                    listUserResult.append(BlaUser(id: item, name: "", avatar: "", lastActiveAt: 0, customData: ""))
                                }
                            }
                            completion(listUserResult, nil)
                        }
                    }
                }
            }
        } else {
            completion(listUserResult, nil)
        }
        
    }
}
