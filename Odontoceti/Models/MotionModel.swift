//
//  MotionModel.swift
//  Odontoceti
//
//  Created by Gregory Foster on 3/19/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import Foundation
import CoreMotion


/// The the store of information about the current magnetic readings from the phone.
class MotionModel: NSObject {
    
    /// The name for the notification which contains the latest measured motion values.
    public static var updateNotificationName = Notification.Name(rawValue: "MotionUpdate")
    
    /// The class singleton.
    static let sharedModel = MotionModel()
    
    /// The deviceMotionUpdateInterval.
    public let rate: Double = 0.05
    
    /// The manager which tracks and provides measurements from the magnet which are then passed on.
    private let motionManager = CMMotionManager()
    
    override init() {
        super.init()
        motionManager.deviceMotionUpdateInterval = TimeInterval(rate)
        motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical,
                                               to: OperationQueue.main,
                                               withHandler: {motionData, error in
                                                let x = motionData?.userAcceleration.x
                                                let y = motionData?.userAcceleration.y
                                                let z = motionData?.userAcceleration.z
                                                
                                                print("c")
                                                if let x = x, let y = y, let z = z {
                                                    NotificationCenter.default.post(name: MotionModel.updateNotificationName,
                                                                                    object: nil,
                                                                                    userInfo: ["accelX": x,
                                                                                               "accelY": y,
                                                                                               "accelZ": z])
                                                }
        })
    }
}
