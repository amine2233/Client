//
//  Client.swift
//  Client
//
//  Created by Amine Bensalah on 03/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class Client: ClientProtocol {
    /// The Client error
    public enum Error: Swift.Error, LocalizedError {
        /// The network failure
        case network(Swift.Error, Int)
        /// The remote failure
        case remote(Swift.Error, Int)
        /// The parser failure
        case parser(Swift.Error)
        /// The client error
        case client(String)
        /// The request parameter constuction
        case requestParameters(Swift.Error)
        /// The request unauthorized failure
        case unauthorized(Swift.Error)
        /// The request unauthenticated failure
        case unauthenticated(Swift.Error)
    }

    /// The base url
    public let baseURL: String
    /// The url session
    public let session: URLSession
    /// The http headers
    public var defaultHeaders: [String: String] = [:]


    /// Create a new client
    /// - Parameters:
    ///   - baseURL: The base url
    ///   - session: The url session
    public init(baseURL: String, session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.baseURL = baseURL
        self.session = session
    }


    /// Retrive the `Request` oject
    /// - Parameter request: The `Request` oject
    /// - Returns: return a new `Request`
    open func prepare<T, E>(request: Request<T, E>) -> Request<T, E> {
        return request
    }

    /// Create an url
    /// - Parameter request: The `Request` object, to configure url
    /// - Returns: The `URL`
    open func requestUrl<Resource, Error>(for request: Request<Resource, Error>) -> URL {
        return URL(string: baseURL.appendingPathComponent(request.path))!
    }

    // swiftlint:disable function_body_length
    /// Run the request
    /// - Parameters:
    ///   - request: The `Request` Object
    ///   - completion: The completion block
    /// - Returns: The `URLSessionTask`
    @discardableResult open func perform<Resource, Error>(_ request: Request<Resource, Error>,
                                                          completion: @escaping (Result<Resource, Client.Error>) -> Void)
        -> URLSessionTask {

            var request = prepare(request: request)
            let headers = defaultHeaders.merging(contentsOf: request.headers)
            let url = requestUrl(for: request)

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.method.rawValue
            headers.forEach { urlRequest.addValue($1, forHTTPHeaderField: $0) }

            if let parameters = request.parameters {
                do {
                    urlRequest = try parameters.apply(urlRequest: urlRequest)
                } catch {
                    switch error {
                    case let clientError as Client.Error:
                        completion(.failure(clientError))
                    default:
                        completion(.failure(.client("Not handled error for request apply parameters")))
                    }
                }
            }

            if let body = request.body {
                do {
                    urlRequest = try body.apply(urlRequest: urlRequest)
                } catch {
                    switch error {
                    case let clientError as Client.Error:
                        completion(.failure(clientError))
                    default:
                        completion(.failure(.client("Not handled error for request apply parameters")))
                    }
                }
            }

            let task = self.session.dataTask(with: urlRequest) { (data, urlResponse, error) in
                guard let urlResponse = urlResponse as? HTTPURLResponse else {
                    if let error = error {
                        completion(.failure(.network(error, 0)))
                    } else {
                        completion(.failure(.client("Did not receive HTTPURLResponse. Huh?")))
                    }
                    return
                }

                request.headers
                    .merge(contentsOf: urlResponse.allHeaderFields
                        .map { ($0 as? String, $1 as? String) }
                        .compactMap()
                )

                if let error = error {
                    if let data = data, let serverError = try? request.error(data) {
                        completion(.failure(.remote(serverError, urlResponse.statusCode)))
                    } else {
                        completion(.failure(.network(error, urlResponse.statusCode)))
                    }
                    return
                }

                guard urlResponse.statusCode != 401 else {
                    if let data = data, let error = try? request.error(data) {
                        completion(.failure(.unauthenticated(error)))
                    } else {
                        let message = "HTTP status code unauthorized. Received  \(urlResponse.statusCode)."
                        let error = Client.Error.client(message)
                        completion(.failure(.unauthenticated(error)))
                    }
                    return
                }

                guard urlResponse.statusCode != 403 else {
                    if let data = data, let error = try? request.error(data) {
                        completion(.failure(.unauthorized(error)))
                    } else {
                        let message = "HTTP status code unauthorized. Received  \(urlResponse.statusCode)."
                        let error = Client.Error.client(message)
                        completion(.failure(.unauthorized(error)))
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
