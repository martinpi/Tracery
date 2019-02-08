//
//  Nodes.swift
//  Kalk
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Foundation

public enum KalkOperator {
	case Plus
	case Minus
	case Division
	case Multiplication
}

public protocol KalkBaseNode: CustomStringConvertible {
	var evaluate: KalkValue { get }
}

public protocol KalkExprNode: KalkBaseNode {
}

public struct KalkNumberNode: KalkExprNode {
    public let value: Double
    public var description: String {
        return "NumberNode(\(value))"
    }
	public var evaluate: KalkValue {
		if value == floor(value) {
			return KalkInterpreter.getInt(value: Int(value))
		}
		return KalkInterpreter.getDouble(value:value)
	}
}

//public struct KalkColourNode: KalkBaseNode {
//	public let colour: Color
//	public var description: String {
//		return "ColourNode(\(colour))"
//	}
//	public var evaluate: KalkValue { return KalkInterpreter.getDouble(value:0.0) }
//}

public struct KalkVariableNode: KalkExprNode {
    public let name: String
    public var description: String {
        return "VariableNode(\(name))"
    }
	public var evaluate: KalkValue { return KalkInterpreter.getDouble(value:0.0) }
}

public struct KalkConstantNode: KalkExprNode {
	public let name: String
	public let value: Double
	public var description: String {
		return "VariableNode(\(name))"
	}
	public var evaluate: KalkValue { return KalkInterpreter.getDouble(value:value) }
}

public struct KalkBinaryOpNode: KalkExprNode {
    public let op: KalkOperator
    public let lhs: KalkExprNode
    public let rhs: KalkExprNode
    public var description: String {
        return "BinaryOpNode(\(op), lhs: \(lhs), rhs: \(rhs))"
    }
	public var evaluate: KalkValue {
		var result = 0.0
		let l = lhs.evaluate.getDouble()
		let r = rhs.evaluate.getDouble()
		switch op {
		case KalkOperator.Plus: result = l! + r!; break
		case KalkOperator.Minus: result = l! - r!; break
		case KalkOperator.Multiplication: result = l! * r!; break
		case KalkOperator.Division: result = l! / r!; break
		}
		return KalkInterpreter.getDouble(value:result)
	}
}


public struct KalkCallNode: KalkExprNode {
    public let callee: String
    public let arguments: [KalkExprNode]
    public var description: String {
        return "CallNode(name: \(callee), argument: \(arguments))"
    }
	public var evaluate: KalkValue {
		
		if let binary = KalkInterpreter.getBinaryFunction(name: callee) {
			if arguments.count == 2 {
				return binary.eval(arguments[0].evaluate, arguments[1].evaluate)
			}
		}
		if let unary = KalkInterpreter.getUnaryFunction(name: callee) {
			return unary.eval(arguments[0].evaluate)
		}

		return KalkInterpreter.getDouble(value:-1.0)
	}
}

public struct KalkPrototypeNode: KalkExprNode {
    public let name: String
    public let argumentNames: [String]
    public var description: String {
        return "PrototypeNode(name: \(name), argumentNames: \(argumentNames))"
    }
	public var evaluate: KalkValue { return KalkInterpreter.getDouble(value:0.0) }
}

public struct KalkFunctionNode: KalkExprNode {
    public let prototype: KalkPrototypeNode
    public let body: KalkExprNode
    public var description: String {
        return "FunctionNode(prototype: \(prototype), body: \(body))"
    }
	public var evaluate: KalkValue { return KalkInterpreter.getDouble(value:0.0) }
}

