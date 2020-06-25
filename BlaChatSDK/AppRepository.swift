//
//  AppRepository.swift
//  Alamofire
//
//  Created by Os on 6/24/20.
//

import UIKit
import SwiftyJSON
import Alamofire

class AppRepository: BaseRepositoryRemote {
    func updateFCMToken(fcmToken: String, completion: @escaping(Bool?, Error?) -> Void) {
        var param = [String: Any]()
        param["imei"] = UIDevice.current.identifierForVendor?.uuidString
        param["fcm_token"] = fcmToken
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/me/update-fcm",
            method: .post,
            encoding: URLEncoding.default,
            headers: self.headersWithoutJson
        )
        self.requestManager.startRequest(request) { (json, error) in
            if let err = error {
                completion(false, err)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func removeFCMToken(completion: @escaping(Bool?, Error?) -> Void) {
        var param = [String: Any]()
        param["imei"] = UIDevice.current.identifierForVendor?.uuidString
        let request = alamoFireManager.request(
            Constants.domain + "/v1/user/me/delete-fcm",
            method: .post,
            encoding: URLEncoding.default,
            headers: self.headersWithoutJson
        )
        self.requestManager.startRequest(request) { (json, error) in
            if let err = error {
                completion(false, err)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func getMissingEvent(lastEventId: String, completion: @escaping(JSON?, Error?) -> Void) {
        let request = alamoFireManager.request(
            Constants.domain + "/v1/events/gets?eventId=\(lastEventId)",
            method: .get,
            encoding: JSONEncoding.default,
            headers: self.headers
        )
        self.requestManager.startRequest(request) { (json, error) in
            completion(json, error)
        }
    }
}
