//
//  LoggingClient.swift
//  Client
//
//  Created by Amine Bensalah on 04/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation

/// A Client subclass that adds logging layer.
open class LoggingClient: Client {

    open override func perform<Resource, Error>(_ request: Request<Resource, Error>, completion: @escaping (Result<Resource, Client.Error>) -> Void) -> URLSessionTask {
        let requestDescription: String
        if let parameters = request.parameters {
            requestDescription = "\(request.method.rawValue) \(request.path); \(String(describing: parameters))"
        } else {
            requestDescription = "\(request.method.rawValue) \(request.path)"
        }
        log.info("Sent request: " + requestDescription)

        return super.perform(request, completion: { (result) in

            switch result {
            case .success(let value):
                log.info("Received response for: " + requestDescription)
                log.debug("Parsed response data: \(value)")
            case .failure(let error):
                log.error("Request failed: " + requestDescription + "\nWith error: " + error.localizedDescription)
            }

            completion(result)
        })
    }
}
