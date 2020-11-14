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
        case let .requestParameters(error):
            return error.localizedDescription
        case let .unauthorized(error):
            return "unauthorized failure :\(error.localizedDescription)"
        case let .unauthenticated(error):
            return "unauthenticated failure :\(error.localizedDescription)"
        }
    }
}
