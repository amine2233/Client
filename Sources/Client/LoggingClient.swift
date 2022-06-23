//
//  LoggingClient.swift
//  Client
//
//  Created by Amine Bensalah on 04/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A Client subclass that adds logging layer.
open class LoggingClient: Client {
    private var logger: Logger

    /// Create a new client
    /// - Parameters:
    ///   - baseURL: The base url
    ///   - session: The url session
    ///   - logger: Logger
    public init(baseURL: String, session: URLSessionsService = URLSession(configuration: URLSessionConfiguration.default), logger: Logger = LoggerFactory.build()) {
        self.logger = logger
        super.init(baseURL: baseURL, session: session)
    }

    @discardableResult
    open override func perform<Resource, Error>(
        _ request: Request<Resource, Error>,
        completion: @escaping (Result<Resource, Client.Error>) -> Void
    ) -> URLSessionServiceTask? {
        var requestDescription: String = "\(request.method.rawValue) \(request.path);"
        if let parameters = request.parameters {
            requestDescription += " \(String(describing: parameters))"
        }

        logger.info("Sent path: " + request.path)
        logger.info("Sent request: " + requestDescription)
        logger.info("Sent http headers: " + "\(request.headers)")

        return super.perform(request, completion: {[logger] (result) in
            logger.info("Received path: " + request.path)
            switch result {
            case .success(let value):
                logger.info("Received response for: " + requestDescription)
                logger.debug("Parsed response data: \(value)")
            case .failure(let error):
                logger.error("Request failed: " + requestDescription + "\nWith error: " + error.localizedDescription)
            }
            logger.info("Received http headers: " + "\(request.headers)")

            completion(result)
        })
    }

    open override func perform<Resource, Error>(
        _ request: Request<Resource, Error>
    ) async throws -> Resource {
        let result = try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Resource, Swift.Error>) -> Void in
            perform(request) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        })
        return result
    }
}
