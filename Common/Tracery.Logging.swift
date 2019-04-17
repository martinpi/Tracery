//
//  Tracery.Logging.swift
//  Tracery
//
//  Created by Benzi on 10/03/17.
//  Copyright © 2017 Benzi Ahamed. All rights reserved.
//

import Foundation

// EXAMPLE OF A LOGGING FUNCTION
//	func notificationLog(_ message: String) {
//		// install via Tracery.logTarget = notificationLog
//		NotificationCenter.default.post(name: Notification.Name("Tracery.log"), object: nil, userInfo: ["message":message])
//	}


extension Tracery {

    public enum LoggingLevel : Int {
        case none = 0
        case errors
        case warnings
        case info
        case verbose
    }
    
    public static var logLevel = LoggingLevel.errors
	public static var logTarget : (String) -> Void = stdLog
	
	fileprivate static func stdLog(_ message: String) {
		// standard logger to standard output
		print(message)
	}

    public static func log(level: LoggingLevel, message: @autoclosure () -> String) {
        guard logLevel.rawValue >= level.rawValue else { return }
        logTarget(message())
    }

    func trace(_ message: @autoclosure () -> String) {
		let indent = String(repeating: "  ", count: ruleEvaluationLevel)
        Tracery.log(level: .verbose, message: "\(indent)\(message())")
    }
    
}

func info(_ message: @autoclosure () -> String) {
    Tracery.log(level: .info, message: "ℹ️ \(message())")
}

func warn(_ message: @autoclosure () -> String) {
    Tracery.log(level: .warnings, message: "⚠️ \(message())")
}

func error(_ message: @autoclosure () -> String) {
    Tracery.log(level: .errors, message: "⛔️ \(message())")
}

func trace(_ message: @autoclosure () -> String) {
	Tracery.log(level: .verbose, message: message())
}














