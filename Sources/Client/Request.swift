//
//  Request.swift
//  Client
//
//  Created by Amine Bensalah on 03/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The request method type
public enum HTTPMethod: String {
    case get    = "GET"
    case put    = "PUT"
    case post   = "POST"
    case patch  = "PATCH"
    case delete = "DELETE"
    case head   = "HEAD"
}

/// The request builder `Request<Resource, Error: Swift.Error>`
public struct Request<Resource, Error: Swift.Error> {
    /// The request path
    public var path: String
    /// The request method type `HTTPMethod`
    public var method: HTTPMethod
    /// The query parameters
    public var parameters: RequestParameters?
    /// The content body
    public var body: RequestParameters?
    /// The headers parameters
    public var headers: [String: String]
    /// The resource parser, use this callback to parse a success response
    public var resource: (Data) throws -> Resource  // Resource parser
    /// The failure parser, use this callback to parse a failure response
    public var error: (Data) throws -> Error        // Error parser

    /// Create a new Request
    public init(path: String,
                method: HTTPMethod,
                parameters: RequestParameters? = nil,
                body: RequestParameters? = nil,
                headers: [String: String] = [:],
                resource: @escaping (Data) throws -> Resource,
                error: @escaping (Data) throws -> Error) {

        self.path = path
        self.method = method
        self.parameters = parameters
        self.body = body
        self.headers = headers
        self.resource = resource
        self.error = error
    }
}

extension Request {
    /// Send a request and get a `URLSessionTask`
    @discardableResult
    public func response(using client: Client, completion: @escaping (Result<Resource,Client.Error>) -> Void) -> URLSessionTask {
        return client.perform(self, completion: completion)
    }

    public mutating func set(_ value: String?, forHttpHeaderKey key: String) {
        var headers = self.headers
        headers[key] = value
        self.headers = headers
    }
}
