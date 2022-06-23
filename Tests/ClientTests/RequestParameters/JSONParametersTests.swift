//
//  JSONParameters.swift
//  ClientTests
//
//  Created by Amine Bensalah on 17/05/2020.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Client

class JSONParametersTests: XCTestCase {

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    func testWhenCreateJSONParameters() throws {
        let id = "9879874"
        let urlString = "http://apple.com"
        guard let url = URL(string: urlString) else { XCTFail("Can't create an url"); return }
        var urlRequest = URLRequest(url: url)
        var json: [String: Any] = [:]
        json["id"] = id
        let jsonParameters = JSONParameters(json)
        try jsonParameters.apply(urlRequest: &urlRequest)

        XCTAssertNotNil(urlRequest.httpBody)

        guard let httpBody = urlRequest.httpBody else { XCTFail("Can't read httpBody"); return }
        let data = try JSONSerialization.jsonObject(with: httpBody, options: [])
        guard let newJSON = data as? [String: Any] else { XCTFail("Can't create new json"); return }

        XCTAssertEqual(newJSON["id"] as? String, id)
    }
}
