//
//  ViewController.swift
//  ScrollTableTest
//
//  Created by Ilya Mikhaltsou on 4/4/19.
//  Copyright © 2019 Ilya Mikhaltsou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "basic")
        tableView.register(TableCell.self, forCellReuseIdentifier: "custom")

        tableView.accessibilityIdentifier = "Hey"
    }

}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 200
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)

            cell.textLabel?.text = "Cell \(indexPath.row)"
            cell.accessibilityLabel = "Accessible Cell \(indexPath.row)"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "custom", for: indexPath) as! TableCell

            cell.customLabel.text = "Custom Cell \(indexPath.row)"
            cell.accessibilityLabel = "Accessible Custom Cell \(indexPath.row)"
            cell.customLabel.accessibilityIdentifier = "custom.cell.\(indexPath.row)"
            return cell
        default:
            fatalError()
        }
    }
}

