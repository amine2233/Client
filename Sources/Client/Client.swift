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

public protocol URLSessionServiceTask {
    func resume()
    func cancel()
}

extension URLSessionDataTask: URLSessionServiceTask { }

final class URLSessionServiceTaskEmpty: URLSessionTask, URLSessionServiceTask {
    override init() {}
}

public protocol URLSessionsService {
    /*
     * data task convenience methods.  These methods create tasks that
     * bypass the normal delegate calls for response and data delivery,
     * and provide a simple cancelable asynchronous interface to receiving
     * data.  Errors will be returned in the NSURLErrorDomain,
     * see <Foundation/NSURLError.h>.  The delegate, if any, will still be
     * called for authentication challenges.
     */
    func data(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionServiceTask

    /// Convenience method to load data using an URLRequest, creates and resumes an URLSessionDataTask internally.
    ///
    /// - Parameter request: The URLRequest for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: Data and response.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionsService {
    public func data(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionServiceTask {
        dataTask(with: request, completionHandler: completionHandler) as URLSessionServiceTask
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

public protocol ClientProtocol {
    func prepare<T, E>(request: Request<T, E>) -> Request<T, E>
    func requestUrl<Resource, Error>(for request: Request<Resource, Error>) -> URL?
    func perform<Resource, Error>(_ request: Request<Resource, Error>,
                                  completion: @escaping (Result<Resource, Client.Error>) -> Void) -> URLSessionServiceTask
    func perform<Resource, Error>(_ request: Request<Resource, Error>) async throws
        -> Resource
}

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
        /// The empty response
        case empty(Swift.Error, Int)
        /// The request composition filure
        case request(String)
        /// Other failure
        case other(Swift.Error)
    }

    /// The base url
    public let baseURL: String
    /// The url session
    public let session: URLSessionsService
    /// The http headers
    public var defaultHeaders: [String: String] = [:]


    /// Create a new client
    /// - Parameters:
    ///   - baseURL: The base url
    ///   - session: The url session
    public init(baseURL: String, session: URLSessionsService = URLSession(configuration: URLSessionConfiguration.default)) {
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
    open func requestUrl<Resource, Error>(for request: Request<Resource, Error>) -> URL? {
        return URL(string: baseURL.appendingPathComponent(request.path))
    }

    // swiftlint:disable function_body_length
    /// Run the request
    /// - Parameters:
    ///   - request: The `Request` Object
    ///   - completion: The completion block
    /// - Returns: The `URLSessionTask`
    @discardableResult open func perform<Resource, Error>(_ request: Request<Resource, Error>,
                                                          completion: @escaping (Result<Resource, Client.Error>) -> Void)
        -> URLSessionServiceTask {

            var request = prepare(request: request)
            let headers = defaultHeaders.merging(contentsOf: request.headers)
            guard let url = requestUrl(for: request) else {
                completion(.failure(.request(request.path)))
                return URLSessionServiceTaskEmpty()
            }

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
                    return URLSessionServiceTaskEmpty()
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
                    return URLSessionServiceTaskEmpty()
                }
            }

            let task = self.session.data(with: urlRequest) { (data, urlResponse, error) in
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

                if let data = data, !data.isEmpty {
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
                        let resource = try request.empty()
                        completion(.success(resource))
                    } catch let error as Client.Error {
                        completion(.failure(error))
                    } catch let error {
                        completion(.failure(.empty(error, urlResponse.statusCode)))
                    }
                }
            }

            task.resume()
            return task
    }
    // swiftlint:enable function_body_length

    // swiftlint:disable function_body_length
    /// Run the request
    /// - Parameters:
    ///   - request: The `Request` Object
    /// - Returns: The `Resource`
    open func perform<Resource, Error>(_ request: Request<Resource, Error>) async throws
        -> Resource {

            var request = prepare(request: request)
            let headers = defaultHeaders.merging(contentsOf: request.headers)
            guard let url = requestUrl(for: request) else {
                throw Client.Error.request(request.path)
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.method.rawValue
            headers.forEach { urlRequest.addValue($1, forHTTPHeaderField: $0) }

            if let parameters = request.parameters {
                do {
                    urlRequest = try parameters.apply(urlRequest: urlRequest)
                } catch {
                    switch error {
                    case let clientError as Client.Error:
                        throw Client.Error.other(clientError)
                    default:
                        throw Client.Error.client("Not handled error for request apply parameters")
                    }
                }
            }

            if let body = request.body {
                do {
                    urlRequest = try body.apply(urlRequest: urlRequest)
                } catch {
                    switch error {
                    case let clientError as Client.Error:
                        throw Client.Error.other(clientError)
                    default:
                        throw Client.Error.client("Not handled error for request apply parameters")
                    }
               }
            }

            do {
                let (data, urlResponse) = try await self.session.data(for: urlRequest)

                guard let urlResponse = urlResponse as? HTTPURLResponse else {
                    let error = Client.Error.client("Not handled HTTPURLResponse")
                    throw Client.Error.remote(error, 0)
                }

                request.headers
                    .merge(contentsOf: urlResponse.allHeaderFields
                        .map { ($0 as? String, $1 as? String) }
                        .compactMap()
                )

                guard urlResponse.statusCode != 401 else {
                    if let error = try? request.error(data) {
                        throw Client.Error.unauthenticated(error)
                    } else {
                        let message = "HTTP status code unauthorized. Received  \(urlResponse.statusCode)."
                        let error = Client.Error.client(message)
                        throw Client.Error.unauthenticated(error)
                    }
                }

                guard urlResponse.statusCode != 403 else {
                    if let error = try? request.error(data) {
                        throw Client.Error.unauthorized(error)
                    } else {
                        let message = "HTTP status code unauthorized. Received  \(urlResponse.statusCode)."
                        let error = Client.Error.client(message)
                        throw Client.Error.unauthorized(error)
                    }
                }

                guard (200..<300).contains(urlResponse.statusCode) else {
                    if let error = try? request.error(data) {
                        throw Client.Error.remote(error, urlResponse.statusCode)
                    } else {
                        let message = "HTTP status code validation failed. Received  \(urlResponse.statusCode)."
                        let error = Client.Error.client(message)
                        throw Client.Error.remote(error, urlResponse.statusCode)
                    }
                }

                if !data.isEmpty {
                    do {
                        let resource = try request.resource(data)
                        return resource
                    } catch let error as Client.Error {
                        throw Client.Error.other(error)
                    } catch let error {
                        throw Client.Error.parser(error)
                    }
                } else {
                    // no error, no data - valid empty response
                    do {
                        let resource = try request.empty()
                        return resource
                    } catch let error as Client.Error {
                        throw Client.Error.other(error)
                    } catch let error {
                        throw Client.Error.empty(error, urlResponse.statusCode)
                    }
                }

            } catch {
                throw Client.Error.remote(error, 0)
            }
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
        case .empty(_, let code):
            return code
        default:
            return 0
        }
    }

    public var errorDescription: String? {
        switch self {
        case let .network(error, statusCode):
            return "network failure on status code: \(statusCode) with: \(error.localizedDescription)"
        case let .remote(error, statusCode):
            return "remote failure on status code: \(statusCode) with: \(error.localizedDescription)"
        case let .parser(error):
            return "parser failure with: \(error.localizedDescription)"
        case let .client(message):
            return "client failure with: \(message)"
        case let .requestParameters(error):
            return "request parameters failure with: \(error.localizedDescription)"
        case let .unauthorized(error):
            return "unauthorized failure :\(error.localizedDescription)"
        case let .unauthenticated(error):
            return "unauthenticated failure :\(error.localizedDescription)"
        case let .empty(error, statusCode):
            return "empty response on status code: \(statusCode) with: \(error.localizedDescription)"
        case let .request(path):
            return "failure on path: \(path)"
        case let .other(error):
            return "other failure: \(error.localizedDescription)"
        }
    }
}
