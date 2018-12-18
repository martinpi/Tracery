//
//  Kalk.SSA.swift
//  Ephemerald
//
//  Created by Martin Pichlmair on 04/10/2018.
//  Copyright © 2018 Broken Rules. All rights reserved.
//

import Foundation

public class KalkFunction {
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

public enum KalkValue {
	case double(value: Double)
	case int(value: Int)
	case string(value: String)
	case function(func: KalkFunction)
	
	public func getDouble() -> Double? {
		switch self {
		case let .double(value):
			return value
		default:
			return nil
		}
	}
	
	
}
