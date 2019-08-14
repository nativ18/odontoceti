//
//  SensorAccel.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/12/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import Foundation
import CoreMotion

class SensorAccel: NSObject, SensorTableViewCellDataSource {

  private let manager = CMMotionManager()
  public var sensorTitle: String {
    return "Accel"
  }

  public var updateHandler: (([NSNumber]) -> Void)?

  override init() {
    super.init()
    manager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: {accelData, error in
      if let data = accelData {
        let values = [NSNumber(value:data.acceleration.x),
                      NSNumber(value:data.acceleration.y),
                      NSNumber(value:data.acceleration.z)]

        if let handler = self.updateHandler {
          handler(values)
        }
      }
    })
  }
}
