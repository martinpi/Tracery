//
//  File.swift
//  Tracery
//
//  Created by Martin Pichlmair on 15/12/2018.
//  Copyright © 2018 Benzi Ahamed. All rights reserved.
//

import Foundation

extension String {
	func replaceMatches(for regexPattern: String, template: String) -> String {
		let regex = try! NSRegularExpression(pattern: regexPattern, options: [NSRegularExpression.Options.anchorsMatchLines])
		return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self), withTemplate: template)
	}
}

public class RegularExpressions {
	
	public var patterns = [String:String]()
	
	public func applyAll(_ toString: String) -> String {
		var returnString = toString
		for (expression, template) in patterns {
			returnString = returnString.replaceMatches(for: expression, template: template)
		}
		return returnString
	}
	
	public init() {
		
	}
	
}
