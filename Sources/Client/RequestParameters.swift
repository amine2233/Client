//
//  RequestParameters.swift
//  Client
//
//  Created by Amine Bensalah on 03/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol RequestParameters {
    func apply(urlRequest: URLRequest) throws -> URLRequest
}

/// Create a `FormParameters`
public struct FormParameters: RequestParameters {
    public let data: [String: Any]

    public init(_ data: [String: Any]) {
        self.data = data
    }

    public func apply(urlRequest: URLRequest) -> URLRequest {
        var request = urlRequest
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data.keyValuePairs.data(using: .utf8)
        return request
    }
}

/// Create a `JSONParameters`
public struct JSONParameters: RequestParameters {
    public let json: Any

    public init(_ json: Any) {
        self.json = json
    }

    public func apply(urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = data
        } catch {
            throw Client.Error.requestParameters(error)
        }

        return request
    }
}

/// Create a `QueryParameters`
public struct QueryParameters: RequestParameters {
    public let query: [String: String]

    public init(_ query: [String: String]) {
        self.query = query
    }

    public func apply(urlRequest: URLRequest) -> URLRequest {
        var request = urlRequest
        var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        var items = urlComponents.queryItems ?? []
        items.append(contentsOf: query.map { URLQueryItem(name: $0.key, value: $0.value) })
        urlComponents.queryItems = items
        request.url = urlComponents.url
        return request
    }
}

/// Create a `StringParameter` 
public struct StringParameter: RequestParameters {
    public let string: String

    public init(_ string: String) {
        self.string = string
    }

    public func apply(urlRequest: URLRequest) -> URLRequest {
        var request = urlRequest
        request.httpBody = string.data(using: .utf8)
        return request
    }
}

/// Create a body with `Encodable` object
public struct EncodableParameter<T: Encodable>: RequestParameters {
    public let model: T

    public init(_ model: T) {
        self.model = model
    }

    public func apply(urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try JSONEncoder().encode(model)
            request.httpBody = data
        } catch {
            throw Client.Error.requestParameters(error)
        }

        return request
    }
}
