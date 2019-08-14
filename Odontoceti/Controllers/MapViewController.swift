//
//  MapViewController.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/20/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    private lazy var userArrowView: UserArrowView = {
        let _userArrowView = UserArrowView(frame:CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
        return _userArrowView
    }()

    /// Update this computed variable to move the user point view.
    public var deadReckoningPos: CGPoint {
        set {
            UIView.animate(withDuration: MotionModel.sharedModel.rate, animations: {
                self.userArrowView.center = newValue
                let orientation = CGFloat(OrientationModel.sharedModel.orientation)
                self.userArrowView.transform = CGAffineTransform(rotationAngle: orientation)
            })
        }
        get {
            return userArrowView.frame.origin
        }
    }

    private var pauseFiltering: Bool = true

    var particleDistView = ParticleDistributionView(data:Map.sharedMap.particleDistribution())

    lazy var tiles: [Point: UIView] = {
        var _tiles = [Point: UIView]()
        for p in Map.sharedMap.points {
            _tiles[p] = (UIView())
        }
        return _tiles
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        tabBarItem.title = "Localizer"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.magneticReading(note:)),
                                               name: MagnetModel.updateNotificationName,
                                               object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let chartHeight: CGFloat = 60.0
        let w: CGFloat = CGFloat(view.width) / CGFloat(Map.sharedMap.gridSize)
        let h: CGFloat = (view.height - chartHeight) / CGFloat(Map.sharedMap.gridSize)

        print("width = \(view.width). height = \(view.height)")
        particleDistView.frame = CGRect(x: 0,
                                                y: 0,
                                                width: view.width,
                                                height: chartHeight)
        view.addSubview(particleDistView)

        for p in Map.sharedMap.points {
            if let tile = tiles[p] {
                tile.frame = CGRect(x: CGFloat(p.xLoc) * w,
                                    y: chartHeight + CGFloat(p.yLoc) * h,
                                    width: w,
                                    height: h)
                view.addSubview(tile)
            }
        }
        view.addSubview(userArrowView)
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(pannedArrow(gesture:)))
        view.addGestureRecognizer(panGesture)
        let rotateGesture = UIRotationGestureRecognizer(target: self,
                                                        action: #selector(rotatedArrow(gesture:)))
        view.addGestureRecognizer(rotateGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        pauseFiltering = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        pauseFiltering = true
    }

    private func updateTiles() {
        for p in Map.sharedMap.points {
            if let tile = tiles[p] {
                let likelihood = Map.sharedMap.likelihood(point:p)
                tile.backgroundColor = UIColor.colorBetween(color: .black,
                                                            andColor: .white,
                                                            percent: CGFloat(likelihood))
            }
        }
    }

    @objc func magneticReading(note: Notification) {
        if !pauseFiltering {
            if let magnitude = note.userInfo?["value"] as? Double {
                Map.sharedMap.updateWeights(measurement: magnitude)
                updateTiles()
                particleDistView.data = Map.sharedMap.particleDistribution()
            }
            // Update the deadReckoning position while we're at it.
            deadReckoningPos = DeadReckoningModel.sharedModel.currentLocation
        }
    }

    @objc func pannedArrow(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            _ = gesture.translation(in: self.view)
//            DeadReckoningModel.sharedModel.currentLocation.x += change.x
//            DeadReckoningModel.sharedModel.currentLocation.y += change.y
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        }
    }

    @objc func rotatedArrow(gesture: UIRotationGestureRecognizer) {
        if gesture.state == .changed {
            OrientationModel.sharedModel.offset += Double(gesture.rotation)
            gesture.rotation = 0
        }
    }
}
