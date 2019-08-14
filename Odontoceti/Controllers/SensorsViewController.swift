//
//  ViewController.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/12/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//

import UIKit

class SensorsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        tabBarItem.title = "Sensors"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var tableView: UITableView = {
        let _tableView = UITableView()
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.alwaysBounceVertical = true
        _tableView.backgroundColor = UIColor.clear
        _tableView.register(SensorTableViewCell.self,
                            forCellReuseIdentifier: SensorTableViewCell.reuseIdentifier)
        return _tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .odoBlue

        tableView.frame = view.bounds
        view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDatasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: SensorTableViewCell.reuseIdentifier) as? SensorTableViewCell {
            switch indexPath.row {
            case 0: cell.dataSource = SensorGyro()
            case 1: cell.dataSource = SensorAccel()
            case 2: cell.dataSource = SensorMagnet()
            default: cell.dataSource = nil
        }
            return cell
        }
        return UITableViewCell()
    }
}
