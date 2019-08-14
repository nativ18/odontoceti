//
//  MagnetGrid.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/12/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import UIKit

/// The view in which the user builds up a map of magnetic readings by selecting tiles.
class CartographerViewController: UIViewController {

    /// Each tile / button is arranged in a grid and therefore needs corresponding coordinates.
    var buttonLocations = [UIButton: Point]()

    /// The tile / button that is currently selected. There might be nothing that is selected.
    var curButton: UIButton?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        tabBarItem.title = "Mapper"
        for y in 0..<Map.sharedMap.gridSize {
            for x in 0..<Map.sharedMap.gridSize {
                let cur = UIButton()
                cur.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
                buttonLocations[cur] = Point(xLoc: x, yLoc: y)
            }
        }
        // Watch for notifications from MagnetModel
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.magneticReading(note:)),
                                               name: MagnetModel.updateNotificationName,
                                               object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Handle notifications containing the current magnitude reading for the phone.
     - parameter note: The notification containing the magnitude.
     */
    @objc private func magneticReading(note: Notification) {
        if let button = curButton, let mag = note.userInfo?["value"] as? Double {
            Map.sharedMap.update(location:buttonLocations[button]!, value:mag)
            for (button, path) in self.buttonLocations {
                let nVal = Map.sharedMap.normalizedValueFor(location: path)
                let val = Map.sharedMap.valueFor(location: path)
                button.backgroundColor = UIColor.colorBetween(color: .blue,
                                                              andColor: .red,
                                                              percent: CGFloat(nVal))
                button.setTitle(String(format: "%.0f", val), for: .normal)
            }
        }
    }

    /// When the view loads, setup all the buttons on the screen to form a grid.
    override func viewDidLayoutSubviews() {
        for (button, point) in buttonLocations {
            let x = point.xLoc
            let y = point.yLoc
            button.frame = CGRect(x: view.width * CGFloat(x) / CGFloat(Map.sharedMap.gridSize),
                                  y: view.height * CGFloat(y) / CGFloat(Map.sharedMap.gridSize),
                                  width: view.width / CGFloat(Map.sharedMap.gridSize),
                                  height: view.height / CGFloat(Map.sharedMap.gridSize))
            button.backgroundColor = UIColor.colorBetween(color: .red,
                                                          andColor: .blue,
                                                          percent: 0.5)
            button.titleLabel?.textColor = .white
            view.addSubview(button)
        }
    }

    // Highlight a button when it is selected.
    @objc func buttonPressed(button: UIButton) {
        if let curButton = curButton, button == curButton {
            curButton.layer.borderWidth = 0.0
            self.curButton = nil
        } else {
            curButton?.layer.borderWidth = 0.0
            curButton = button
            button.layer.borderWidth = 5.0
            button.layer.borderColor = UIColor.white.cgColor
        }
    }
}
