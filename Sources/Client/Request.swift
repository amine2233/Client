//
//  Request.swift
//  Client
//
//  Created by Amine Bensalah on 03/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
}

public struct Request<Resource, Error: Swift.Error> {

    public var path: String
    public var method: HTTPMethod
    public var parameters: RequestParameters?
    public var headers: [String: String]?
    public var resource: (Data) throws -> Resource  // Resource parser
    public var error: (Data) throws -> Error        // Error parser

    public init(path: String,
                method: HTTPMethod,
                parameters: RequestParameters? = nil,
                headers: [String: String]? = nil,
                resource: @escaping (Data) throws -> Resource,
                error: @escaping (Data) throws -> Error) {

        self.path = path
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.resource = resource
        self.error = error
    }
}

extension Request {

    @discardableResult
    public func response(using client: Client, completion: @escaping (Result<Resource,Client.Error>) -> Void) -> URLSessionTask {
        return client.perform(self, completion: completion)
    }

    public mutating func set(_ value: String?, forHttpHeaderKey key: String) {
        var headers = self.headers ?? [:]
        headers[key] = value
        self.headers = headers
    }
}
