//
//  RequestManager.swift
//  ChatSDK
//
//  Created by Os on 3/31/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RequestManager: NSObject {
    
    static var shareInstance: RequestManager = {
        let instance = RequestManager()
        return instance
    }()
    
    func startRequest(_ request: DataRequest, completion: @escaping(JSON?, NSError?) -> Void) {
        request
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(_):
                    let json = JSON(response.result.value!)
                    completion(json, nil)
                case .failure(let error as NSError):
                    completion(nil, error)
                default:
                    break
                }
        }
    }
}
