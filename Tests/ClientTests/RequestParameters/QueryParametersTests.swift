//
//  QueryParametersTests.swift
//  ClientTests
//
//  Created by Amine Bensalah on 17/05/2020.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Client

class QueryParametersTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWhenCreateQueryParameters() throws {
        let urlString = "http://api.rest.com"
        guard let url = URL(string: urlString) else { XCTFail("Can't create an url"); return }
        var urlRequest = URLRequest(url: url)

        var queriesParameters: [String: String] = [:]

        queriesParameters["query"] = "test"
        queriesParameters["location"] = "london"

        let queryParameter = QueryParameters(queriesParameters)
        queryParameter.apply(urlRequest: &urlRequest)

        guard let newURL = urlRequest.url else {
            XCTFail("Can't create an url");
            return
        }

        XCTAssertTrue(newURL.absoluteString.contains("location=london"))
        XCTAssertTrue(newURL.absoluteString.contains("query=test"))
    }
}
