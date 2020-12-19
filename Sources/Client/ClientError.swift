//
//  ClientError.swift
//  Client
//
//  Created by Amine Bensalah on 17/05/2020.
//

import Foundation

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
        }
    }
}
