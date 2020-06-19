//
//  CentrifugoController.swift
//  ChatSDK
//
//  Created by Os on 4/16/20.
//  Copyright © 2020 com.blameo. All rights reserved.
//

import UIKit

protocol CentrifugoControllerDelegate: NSObjectProtocol {
    func onPublish(_ s: CentrifugeSubscription, _ e: CentrifugePublishEvent)
}


class CentrifugoController: NSObject {
    
    private var client: CentrifugeClient?
    private var sub: CentrifugeSubscription?
    private var isConnected: Bool = false
    private var subscriptionCreated: Bool = false
    weak var delegate: CentrifugoControllerDelegate?
    
    static var shareInstance: CentrifugoController = {
        let instance = CentrifugoController()
        return instance
    }()
    
    override init() {
        super.init()
        connectSocket()
    }
    
    func connectSocket() {
        let config = CentrifugeClientConfig()
        let url = "ws://\(Constants.IP):8001/connection/websocket?format=protobuf"
        self.client = CentrifugeClient(url: url, config: config, delegate: self)
        self.client?.setToken(CacheRepository.shareInstance.token)
        self.client?.connect()
        do {
            sub = try self.client?.newSubscription(channel: "chat#\(CacheRepository.shareInstance.userId)", delegate: self)
        } catch {
            print("Can not create subscription: \(error)")
            return
        }
        sub?.subscribe()
    }
}

extension CentrifugoController: CentrifugeClientDelegate {
    func onConnect(_ c: CentrifugeClient, _ e: CentrifugeConnectEvent) {
        self.isConnected = true
        print("connected with id", e.client)
    }
    
    func onDisconnect(_ c: CentrifugeClient, _ e: CentrifugeDisconnectEvent) {
        self.isConnected = false
        print("disconnected", e.reason, "reconnect", e.reconnect)
    }
}

extension CentrifugoController: CentrifugeSubscriptionDelegate {
    
    func onPublish(_ s: CentrifugeSubscription, _ e: CentrifugePublishEvent) {
        delegate?.onPublish(s, e)
    }
    
    func onSubscribeSuccess(_ s: CentrifugeSubscription, _ e: CentrifugeSubscribeSuccessEvent) {
        s.presence(completion: { result, error in
            if let err = error {
                print("Unexpected presence error: \(err)")
            } else if let presence = result {
                print(presence)
            }
        })
        print("successfully subscribed to channel \(s.channel)")
    }
    
    func onSubscribeError(_ s: CentrifugeSubscription, _ e: CentrifugeSubscribeErrorEvent) {
        print("failed to subscribe to channel", e.code, e.message)
    }
    
    func onUnsubscribe(_ s: CentrifugeSubscription, _ e: CentrifugeUnsubscribeEvent) {
        print("unsubscribed from channel", s.channel)
    }
    
    func onJoin(_ s: CentrifugeSubscription, _ e: CentrifugeJoinEvent) {
        print("client joined channel \(s.channel), user ID \(e.user)")
    }
    
    func onLeave(_ s: CentrifugeSubscription, _ e: CentrifugeLeaveEvent) {
        print("client left channel \(s.channel), user ID \(e.user)")
    }

}
