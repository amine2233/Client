//
//  Utilities.swift
//  Client
//
//  Created by Amine Bensalah on 04/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation

extension String {

    func appendingPathComponent(_ pathComponent: String) -> String {
        // TODO: Need to change NSString to String for working on Server-Side linux
        //return NSString(string: self).appendingPathComponent(pathComponent)
        return URL(fileURLWithPath: self).appendingPathComponent(pathComponent).path
    }
}

extension Dictionary {

    var jsonString: String {
        let json = try! JSONSerialization.data(withJSONObject: self, options: [])
        return String(data: json, encoding: .utf8)!
    }
}

extension Array {

    var jsonString: String {
        let json = try! JSONSerialization.data(withJSONObject: self, options: [])
        return String(data: json, encoding: .utf8)!
    }
}

extension Dictionary {

    var keyValuePairs: String {
        return map { keyValue in
                let key = keyValue.key
                let value = "\(keyValue.value)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                return "\(key)=\(value)"
            }
            .joined(separator: "&")
    }
}

extension Dictionary {

    public mutating func merge(contentsOf dictionary: [Key: Value]) {
        dictionary.forEach { key, value in
            self[key] = value
        }
    }

    public func merging(contentsOf dictionary: [Key: Value]) -> [Key: Value] {
        var me = self
        me.merge(contentsOf: dictionary)
        return me
    }
}

// swiftlint:disable syntactic_sugar
public protocol OptionalProtocol {
    associatedtype Wrapped
    var unbox: Optional<Wrapped> { get }
    init(nilLiteral: ())
    init(_ some: Wrapped)
}
// swiftlint:enable syntactic_sugar

// swiftlint:disable syntactic_sugar
extension Optional: OptionalProtocol {
    public var unbox: Optional<Wrapped> {
        return self
    }
}
// swiftlint:enable syntactic_sugar

extension Dictionary where Value: OptionalProtocol {

    public var nonNils: [Key: Value.Wrapped] {
        var result: [Key: Value.Wrapped] = [:]

        forEach { pair in
            if let value = pair.value.unbox {
                result[pair.key] = value
            }
        }

        return result
    }
}
