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
}
