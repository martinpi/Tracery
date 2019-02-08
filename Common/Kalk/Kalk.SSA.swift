//
//  Kalk.SSA.swift
//  Ephemerald
//
//  Created by Martin Pichlmair on 04/10/2018.
//  Copyright © 2018 Broken Rules. All rights reserved.
//

import Foundation

public class KalkUnaryFunction {
	public var name: String
	public var callback: (KalkValue) -> KalkValue

	init (name: String, callback: @escaping (KalkValue) -> KalkValue) {
		self.name = name
		self.callback = callback
	}
	
	public func eval(_ value:KalkValue) -> KalkValue {
		return callback(value)
	}
}

public class KalkBinaryFunction {
	public var name: String
	public var callbackBinary: (KalkValue, KalkValue) -> KalkValue
	
	init (name: String, callback: @escaping (KalkValue, KalkValue) -> KalkValue) {
		self.name = name
		self.callbackBinary = callback
	}
	
	public func eval(_ value:KalkValue, _ value2: KalkValue) -> KalkValue {
		return callbackBinary(value, value2)
	}
}


public enum KalkValue {
	case double(value: Double)
	case int(value: Int)
	case string(value: String)
	case function(func: KalkUnaryFunction)
	
	public func getDouble() -> Double? {
		switch self {
		case let .double(value):
			return value
		case let .int(value):
			return Double(value)
		default:
			return nil
		}
	}
	public func getInt() -> Int? {
		switch self {
		case let .int(value):
			return value
		case let .double(value):
			return Int(value)
		default:
			return nil
		}
	}
	public func getString() -> String? {
		switch self {
		case let .int(value):
			return String(value)
		case let .double(value):
			return String(value)
		case let .string(value):
			return value
		default:
			return nil
		}
	}
	
}
