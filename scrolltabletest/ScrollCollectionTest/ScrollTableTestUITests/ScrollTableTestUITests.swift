//
//  ScrollTableTestUITests.swift
//  ScrollTableTestUITests
//
//  Created by Ilya Mikhaltsou on 4/4/19.
//  Copyright © 2019 Ilya Mikhaltsou. All rights reserved.
//

import XCTest

class ScrollTableTestUITests: XCTestCase {

    let application = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        application.launch()
    }

    override func tearDown() {
    }

    func testCellFoundByAccessibilityLabel_visible() {
        application.cells["Accessible Cell 2"].tap()
    }

    func testCellFoundByAccessibilityLabel_invisible() {
        application.cells["Accessible Cell 199"].tap()
    }

    func testCustomCellFoundByLabel_visible() {
        application.cells["Accessible Cell 199"].tap()

        application.cells.staticTexts["Custom Cell 2"].tap()
    }

    func testCustomCellFoundByLabel_invisible() {
        application.cells.staticTexts["Custom Cell 199"].tap()
    }

    func testCustomCellFoundByAccessibilityLabel_visible() {
        application.cells["Accessible Cell 199"].tap()

        application.cells["Accessible Custom Cell 2"].tap()
    }

    func testCustomCellFoundByAccessibilityLabel_invisible_fails() {
        application.cells["Accessible Custom Cell 199"].tap()
    }

}
