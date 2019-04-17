//
//  Kalk.Interpreter.swift
//  Ephemerald
//
//  Created by Martin Pichlmair on 04/10/2018.
//  Copyright © 2018 Broken Rules. All rights reserved.
//

import Foundation

// The interpreter is more or less a single evaluation context

public class KalkInterpreter {
	
	public static func getDouble(value: Double) -> KalkValue {
		return KalkValue.double(value: value)
	}
	public static func getInt(value: Int) -> KalkValue {
		return KalkValue.int(value: value)
	}
	public static func getUnaryFunction(name: String) -> KalkUnaryFunction? {
		if let f = unaryFunctions[name] {
			return f
		}
		return nil
	}
	public static func getBinaryFunction(name: String) -> KalkBinaryFunction? {
		if let f = binaryFunctions[name] {
			return f
		}
		return nil
	}
	static func registerUnaryFunction(_ name: String, _ function: @escaping (KalkValue) -> KalkValue) {
		unaryFunctions[name] = KalkUnaryFunction(name: name, callback: function)
	}
	static func registerBinaryFunction(_ name: String, _ function: @escaping (KalkValue, KalkValue) -> KalkValue) {
		binaryFunctions[name] = KalkBinaryFunction(name: name, callback: function)
	}

	public static var unaryFunctions : [String : KalkUnaryFunction] = [:]
	public static var binaryFunctions : [String : KalkBinaryFunction] = [:]

	public static func KalkSin(_ value: KalkValue) -> KalkValue {
		return getDouble(value: sin(value.getDouble()!))
	}
	public static func KalkCos(_ value: KalkValue) -> KalkValue {
		return getDouble(value: cos(value.getDouble()!))
	}
	public static func KalkRand(_ value: KalkValue) -> KalkValue {
		return getDouble(value:
		(Double(arc4random()) / Double(UINT32_MAX)) * value.getDouble()!)
	}
	public static func KalkInt(_ value: KalkValue) -> KalkValue {
		return getInt(value: value.getInt()!)
	}

	public static func registerBuiltins() {
		registerUnaryFunction("sin", KalkSin)
		registerUnaryFunction("cos", KalkCos)
		registerUnaryFunction("rand", KalkRand)
		registerUnaryFunction("int", KalkInt)
		
		registerUnaryFunction("sqrt") { value -> KalkValue in
			return getDouble(value:sqrt(value.getDouble()!))
		}
		registerUnaryFunction("sqr") { value -> KalkValue in
			return getDouble(value:pow(value.getDouble()!, 2.0))
		}
		registerBinaryFunction("pow") { (value,value2) -> KalkValue in
			return getDouble(value:pow(value.getDouble()!, value2.getDouble()!))
		}
		registerBinaryFunction("rand") { (value,value2) -> KalkValue in
			return getDouble(value: value.getDouble()! +
				(Double(arc4random()) / Double(UINT32_MAX)) * (value2.getDouble()!-value.getDouble()!))
		}
	}

	public static func interpret(_ string: String) -> String {
		let lexer = KalkLexer(input: string)
		let tokens = lexer.tokenize()
		let parser = KalkParser(tokens: tokens)
		var expandedString: String = ""
		do {
			let nodes = try parser.parse()
			nodes.forEach {
				if let n = $0 as? KalkExprNode {
//					expandedString += String(n.evaluate.getDouble()!)
					expandedString += String(n.evaluate.getString()!)
				}
			}
		} catch {
			expandedString = "0.0"
		}
		return expandedString
	}

	
	public static func interpret(lines: [String]) -> String {
		return interpret(lines.joined(separator: "\n"))
	}
}
