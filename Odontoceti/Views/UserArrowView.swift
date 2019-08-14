//
//  UserArrowView.swift
//  Odontoceti
//
//  Created by Gregory Foster on 3/19/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import UIKit

class UserArrowView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        context.closePath()
        context.setFillColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.fillPath()
    }
}
