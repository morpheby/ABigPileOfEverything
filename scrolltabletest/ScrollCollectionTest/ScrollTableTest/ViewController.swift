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
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "basic")
        collectionView.register(TableCell.self, forCellWithReuseIdentifier: "custom")
    }

}

extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "basic", for: indexPath)

            cell.accessibilityLabel = "Accessible Cell \(indexPath.row)"
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "custom", for: indexPath) as! TableCell

            cell.customLabel.text = "Custom Cell \(indexPath.row)"
            cell.accessibilityLabel = "Accessible Custom Cell \(indexPath.row)"
            return cell
        default:
            fatalError()
        }
    }

}

