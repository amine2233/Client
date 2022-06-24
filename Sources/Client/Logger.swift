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

public struct LoggerLevel: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let none = LoggerLevel(rawValue: 1 << 0)
    public static let error = LoggerLevel(rawValue: 1 << 1)
    public static let warning = LoggerLevel(rawValue: 1 << 2)
    public static let info = LoggerLevel(rawValue: 1 << 3)
    public static let debug = LoggerLevel(rawValue: 1 << 3)
}

public enum LoggerFactory {
    public static func build(prefix: String = "Client", level: LoggerLevel = .debug) -> Logger {
        LoggerDefault(prefix: prefix, level: level)
    }
}

final class LoggerDefault: Logger {

    var level: LoggerLevel

    private let prefix: String

    init(prefix: String, level: LoggerLevel = .debug) {
        self.prefix = prefix
        self.level = level
    }

    func error(_ message: Any) {
        guard level.rawValue >= LoggerLevel.error.rawValue else { return }
        print("[\(prefix)] 💥 \(message)")
    }

    func warning(_ message: Any) {
        guard level.rawValue >= LoggerLevel.warning.rawValue else { return }
        print("[\(prefix)] ⚠️ \(message)")
    }

    func info(_ message: Any) {
        guard level.rawValue >= LoggerLevel.info.rawValue else { return }
        print("[\(prefix)] 🟢 \(message)")
    }

    func debug(_ message: Any) {
        guard level.rawValue >= LoggerLevel.debug.rawValue else { return }
        print("[\(prefix)] 🐞 \(message)")
    }
}
