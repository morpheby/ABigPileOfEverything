//
//  TableCell.swift
//  ScrollTableTest
//
//  Created by Ilya Mikhaltsou on 4/4/19.
//  Copyright © 2019 Ilya Mikhaltsou. All rights reserved.
//

import UIKit

class TableCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
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


