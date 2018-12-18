//
//  Lexer.swift
//  Kalk
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

//let source = multiline(
//    "def foo(x, y)",
//    "  x + y * 2 + (4 + 5) / 3",
//    "",
//    "foo(3, 4)"
//)
//
//let lexer = Lexer(input: source)
//let tokens = lexer.tokenize()
//print(tokens)
//
//let parser = Parser(tokens: tokens)
//do {
//    print(try parser.parse())
//}
//catch {
//    print(error)
//}


import Foundation

public enum KalkToken {
    case Define
    case Identifier(String)
    case Number(Double)
    case ParensOpen
    case ParensClose
    case Comma
    case Other(String)
}

typealias KalkTokenGenerator = (String) -> KalkToken?
let KalkTokenList: [(String, KalkTokenGenerator)] = [
    ("[ \t\n]", { _ in nil }),
    ("[a-zA-Z][a-zA-Z0-9]*", { $0 == "def" ? .Define : .Identifier($0) }),
    ("[0-9.]+", { (r: String) in .Number((r as NSString).doubleValue) }),
    ("\\(", { _ in .ParensOpen }),
    ("\\)", { _ in .ParensClose }),
    (",", { _ in .Comma }),
]

public class KalkLexer {
    let input: String
    init(input: String) {
        self.input = input
    }
    public func tokenize() -> [KalkToken] {
        var tokens = [KalkToken]()
        var content = input
        
        while (content.count > 0) {
            var matched = false
            
            for (pattern, generator) in KalkTokenList {
				if let m = content.match(regex: pattern) {
                    if let t = generator(m) {
                        tokens.append(t)
                    }

					let index = content.index(content.startIndex, offsetBy: m.count)
					content = String(content[index..<content.endIndex])
                    matched = true
                    break
                }
            }

            if !matched {
				let index = content.index(content.startIndex, offsetBy: 1)
				
                tokens.append(.Other(String(content[content.startIndex..<index])))
				content = String(content[index..<content.endIndex])
            }
        }
        return tokens
    }
}

