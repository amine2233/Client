//
//  BasicAuth.swift
//  Client
//
//  Created by Amine Bensalah on 04/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation

public enum BasicAuthError: Error {
    case failToData
    case failToBase64
    case failEencode
}

public struct BasicAuth {
    public static func createBasicAuth(username: String, password: String) throws -> String {
        let compose = "\(username):\(password)"
        guard let data = compose.data(using: String.Encoding.utf8) else { throw BasicAuthError.failToData }
        let base64Data = data.base64EncodedData()
        guard let encode = String(data: base64Data, encoding: String.Encoding.utf8) else { throw BasicAuthError.failEencode }
        return encode
    }
}
