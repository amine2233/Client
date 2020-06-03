//
//  Utilities.swift
//  Client
//
//  Created by Amine Bensalah on 04/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation

extension String {

    /**
     Add a path component \ after the `String`

     Exemple:
        ```
        let urlString = "http://intech-consulting.fr"
        let appendingPathComponent = urlString.appendingPathComponent("v1/users/login")
        /// return "http://intech-consulting.fr/v1/users/login"
        ```

     - Returns: A `String`
     */
    func appendingPathComponent(_ pathComponent: String) -> String {
        // TODO: Need a best solution than this code
        return self + "/" + pathComponent
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

extension Dictionary where Key: OptionalProtocol, Value: OptionalProtocol, Key.Wrapped: Hashable {
    func compactMap(_ transform: (Key, Value) -> (Key.Wrapped, Value.Wrapped)) -> [Key.Wrapped: Value.Wrapped] {
        var result: [Key.Wrapped: Value.Wrapped] = [:]
        for (key, value) in self {
            let (transformedKey, transformedValue) = transform(key, value)
            result[transformedKey] = transformedValue
        }
        return result
    }

    func compactMap(_ transform: (Key, Value) throws -> (Key.Wrapped, Value.Wrapped)) rethrows -> [Key.Wrapped: Value.Wrapped] {
        var result: [Key.Wrapped: Value.Wrapped] = [:]
        for (key, value) in self {
            let (transformedKey, transformedValue) = try transform(key, value)
            result[transformedKey] = transformedValue
        }
        return result
    }

    func compactMap() -> [Key.Wrapped: Value.Wrapped] {
        var result: [Key.Wrapped: Value.Wrapped] = [:]
        for (key, value) in self {
            if let key = key.unbox, let value = value.unbox {
                result[key] = value
            }
        }
        return result
    }
}

extension Dictionary {
    func map<T: Hashable, U>(_ transform: (Key, Value) -> (T, U)) -> [T: U] {
        var result: [T: U] = [:]
        for (key, value) in self {
            let (transformedKey, transformedValue) = transform(key, value)
            result[transformedKey] = transformedValue
        }
        return result
    }

    func map<T: Hashable, U>(_ transform: (Key, Value) throws -> (T, U)) rethrows -> [T: U] {
        var result: [T: U] = [:]
        for (key, value) in self {
            let (transformedKey, transformedValue) = try transform(key, value)
            result[transformedKey] = transformedValue
        }
        return result
    }
}
