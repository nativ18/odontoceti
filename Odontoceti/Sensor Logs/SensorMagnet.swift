//
//  SensorMagnet.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/12/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import Foundation
import CoreMotion

class SensorMagnet: NSObject, SensorTableViewCellDataSource {

  private let manager = CMMotionManager()
  public var sensorTitle: String {
    return "Magnet"
  }

  public var updateHandler: (([NSNumber]) -> Void)?

  override init() {
    super.init()
    manager.startMagnetometerUpdates(to: OperationQueue.main, withHandler: {magnetData, error in
      if let data = magnetData {
        let values = [NSNumber(value:data.magneticField.x),
                      NSNumber(value:data.magneticField.y),
                      NSNumber(value:data.magneticField.z)]

        if let handler = self.updateHandler {
          handler(values)
        }
      }
    })
  }
}
