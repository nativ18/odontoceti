//
//  DeadReckoningModel.swift
//  Odontoceti
//
//  Created by Gregory Foster on 3/19/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import UIKit
import Surge
import Accelerate

class DeadReckoningModel: NSObject {

    /// The current dead reckoning estimation for the user location, speed, & acceleration.
    private var x: Matrix = Matrix([[0.0, 0.0, 0.0, 0.0, 0.0, 0.0]])

    private let dt: Double = MotionModel.sharedModel.rate

    private let Q: Matrix<Double>

    private var P: Matrix = Matrix([[10.0, 0, 0, 0, 0, 0],
                             [0, 10.0, 0, 0, 0, 0],
                             [0, 0, 10.0, 0, 0, 0],
                             [0, 0, 0, 10.0, 0, 0],
                             [0, 0, 0, 0, 10.0, 0],
                             [0, 0, 0, 0, 0, 10.0]])

    private let H: Matrix = Matrix([[0.0, 0.0, 0.0, 0.0, 1.0, 1.0]])

    var currentLocation: CGPoint {
        return CGPoint(x: H[0,0], y: H[0,1])
    }
    
    private let A: Matrix<Double>

    private let I: Matrix = Matrix([[1.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                             [0.0, 1.0, 0.0, 0.0, 0.0, 0.0],
                             [0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
                             [0.0, 0.0, 0.0, 1.0, 0.0, 0.0],
                             [0.0, 0.0, 0.0, 0.0, 1.0, 0.0],
                             [0.0, 0.0, 0.0, 0.0, 0.0, 1.0]])

    private let R: Matrix = Matrix([[100.0, 0.0],
                             [0.0, 100.0]])

    /// The class singleton.
    static let sharedModel = DeadReckoningModel()

    override init() {
        A = Matrix([[1.0, 0.0, dt, 0.0, 0.5 * dt * dt, 0.0],
             [0.0, 1.0, 0.0, dt, 0.0, 0.5 * dt * dt],
             [0.0, 0.0, 1.0, 0.0, dt, 0.0],
             [0.0, 0.0, 0.0, 1.0, 0.0, dt],
             [0.0, 0.0, 0.0, 0.0, 1.0, 0.0],
             [0.0, 0.0, 0.0, 0.0, 0.0, 1.0]])

        let sa = 0.1
        let G: Matrix = Matrix([[1/2.0*dt*dt],
                         [1/2.0*dt*dt],
                         [dt],
                         [dt],
                         [1.0],
                         [1.0]])
//        let ggt = G * G.T
//        let ggtSa = ggt ** Float(sa)
//        Q = ggtSa ** Float(sa)
        Q = ((G * G.T) ** Float(sa)) ** Float(sa) //  matrix * matrix * double * double
        

        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(updateModel(note:)),
                                               name: MotionModel.updateNotificationName,
                                               object: nil)
    }

    /// Update the dead reckoning estimate based on a new accelerometer reading.
    @objc func updateModel(note: Notification) {note
        print("updaing model 1")
        if let accelX = note.userInfo?["accelX"] as? Double,
                let accelY = note.userInfo?["accelY"] as? Double {
            print("updaing model 2")

            let Z: Matrix = Matrix([[0.0, 0.0, 0.0, 0.0, accelX, accelY]])
            // Time Update (Prediction);
            // ========================
            // Project the state ahead
            x = A * x

            // Project the error covariance ahead
            P = A * P * A.T + Q

            
            // Measurement Update (Correction)
            // ===============================
            // Compute the Kalman Gain
            let S = H*P*H.T + R
            let K = (P*H.T) * S


            // Update the estimate via z
//            let y: Matrix<Double> = Z - (H*x)
            let y: Matrix<Double> = Z - (H*x)

            x = x + (K*y)

            // Update the error covariance
            P = (I - (K*H))*P


            // Project the state ahead.

//            state[0] = state[0] + state[2] * dt + state[4] * 0.5 * dt * dt
//            state[1] = state[1] + state[3] * dt + state[5] * 0.5 * dt * dt

            // Project the error covariance ahead.
            // IMPLEMENT LATER

            // Kalman Gain
            // Select bottom 4 elements from 6x6 array P, add [[ra, 0.0], [0.0, ra]])
            //
//            let ra = 100
//            let s =
//
//            let R = 10 // estimate of covariance.
//            let Q = 1e-5 // process variance.
//
//            let k_x = p_x/(p_x + R)
//            let k_y = p_y/(p_y + R)
//
//            // Update the estimate.
//            state[4] += k_x * (accelX - state[4])
//            state[5] += k_y * (accelY - state[5])



//            let metersToPixels: CGFloat = 1000.0
//            let orientation = OrientationModel.sharedModel.orientation
//
//            speed.x -= CGFloat(accelX) * metersToPixels * CGFloat(MotionModel.sharedModel.rate)
//            speed.y -= CGFloat(accelY) * metersToPixels * CGFloat(MotionModel.sharedModel.rate)
//            speed.x *= 0.5
//            speed.y *= 0.5
//
//            print(speed)
//
//            // Calculate the north/south, and the east/west distance in pixels.
//            let northSouthDistance = Double(speed.x)
//            let eastWestDistance = Double(speed.y)
//
//            // Apply the northSouthDistance to the translation
//            currentLocation.x += CGFloat(cos(orientation) * northSouthDistance)
//            currentLocation.y += CGFloat(sin(orientation) * northSouthDistance)
//
//            // Apply the eastWestDistance to the translation
//            currentLocation.x += CGFloat(sin(orientation) * eastWestDistance)
//            currentLocation.y -= CGFloat(cos(orientation) * eastWestDistance)
//
//            // Ensure that the arrow does not move out of bounds
//            currentLocation.x = min(currentLocation.x, UIScreen.main.bounds.width)
//            currentLocation.x = max(currentLocation.x, 0)
//            currentLocation.y = min(currentLocation.y, UIScreen.main.bounds.height)
//            currentLocation.y = max(currentLocation.y, 0)
        }
    }
}

extension Matrix where Scalar: FloatingPoint, Scalar: ExpressibleByFloatLiteral {
    
    // Convinience method to keep Linear framework APIs
    var T: Matrix<Double> {
        // TODO
        return transpose(self as! Matrix<Double>)
    }
}

fileprivate func - (left: Matrix<Double>, right: Matrix<Double>) -> Matrix<Double> {
    precondition(left.rows == right.rows && left.columns == right.columns, "Matrix dimensions not compatible with substraction")
    var result = Matrix<Double>(rows: left.rows, columns: left.columns, repeatedValue: 0)
    for row in 0..<left.rows {
        for column in 0..<left.columns {
            result[row, column] = Double(left[row, column] - right[row, column])
        }
    }
    return result
}

// https://developer.apple.com/documentation/accelerate/1513354-cblas_sscal
infix operator **
fileprivate func ** (matrix: Matrix<Double>, scalar: Float) -> Matrix<Double> {
   
    let columns = matrix.columns
    var grid = [Float](repeating: 0.0, count: matrix.rows * matrix.columns)
    let uint8Pointer = UnsafeMutablePointer<Float>.allocate(capacity: grid.count)
    uint8Pointer.initialize(from: &grid, count: grid.count)

    // Accepts only pointer to Float buffer
    cblas_sscal(Int32(matrix.rows * matrix.columns), scalar, uint8Pointer, 1)
    
    let gridResult = grid.chunked(into: columns)
    return Matrix<Double>(gridResult)
}

extension Array where Iterator.Element == Float {
    func chunked(into size: Int) -> [[Double]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)]).map{ Double($0) }
        }
    }
}
