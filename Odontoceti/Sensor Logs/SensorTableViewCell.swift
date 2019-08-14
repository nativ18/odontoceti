//
//  SensorTableViewCell.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/12/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import UIKit

protocol SensorTableViewCellDataSource {
  var sensorTitle: String {get}
  var updateHandler: (([NSNumber]) -> Void)? {get set}
}

class SensorTableViewCell: UITableViewCell {

  public class var reuseIdentifier: String {
    return "SensorTableViewCell"
  }

  lazy var titleLabel: UILabel = {
    let _titleLabel = UILabel()
    _titleLabel.textColor = .white
    _titleLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
    return _titleLabel
  }()

  lazy var dataLabelX: UILabel = {
    let _dataLabel = UILabel()
    _dataLabel.textColor = .white
    _dataLabel.font = UIFont.systemFont(ofSize: 20.0)
    return _dataLabel
  }()

  lazy var dataLabelY: UILabel = {
    let _dataLabel = UILabel()
    _dataLabel.textColor = .white
    _dataLabel.font = UIFont.systemFont(ofSize: 20.0)
    return _dataLabel
  }()

  lazy var dataLabelZ: UILabel = {
    let _dataLabel = UILabel()
    _dataLabel.textColor = .white
    _dataLabel.font = UIFont.systemFont(ofSize: 20.0)
    return _dataLabel
  }()

  public var dataSource: SensorTableViewCellDataSource? {
    get {
      fatalError("You cannot read from this object.")
    }
    set {
      if var ds = newValue {
        ds.updateHandler = sensorDataDidChange
        self.titleLabel.text = ds.sensorTitle
      }
    }
  }

  public func sensorDataDidChange(values: [NSNumber]) {
    dataLabelX.text = values[0].stringValue
    dataLabelY.text = values[1].stringValue
    dataLabelZ.text = values[2].stringValue
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let margin: CGFloat = 20.0
    titleLabel.frame = CGRect(x: margin,
                              y: margin,
                              width: width/2.0 - margin * 2,
                              height: height - margin * 2)

    dataLabelX.frame = CGRect(x: margin + width / 2.0,
                              y: margin,
                              width: width/2.0 - margin * 2,
                              height: (height - margin * 2)/3)

    dataLabelY.frame = CGRect(x: dataLabelX.xOrigin,
                              y: margin + dataLabelX.height,
                              width: dataLabelX.width,
                              height: dataLabelX.height)

    dataLabelZ.frame = CGRect(x: dataLabelX.xOrigin,
                              y: margin + dataLabelX.height * 2,
                              width: dataLabelX.width,
                              height: dataLabelX.height)

    addSubview(titleLabel)
    addSubview(dataLabelX)
    addSubview(dataLabelY)
    addSubview(dataLabelZ)
    backgroundColor = .clear
  }
}
