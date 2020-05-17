//
//  BasicAuthTests.swift
//  ClientTests
//
//  Created by Amine Bensalah on 17/05/2020.
//

import XCTest
@testable import Client

class BasicAuthTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateBasicAuth() throws {
        let auth = try BasicAuth.createBasicAuth(username: "login", password: "pass")
        XCTAssertEqual(auth, "bG9naW46cGFzcw==")
    }
}
