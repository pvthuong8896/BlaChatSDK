//
//  Users.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SQLite
import Foundation

class UsersLocal: NSObject {
    static var shareInstance: UsersLocal = {
        let instance = UsersLocal()
        return instance
    }()
    
    private let tblUser = Table("tblUser")
    
    private let id = Expression<String?>("id")
    private let name = Expression<String?>("name")
    private let avatar = Expression<String?>("avatar")
    private let last_active_at = Expression<Double?>("last_active_at")
    private let custom_data = Expression<String?>("custom_data")
    
    override init() {
        super.init()
        createTable()
    }
    
    
    func createTable() {
        do {
            if let connection = DbConnection.shareInstance.connection {
                try connection.run(self.tblUser.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                    table.column(self.id)
                    table.column(self.name)
                    table.column(self.avatar)
                    table.column(self.last_active_at)
                    table.column(self.custom_data)
                }))
                print("Create table tblUser success")
            }
        } catch {
            print("Create table tblUser fail ", error)
        }
    }
    
    func getAllUser(completion: @escaping ([BlaUser], Error?) -> Void ) {
        do {
            let users = try DbConnection.shareInstance.connection?.prepare(tblUser)
            var listUser = [BlaUser]()
            if let sequence: AnySequence<Row> = users {
                for row in sequence {
                    listUser.append(BlaUser(id: row[self.id], name: row[self.name], avatar: row[self.avatar], lastActiveAt: row[self.last_active_at], customData: row[custom_data]))
                }
            }
            completion(listUser, nil)
        } catch {
            completion([], error)
        }
    }
    
    func insertUser(id: String?, name: String?, avatar: String?, customData: [String: Any]?) {
        do {
            var customDataString = ""
            if let theJSONData = try?  JSONSerialization.data(
                withJSONObject: customData ?? [String: Any](),
                options: []
                ),
                let jsonString = String(data: theJSONData,
                                        encoding: String.Encoding.utf8) {
                customDataString = jsonString
            }
            let insert = tblUser.insert(
                self.id <- id,
                self.name <- name,
                self.avatar <- avatar,
                self.custom_data <- customDataString
            )
            try DbConnection.shareInstance.connection?.run(insert)
        } catch {
            print("insert channel error ", error)
        }
    }
    
    func updateUser(user: BlaUser) {
        do {
            let filter = self.tblUser.filter(self.id == user.id)
            var setter:[SQLite.Setter] = [SQLite.Setter]()
            if let name = user.name {
                setter.append(self.name <- name)
            }
            if let avatar = user.avatar {
                setter.append(self.avatar <- avatar)
            }
            if let lastActiveAt = user.lastActiveAt {
                setter.append(self.last_active_at <- lastActiveAt.timeIntervalSince1970)
            }
            if let theJSONData = try?  JSONSerialization.data(
                withJSONObject: user.customData ?? [String: Any](),
                options: []
                ),
                let jsonString = String(data: theJSONData,
                                        encoding: String.Encoding.utf8) {
                setter.append(self.custom_data <- jsonString)
            }
            
            if setter.count > 0 {
                let update = filter.update(setter)
                try DbConnection.shareInstance.connection?.run(update)
            }
        } catch {
            print("Update channel error ", error)
        }
    }
    
    func saveUser(user: BlaUser) {
        do {
            try DbConnection.shareInstance.connection?.transaction {
                let filter = self.tblUser.filter(self.id == user.id)
                let resultFilter = try DbConnection.shareInstance.connection?.pluck(filter)
                if let _ = resultFilter {
                    self.updateUser(user: user)
                } else {
                    self.insertUser(id: user.id, name: user.name, avatar: user.avatar, customData: user.customData)
                }
            }
        } catch {
            print("Error to saveUserInChannel")
        }
    }
    
    func getUserByIds(ids: [String], completion: @escaping ([BlaUser]?, Error?) -> Void) {
        do {
            let filter = tblUser.filter(ids.contains(self.id))
            let users = try DbConnection.shareInstance.connection?.prepare(filter)
            var listUser = [BlaUser]()
            if let sequence: AnySequence<Row> = users {
                for row in sequence {
                    listUser.append(BlaUser(id: row[self.id], name: row[self.name], avatar: row[self.avatar], lastActiveAt: row[self.last_active_at], customData: row[custom_data]))
                }
            }
            completion(listUser, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func removeAllUser() {
        do {
            let filter = tblUser.delete()
            try DbConnection.shareInstance.connection?.run(filter)
        } catch {
            print("remove message error")
        }
    }
}
