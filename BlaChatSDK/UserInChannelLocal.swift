//
//  UserInChannel.swift
//  ChatSDK
//
//  Created by Os on 4/9/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SQLite
import SwiftyJSON

class UserInChannelLocal: NSObject {
    static var shareInstance: UserInChannelLocal = {
        let instance = UserInChannelLocal()
        return instance
    }()
    
    private let tblUserInChannel = Table("tblUserInChannel")
    private let channel_id = Expression<String?>("channel_id")
    private let user_id = Expression<String?>("user_id")
    private let last_seen = Expression<Double?>("last_seen")
    private let last_receive = Expression<Double?>("last_receive")
    
    override init() {
        super.init()
        createTable()
    }
    
    
    func createTable() {
        do {
            if let connection = DbConnection.shareInstance.connection {
                try connection.run(self.tblUserInChannel.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                    table.column(self.channel_id)
                    table.column(self.user_id)
                    table.column(self.last_seen)
                    table.column(self.last_receive)
                }))
                print("Create table tblUserInChannel success")
            }
        } catch {
            print("Create table tblUserInChannel fail ", error)
        }
    }
    
    
    func getUserInChannel(channel_id: String, completion: ([BlaUserInChannel]?, Error?) -> Void) {
        do {
            let filter = tblUserInChannel.filter(self.channel_id == channel_id)
            let messsages = try DbConnection.shareInstance.connection?.prepare(filter)
            var listUserInChannel = [BlaUserInChannel]()
            if let sequence: AnySequence<Row> = messsages {
                for row in sequence {
                    let userInChannel = BlaUserInChannel(channelId: row[self.channel_id], userId: row[self.user_id], lastSeen: row[self.last_seen], lastReceive: row[self.last_receive])
                    listUserInChannel.append(userInChannel)
                }
                
            }
            completion(listUserInChannel, nil)
        } catch {
            completion(nil, error)
            print("Get Messages error ", error)
        }
    }
    
    func getUserInMultiChannel(ids: [String], completion: ([BlaUserInChannel]?, Error?) -> Void) {
        do {
            let filter = tblUserInChannel.filter(ids.contains(self.channel_id))
            let messsages = try DbConnection.shareInstance.connection?.prepare(filter)
            var listUserInChannel = [BlaUserInChannel]()
            if let sequence: AnySequence<Row> = messsages {
                for row in sequence {
                    let userInChannel = BlaUserInChannel( channelId: row[self.channel_id], userId: row[self.user_id], lastSeen: row[self.last_seen], lastReceive: row[self.last_receive])
                    listUserInChannel.append(userInChannel)
                }
                
            }
            completion(listUserInChannel, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func insertUserInChannel(channel_id: String?, user_id: String?, last_seen: Date?, last_receive: Date?, completion: @escaping(BlaChannel?, Error?) -> Void) {
        do {
            let insert = tblUserInChannel.insert(
                self.channel_id <- channel_id,
                self.user_id <- user_id,
                self.last_seen <- last_seen?.timeIntervalSince1970,
                self.last_receive <- last_receive?.timeIntervalSince1970
            )
            try DbConnection.shareInstance.connection?.run(insert)
        } catch {
            print("insert channel error ", error)
        }
    }
    
    func updateUserInChannel(userInChannel: BlaUserInChannel, completion: @escaping(Bool?, Error?) -> Void) {
        do {
            let filter = self.tblUserInChannel.filter(self.user_id==userInChannel.userId && self.channel_id == userInChannel.channelId)
            var setter:[SQLite.Setter] = [SQLite.Setter]()
            if let last_receive = userInChannel.lastReceive {
                setter.append(self.last_receive <- last_receive.timeIntervalSince1970)
            }
            if let last_seen = userInChannel.lastSeen {
                setter.append(self.last_seen <- last_seen.timeIntervalSince1970)
            }
            if setter.count > 0 {
                let update = filter.update(setter)
                try DbConnection.shareInstance.connection?.run(update)
                completion(true, nil)
            }
        } catch {
            print("Update channel error ", error)
        }
    }
    
    func saveUserInChannel(userInChannel: BlaUserInChannel, completion: @escaping(Bool?, Error?) -> Void) {
        do {
            try DbConnection.shareInstance.connection?.transaction {
                let filter = self.tblUserInChannel.filter((self.user_id==userInChannel.userId) && (self.channel_id == userInChannel.channelId))
                let resultFilter = try DbConnection.shareInstance.connection?.pluck(filter)
                if let _ = resultFilter {
                    self.updateUserInChannel(userInChannel: userInChannel) { (result, error) in
                        completion(result, error)
                    }
                } else {
                    self.insertUserInChannel(channel_id: userInChannel.channelId, user_id: userInChannel.userId, last_seen: userInChannel.lastSeen, last_receive: userInChannel.lastReceive) { (result, error) in
                        completion(true, nil)
                    }
                }
            }
        } catch {
            print("Error to saveUserInChannel")
        }
    }
    
    func removeUserInChannel(channelId: String, userId: String) {
        do {
            let filter = self.tblUserInChannel.filter(self.channel_id == channelId && self.user_id == userId).delete()
            try DbConnection.shareInstance.connection?.run(filter)
        } catch {
            print("error to delete user in channel")
        }
    }
    
    func removeAllUserInChannel(channelId: String) {
        do {
            let filter = self.tblUserInChannel.filter(self.channel_id == channelId).delete()
            try DbConnection.shareInstance.connection?.run(filter)
        } catch {
            print("error to delete user in channel")
        }
    }
    
    func removeAllUserInChannel() {
        do {
            let filter = tblUserInChannel.delete()
            try DbConnection.shareInstance.connection?.run(filter)
        } catch {
            print("remove message error")
        }
    }
}
