//
//  ClientProtocol.swift
//  Client
//
//  Created by Amine Bensalah on 17/05/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

protocol ClientProtocol {
    func prepare<T, E>(request: Request<T, E>) -> Request<T, E>
    func requestUrl<Resource, Error>(for request: Request<Resource, Error>) -> URL
    func perform<Resource, Error>(_ request: Request<Resource, Error>,
                                  completion: @escaping (Result<Resource, Client.Error>) -> Void) -> URLSessionTask
}
