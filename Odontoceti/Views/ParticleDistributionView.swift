//
//  particleDistribution.swift
//  Odontoceti
//
//  Created by Gregory Foster on 3/3/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

//

import UIKit

/// A lightweight graph view that draws a simple bar chart.
class ParticleDistributionView: UIView {

    var data = [Double]() {
        didSet(oldValue) {
            if data != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    init(data: [Double]) {
        super.init(frame: CGRect.null)
        self.data = data
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {

        if data.count > 0 {
            let h = rect.height
            let w = rect.width / CGFloat(data.count)

            for (i, val) in data.enumerated() {
                let color: UIColor = .blue

                let drect = CGRect(x: w*CGFloat(i),
                                   y: h - h*CGFloat(val),
                                   width: w,
                                   height: h*CGFloat(val))
                let bpath: UIBezierPath = UIBezierPath(rect: drect)

                color.set()
                bpath.fill()
            }
        }
    }
}
