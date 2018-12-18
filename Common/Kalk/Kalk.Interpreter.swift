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
	public static func getFunction(name: String) -> KalkFunction? {
		if let f = functions[name] {
			return f
		}
		return nil
	}
	static func registerUnaryFunction(_ name: String, _ function: @escaping (KalkValue) -> KalkValue) {
		functions[name] = KalkFunction(name: name, callback: function)
	}

	public static var functions : [String : KalkFunction] = [:]

	public static func KalkSin(_ value: KalkValue) -> KalkValue { return getDouble(value: sin(value.getDouble()!)) }
	public static func KalkCos(_ value: KalkValue) -> KalkValue { return getDouble(value: cos(value.getDouble()!)) }
	public static func KalkRand(_ value: KalkValue) -> KalkValue { return getDouble(value:
		(Double(arc4random()) / Double(UINT32_MAX)) * value.getDouble()!) }

	public static func registerBuiltins() {
		registerUnaryFunction("sin", KalkSin)
		registerUnaryFunction("cos", KalkCos)
		registerUnaryFunction("rand", KalkRand)
		
		registerUnaryFunction("sqrt") { value -> KalkValue in
			return getDouble(value:sqrt(value.getDouble()!))
		}
	}
	
	public static func interpret(_ string: String) -> String {
		let lexer = KalkLexer(input: string)
		let tokens = lexer.tokenize()
		let parser = KalkParser(tokens: tokens)
		registerBuiltins()
		var expandedString: String = ""
		do {
			let nodes = try parser.parse()
			nodes.forEach {
				if let n = $0 as? KalkExprNode {
					expandedString += String(n.evaluate.getDouble()!)
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
