//
//  FormParametersTests.swift
//  Client
//
//  Created by Amine Bensalah on 17/05/2020.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Client

class FormParametersTests: XCTestCase {

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    func testWhenFormParametersTests() throws {
        let urlString = "http://apple.com"
        guard let url = URL(string: urlString) else { XCTFail("Can't create an url"); return }
        let urlRequest = URLRequest(url: url)
        var data: [String : Any] = [:]
        data["Cache-Control"] = "no-cache"
        let formParameters = FormParameters(data)
        let newURLRequest = formParameters.apply(urlRequest: urlRequest)

        XCTAssertEqual(newURLRequest.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded;charset=UTF-8")
    }
}

