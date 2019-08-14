//
//  MagnetModel.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/20/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import Foundation
import CoreMotion


/// The the store of information about the current magnetic readings from the phone.
class MagnetModel: NSObject {

    /// The name for the notification which contains the latest measured magnet magnitude.
    public static var updateNotificationName = Notification.Name(rawValue: "MagnetUpdate")

    /// The class singleton.
    static let sharedModel = MagnetModel()

    /// The manager which tracks and provides measurements from the magnet which are then passed on.
    private let motionManager = CMMotionManager()

    override init() {
        super.init()
        motionManager.deviceMotionUpdateInterval = TimeInterval(0.05)
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical,
                                               to: OperationQueue.main,
                                               withHandler: {motionData, error in
            let x = motionData?.magneticField.field.x
            let y = motionData?.magneticField.field.y
            let z = motionData?.magneticField.field.z
            print("a")
            if let x = x, let y = y, let z = z {
                let mag = pow(pow(x, 2.0) + pow(y, 2.0) + pow(z, 2.0), 0.5)
                NotificationCenter.default.post(name: MagnetModel.updateNotificationName,
                                                object: nil,
                                                userInfo: ["value": mag])
            }
        })
    }
}
