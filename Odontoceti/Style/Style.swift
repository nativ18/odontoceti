//
//  style.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/12/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import UIKit

extension UIColor {
  public class var odoBlue: UIColor {
    return UIColor(red: 0.02745098039, green: 0.003921568627, blue: 0.1411764706, alpha: 1)
  }

  class func colorBetween(color: UIColor, andColor: UIColor, percent: CGFloat) -> UIColor {
    var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
    var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))

    color.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    andColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

    return UIColor(
      red: r1 + percent * (r2 - r1),
      green: g1 + percent * (g2 - g1),
      blue:  b1 + percent * (b2 - b1),
      alpha: a1 + percent * (a2 - a1))
  }
}

extension UIView {
  public var width: CGFloat {
    return self.bounds.width
  }

  public var height: CGFloat {
    return self.bounds.height
  }

  public var yOrigin: CGFloat {
    return self.frame.origin.y
  }

  public var xOrigin: CGFloat {
    return self.frame.origin.x
  }
}
