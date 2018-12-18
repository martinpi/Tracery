//
//  Parser.swift
//  Kalk
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Foundation

enum KalkErrors: Error {
    case UnexpectedToken
    case UndefinedOperator(String)
    
    case ExpectedCharacter(Character)
    case ExpectedExpression
    case ExpectedArgumentList
    case ExpectedFunctionName
}

class KalkParser {
    let tokens: [KalkToken]
    var index = 0
    
    init(tokens: [KalkToken]) {
        self.tokens = tokens
    }
    
	func peekToken(i: Int) throws -> KalkToken {
		let token = tokens[safe: i]
		if token != nil {
			return token!
		} else {
			throw KalkErrors.UnexpectedToken
		}
	}
	
    func peekCurrentToken() throws -> KalkToken {
		return try peekToken(i: index)
    }
    
    @discardableResult func popCurrentToken() throws -> KalkToken {
		index += 1
		return try peekToken(i: index-1)
    }
    
    func parseNumber() throws -> KalkExprNode {
		guard case let KalkToken.Number(value) = try popCurrentToken() else {
            throw KalkErrors.UnexpectedToken
        }
        return KalkNumberNode(value: value)
    }
    
    func parseExpression() throws -> KalkExprNode {
        let node = try parsePrimary()
		return try parseBinaryOp(node: node)
    }
    
    func parseParens() throws -> KalkExprNode {
		guard case KalkToken.ParensOpen = try popCurrentToken() else {
            throw KalkErrors.ExpectedCharacter("(")
        }
        
        let exp = try parseExpression()

		guard case KalkToken.ParensClose = try popCurrentToken() else {
            throw KalkErrors.ExpectedCharacter(")")
        }
    
        return exp
    }
    
    func parseIdentifier() throws -> KalkExprNode {
		guard case let KalkToken.Identifier(name) = try popCurrentToken() else {
            throw KalkErrors.UnexpectedToken
        }

		guard case KalkToken.ParensOpen = try peekCurrentToken() else {
            return KalkVariableNode(name: name)
        }
		try popCurrentToken()
        
        var arguments = [KalkExprNode]()
		if case KalkToken.ParensClose = try peekCurrentToken() {
        }
        else {
            while true {
                let argument = try parseExpression()
                arguments.append(argument)
                
				if case KalkToken.ParensClose = try peekCurrentToken() {
                    break
                }
                
				guard case KalkToken.Comma = try popCurrentToken() else {
                    throw KalkErrors.ExpectedArgumentList
                }
            }
        }
        
		try popCurrentToken()
        return KalkCallNode(callee: name, arguments: arguments)
    }
    
    func parsePrimary() throws -> KalkExprNode {
		switch (try peekCurrentToken()) {
        case .Identifier:
            return try parseIdentifier()
        case .Number:
            return try parseNumber()
        case .ParensOpen:
            return try parseParens()
        default:
            throw KalkErrors.ExpectedExpression
        }
    }
    
    let operatorPrecedence: [String: Int] = [
        "+": 20,
        "-": 20,
        "*": 40,
        "/": 40
    ]
    
    func getCurrentTokenPrecedence() throws -> Int {
        guard index < tokens.count else {
            return -1
        }
        
		guard case let KalkToken.Other(op) = try peekCurrentToken() else {
            return -1
        }
        
        guard let precedence = operatorPrecedence[op] else {
            throw KalkErrors.UndefinedOperator(op)
        }

        return precedence
    }
    
    func parseBinaryOp(node: KalkExprNode, exprPrecedence: Int = 0) throws -> KalkExprNode {
        var lhs = node
        while true {
            let tokenPrecedence = try getCurrentTokenPrecedence()
            if tokenPrecedence < exprPrecedence {
                return lhs
            }
            
			guard case let KalkToken.Other(op) = try popCurrentToken() else {
                throw KalkErrors.UnexpectedToken
            }
            
            var rhs = try parsePrimary()
            let nextPrecedence = try getCurrentTokenPrecedence()
            
            if tokenPrecedence < nextPrecedence {
				rhs = try parseBinaryOp(node: rhs, exprPrecedence: tokenPrecedence+1)
            }
			
			var oper = KalkOperator.Plus
			switch op {
			case "+": oper = KalkOperator.Plus; break
			case "-": oper = KalkOperator.Minus; break
			case "*": oper = KalkOperator.Multiplication; break
			case "/": oper = KalkOperator.Division; break
			default: break
			}
			
            lhs = KalkBinaryOpNode(op: oper, lhs: lhs, rhs: rhs)
        }
    }
    
    func parsePrototype() throws -> KalkPrototypeNode {
		guard case let KalkToken.Identifier(name) = try popCurrentToken() else {
            throw KalkErrors.ExpectedFunctionName
        }
        
		guard case KalkToken.ParensOpen = try popCurrentToken() else {
            throw KalkErrors.ExpectedCharacter("(")
        }
        
        var argumentNames = [String]()
		while case let KalkToken.Identifier(name) = try peekCurrentToken() {
			try popCurrentToken()
            argumentNames.append(name)
            
			if case KalkToken.ParensClose = try peekCurrentToken() {
                break
            }
            
			guard case KalkToken.Comma = try popCurrentToken() else {
                throw KalkErrors.ExpectedArgumentList
            }
        }
        
        // remove ")"
		try popCurrentToken()
        
        return KalkPrototypeNode(name: name, argumentNames: argumentNames)
    }
    
    func parseDefinition() throws -> KalkFunctionNode {
		try popCurrentToken()
        let prototype = try parsePrototype()
        let body = try parseExpression()
        return KalkFunctionNode(prototype: prototype, body: body)
    }
    
    func parseTopLevelExpr() throws -> KalkFunctionNode {
        let prototype = KalkPrototypeNode(name: "", argumentNames: [])
        let body = try parseExpression()
        return KalkFunctionNode(prototype: prototype, body: body)
    }
    
	func parse() throws -> [KalkBaseNode] {
        index = 0
        
        var nodes = [KalkBaseNode]()
        while index < tokens.count {
			switch try peekCurrentToken() {
            case .Define:
                let node = try parseDefinition()
                nodes.append(node)
            default:
                let expr = try parseExpression()
                nodes.append(expr)
            }
        }
        
        return nodes
    }
}
