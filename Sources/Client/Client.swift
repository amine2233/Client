//
//  Client.swift
//  Client
//
//  Created by Amine Bensalah on 03/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

open class Client {
    public enum Error: Swift.Error, LocalizedError {
        case network(Swift.Error, Int)
        case remote(Swift.Error, Int)
        case parser(Swift.Error)
        case client(String)
    }

    public let baseURL: String
    public let session: URLSession
    public var defaultHeaders: [String: String] = [:]

    public init(baseURL: String, session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.baseURL = baseURL
        self.session = session
    }

    /// For example, authorize request with the token.
    open func prepare<T, E>(request: Request<T, E>) -> Request<T, E> {
        return request
    }

    open func requestUrl<Resource, Error>(for request: Request<Resource, Error>) -> URL {
        return URL(string: baseURL.appendingPathComponent(request.path))!
    }

    /// Perform request.
    // swiftlint:disable function_body_length
    @discardableResult
    open func perform<Resource, Error>(_ request: Request<Resource, Error>,
                                       completion: @escaping (Result<Resource, Client.Error>) -> Void) -> URLSessionTask {

        let request = prepare(request: request)
        let headers = defaultHeaders.merging(contentsOf: request.headers ?? [:])
        let url = requestUrl(for: request)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        headers.forEach { urlRequest.addValue($1, forHTTPHeaderField: $0) }

        if let parameters = request.parameters {
            urlRequest = parameters.apply(urlRequest: urlRequest)
        }

        #if (os(iOS) || os(watchOS) || os(tvOS))
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        #endif

        let task = self.session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            #if (os(iOS) || os(watchOS) || os(tvOS))
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            #endif

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                if let error = error {
                    completion(.failure(.network(error, 0)))
                } else {
                    completion(.failure(.client("Did not receive HTTPURLResponse. Huh?")))
                }
                return
            }

            if let error = error {
                if let data = data, let serverError = try? request.error(data) {
                    completion(.failure(.remote(serverError, urlResponse.statusCode)))
                } else {
                    completion(.failure(.network(error, urlResponse.statusCode)))
                }
                return
            }

            guard (200..<300).contains(urlResponse.statusCode) else {
                if let data = data, let error = try? request.error(data) {
                    completion(.failure(.remote(error, urlResponse.statusCode)))
                } else {
                    let message = "HTTP status code validation failed. Received  \(urlResponse.statusCode)."
                    let error = Client.Error.client(message)
                    completion(.failure(.remote(error, urlResponse.statusCode)))
                }
                return
            }

            if let data = data {
                do {
                    let resource = try request.resource(data)
                    completion(.success(resource))
                } catch let error as Client.Error {
                    completion(.failure(error))
                } catch let error {
                    completion(.failure(.parser(error)))
                }
            } else {
                // no error, no data - valid empty response
                do {
                    let resource = try request.resource(Data())
                    completion(.success(resource))
                } catch let error as Client.Error {
                    completion(.failure(error))
                } catch let error {
                    completion(.failure(.parser(error)))
                }
            }
        }

        task.resume()
        return task
    }
    // swiftlint:enable function_body_length
}

extension Client.Error {

    public var code: Int? {
        switch self {
        case .network(_, let code):
            return code
        case .remote(_, let code):
            return code
        default:
            return 0
        }
    }

    public var errorDescription: String? {
        switch self {
        case .network(let error, _):
            return error.localizedDescription
        case .remote(let error, _):
            return error.localizedDescription
        case .parser(let error):
            return error.localizedDescription
        case .client(let message):
            return message
        }
    }
}
