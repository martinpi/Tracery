//
//  Tracery.JSON.swift
//  Tracery
//
//  Created by Martin Pichlmair on 25/09/2018.
//  Copyright © 2018 Broken Rules. All rights reserved.
//

import Foundation


// File format that can scan JSON

// {
// 	"origin": ["candidate 1", "candidate 2"]
// }

extension Tracery {
	
	convenience public init(_ options: TraceryOptions = TraceryOptions.defaultSet, jsonFile: String) {
		if let reader = StreamReader(path: jsonFile) {
			self.init ( options, rules: { JSONParser.parse(lines: reader) } )
		}
		else {
			warn("unable to parse input file: \(jsonFile)")
			self.init()
		}
	}
	
	convenience public init(_ options: TraceryOptions = TraceryOptions.defaultSet, json: [String]) {
		self.init ( options, rules: { JSONParser.parse(lines: json) } )
	}
	
	
	
}

struct JSONParser {
	
	enum State {
		case consumeRule
		case consumeDefinitions
	}
	
	static func parse<S: Sequence>(lines: S) -> [String: Any] where S.Iterator.Element == String {
		
		var ruleSet = [String: Any]()

//		Tracery.logLevel = Tracery.LoggingLevel.verbose
		
		var jsonData = Data()
		for line in lines {
			if let lineData = line.data(using: .utf8) {
				jsonData.append(lineData)
			} else {
				warn("error decoding string to data")
			}
		}
		
		do {
			let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
			
			if let dictionary = json as? [String: Any] {
				for (rule, value) in dictionary {
					if let candidates = value as? [String] {
						// multiple candidates
						if ruleSet[rule] != nil {
							warn("rule '\(rule)' defined twice, will be overwritten")
						}
						ruleSet[rule] = candidates
					} else {
						if let candidate = value as? String {
							// sinlge candidate
							if ruleSet[rule] != nil {
								warn("rule '\(rule)' defined twice, will be overwritten")
							}
							ruleSet[rule] = candidate
						} else {
							warn("JSON parsing found no candidate for rule '"+rule+"'")
						}
					}
				}
			} else {
				warn("JSON root should be an object, not an array")
			}
			

		} catch {
			warn("JSON parsing error: \(error).")
		}
		
//		Tracery.logLevel = Tracery.LoggingLevel.errors
		
		return ruleSet
	}
	
}
