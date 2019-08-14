//
//  MagnetModel.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/20/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import Foundation
import CoreLocation


/// The the store of information about the current magnetic readings from the phone.
class OrientationModel: NSObject, CLLocationManagerDelegate {

    /// The name for the notification which contains the latest measured magnet magnitude.
    public static var updateNotificationName = Notification.Name(rawValue: "OrientationUpdate")

    /// The class singleton.
    static let sharedModel = OrientationModel()

    /// The manager which tracks and provides measurements from the magnet which are then passed on.
    private let locationManager = CLLocationManager()

    /// The raw value provided by the systems compass determining phone orientation.
    private var _rawHeading: Double = 0

    /// The user inputted rotation offset.
    private var _offset: Double = 0

    /// The calculated oriention of the phone in radians, which considers the offset.
    public var orientation: Double {
        get {
             return _rawHeading.truncatingRemainder(dividingBy: 360.0) / 180.0 * .pi + offset
        }
    }

    // When the offset is changed, recaculate and post the orientation.
    public var offset: Double {
        set {
            _offset = newValue
            postOrientation()
        }
        get {
            return _offset
        }
    }

    override init() {
        super.init()
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways:
                self.locationManager.delegate = self
                self.locationManager.startUpdatingHeading()
            case .notDetermined:
                self.locationManager.requestAlwaysAuthorization()
            default:
                objc_exception_throw(NSException(name: .genericException,
                                                 reason: "Location Permission not granted",
                                                 userInfo: nil))
        }
    }

    func locationManager(_ manager: CLLocationManager,
                                 didUpdateHeading newHeading: CLHeading) {
        _rawHeading = newHeading.magneticHeading
        postOrientation()
    }

    private func postOrientation() {
        print("b")
        NotificationCenter.default.post(name: OrientationModel.updateNotificationName,
                                        object: nil,
                                        userInfo: ["orientation": orientation])
    }
}
