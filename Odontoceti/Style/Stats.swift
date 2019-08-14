//
//  Stats.swift
//  Odontoceti
//
//  Created by Gregory Foster on 3/3/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import Foundation

extension Double {

  func roundTo(places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}

class Stats {
  class func normalPDF(measure: Double, mean: Double, sigma: Double) -> Double {
    let twoSigmaSquared: Double = 2 * pow(sigma, 2)
    return exp(-pow(measure - mean, 2) / twoSigmaSquared) / (pow(Double.pi*twoSigmaSquared, 0.5))
  }
}
