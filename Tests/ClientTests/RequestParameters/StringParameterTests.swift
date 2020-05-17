//
//  StringParameterTests.swift
//  ClientTests
//
//  Created by Amine Bensalah on 17/05/2020.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Client

class StringParameterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWhenCreateStringParameter() throws {

        let urlString = "http://api.rest.com"
        guard let url = URL(string: urlString) else { XCTFail("Can't create an url"); return }
        let urlRequest = URLRequest(url: url)

        let randomString = String.random(length: 10)
        let stringParameter = StringParameter(randomString)
        let newURLRequest = stringParameter.apply(urlRequest: urlRequest)

        guard let data = newURLRequest.httpBody else {
            XCTFail("Can't create an url");
            return
        }

        XCTAssertEqual(String(data: data, encoding: .utf8), randomString)
    }
}

extension String {
    static func random(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
