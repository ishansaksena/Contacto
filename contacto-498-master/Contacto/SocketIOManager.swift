//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Kyungmin Lee on 5/20/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Contacts

class SocketIOManager : NSObject {

    static let sharedInstance = SocketIOManager()

    let socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://ec2-54-224-116-146.compute-1.amazonaws.com:3000")!)
    
}