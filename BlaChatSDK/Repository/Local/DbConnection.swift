//
//  DbConnection.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import SQLite
import Foundation


class DbConnection: NSObject {
    
    static var shareInstance: DbConnection = {
        let instance = DbConnection()
        return instance
    }()
    
    var connection: Connection?
    let dbFileName = "db.sqlite"
    
    override init() {
        let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        do {
           connection = try Connection("\(dbPath)/\(dbFileName)")
        } catch {
            connection = nil
            print("Error connection database ", error)
        }
    }
}
