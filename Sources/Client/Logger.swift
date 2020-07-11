//
//  Logger.swift
//  Client
//
//  Created by Amine Bensalah on 04/07/2019.
//  Copyright © 2019 Amine Bensalah. All rights reserved.
//

import Foundation

public protocol Logger {
    func error(_ message: Any)
    func warning(_ message: Any)
    func info(_ message: Any)
    func debug(_ message: Any)
}

public class SimpleLogger: Logger {
    public enum Level: Int {
        case none = 0
        case error = 1
        case warning = 2
        case info = 3
        case debug = 4
    }

    public let prefix: String

    public var level: Level = .debug

    public func error(_ message: Any) {
        guard level.rawValue >= Level.error.rawValue else { return }
        print("[\(prefix)] 💥 \(message)")
    }

    public func warning(_ message: Any) {
        guard level.rawValue >= Level.warning.rawValue else { return }
        print("[\(prefix)] ⚠️ \(message)")
    }

    public func info(_ message: Any) {
        guard level.rawValue >= Level.info.rawValue else { return }
        print("[\(prefix)] 🟢 \(message)")
    }

    public func debug(_ message: Any) {
        guard level.rawValue >= Level.debug.rawValue else { return }
        print("[\(prefix)] 🐞 \(message)")
    }

    public init(prefix: String) {
        self.prefix = prefix
    }
}

public var log: Logger = SimpleLogger(prefix: "Client")
