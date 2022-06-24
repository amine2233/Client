//
//  EncodableParameterTests.swift
//  ClientTests
//
//  Created by Amine Bensalah on 17/05/2020.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Client

class EncodableParameterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWhenCreateEncodableParameter() throws {
        let urlString = "http://api.rest.com"
        guard let url = URL(string: urlString) else { XCTFail("Can't create an url"); return }
        var urlRequest = URLRequest(url: url)

        let user = Login(username: "client", password: "client")
        let encodableParameter = EncodableParameter(user)
        try encodableParameter.apply(urlRequest: &urlRequest)

        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/json")

        guard let httpBody = urlRequest.httpBody else {
            XCTFail("Can't read httpBody");
            return
        }

        let requestUser = try JSONDecoder().decode(Login.self, from: httpBody)

        XCTAssertEqual(requestUser.username, user.username)
        XCTAssertEqual(requestUser.password, user.password)
    }
}

private struct Login: Codable {
    let username: String
    let password: String
}
