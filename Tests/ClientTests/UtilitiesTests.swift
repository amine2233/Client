//
//  ClientTests.swift
//  ClientTests
//
//  Created by Amine Bensalah on 23/06/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import XCTest
@testable import Client

class UtilitiesTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppendingPathComponent() {
        // Given
        let urlString = "http://intech-consulting.fr"
        // When
        let appendingPathComponent = urlString.appendingPathComponent("v1/users/login")
        // Than
        XCTAssertEqual(appendingPathComponent, "http://intech-consulting.fr/v1/users/login")
    }

    static var allTests = [
        ("testAppendingPathComponent", testAppendingPathComponent),
    ]
}
