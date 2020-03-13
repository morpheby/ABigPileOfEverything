//
//  TableCell.swift
//  ScrollTableTest
//
//  Created by Ilya Mikhaltsou on 4/4/19.
//  Copyright © 2019 Ilya Mikhaltsou. All rights reserved.
//

import UIKit

class TableCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    var customLabel = UILabel(frame: .zero)

    private func setupView() {
        contentView.addSubview(customLabel)
        customLabel.frame = contentView.bounds
    }

}


