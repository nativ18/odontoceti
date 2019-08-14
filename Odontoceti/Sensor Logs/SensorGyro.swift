//
//  SensorGyro.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/12/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import Foundation
import CoreMotion

class SensorGyro: NSObject, SensorTableViewCellDataSource {

  private let manager = CMMotionManager()
  public var sensorTitle: String {
    return "Gyroscope"
  }

  public var updateHandler: (([NSNumber]) -> Void)?

  override init() {
    super.init()
    manager.startGyroUpdates(to: OperationQueue.main, withHandler: {gyroData, error in
      if let data = gyroData {
        let values = [NSNumber(value:data.rotationRate.x),
                      NSNumber(value:data.rotationRate.y),
                      NSNumber(value:data.rotationRate.z)]

        if let handler = self.updateHandler {
          handler(values)
        }
      }
    })
  }
}
