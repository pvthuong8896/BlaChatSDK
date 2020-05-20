//
//  BaseRepositoryRemote.swift
//  ChatSDK
//
//  Created by Os on 4/6/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit
import Alamofire

class BaseRepositoryRemote: NSObject {

    var requests = [DataRequest]()
    var requestManager = RequestManager.shareInstance
    var alamoFireManager = Alamofire.SessionManager()
    var headers: HTTPHeaders {
        get {
            let accessToken = UserDefaults.standard.string(forKey: "token")
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken!)",
                "Content-Type": "application/json"
            ]
            return headers
        }
    }
    
    var headersWithoutJson: HTTPHeaders {
        get {
            let accessToken = UserDefaults.standard.string(forKey: "token")
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken!)",
            ]
            return headers
        }
    }
    /*
     * cancel all request for the certain service object
     * and remove all request from requests
     */
    func cancelAllRequests() {
        let sessionManager = Alamofire.SessionManager.default
        if #available(iOS 9.0, *) {
            sessionManager.session.getAllTasks { (_ tasks: [URLSessionTask]) in
                for task in tasks {
                    task.cancel()
                }
            }
        } else {
            // Fallback on earlier versions
            sessionManager.session
                .getTasksWithCompletionHandler({ (sessionTasks, uploadTasks, downloadTasks) in
                for task in sessionTasks {
                    task.cancel()
                }
                for task in uploadTasks {
                    task.cancel()
                }
                for task in downloadTasks {
                    task.cancel()
                }
            })
        }
        for request in requests {
            request.cancel()
        }
        requests.removeAll()
    }

    /*
     *  add request to request array
     *  @param request  DataRequest
     */

    func addToQueue(_ request: DataRequest) {
        requests.append(request)
    }
}
