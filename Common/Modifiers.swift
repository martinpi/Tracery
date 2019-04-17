//
//  Modifiers.swift
//  CardsCardsCards
//
//  Created by Martin Pichlmair on 25/09/2018.
//  Copyright © 2018 Broken Rules. All rights reserved.
//

// A set of standard modifiers

import Foundation

extension String {
	
	func substr(_ from: Int) -> String {
		let start = index(startIndex, offsetBy: from)
		return String(self[start ..< endIndex])
	}

	func substr(_ from: Int, to: Int) -> String {
		let start = index(startIndex, offsetBy: from)
		let end = index(startIndex, offsetBy: to)
		return String(self[start ..< end])
	}
	
	func charAt(_ pos: Int) -> Character {		let start = index(startIndex, offsetBy: pos)
		return Character(String(self[start]))
	}
	
	func capitalizingFirstLetter() -> String {
		return prefix(1).capitalized + dropFirst()
	}
	
	mutating func capitalizeFirstLetter() {
		self = self.capitalizingFirstLetter()
	}
}

public class StandardModifiers {

	static public func isConsonant(c: Character) -> Bool {
		let lower = Character(String(c).lowercased())
		switch(lower) {
		case "a":
			return false
		case "e":
			return false
		case "i":
			return false
		case "o":
			return false
		case "u":
			return false
		default:
			return true
		}
	}
	
	static func endsWithConY(s: String) -> Bool {
		if (s.hasSuffix("y")) {
			return isConsonant(c: Character(s.substr((s.count-2), to: (s.count-1))))
		}
		return false
	}
	
	static func uppercase(s: String) -> String {
		return s.uppercased()
	}
	static func lowercase(s: String) -> String {
		return s.lowercased()
	}
	static func titlecase(s: String) -> String {
		return s.capitalized
	}
	static func capitalize(s: String) -> String {
		return s.capitalizingFirstLetter()
	}
	static func inQuotes(s: String) -> String {
		return "\""+s+"\""
	}
	
	static func comma(s: String) -> String {
		if (s.suffix(1) == "," || s.suffix(1) == "." || s.suffix(1) == "!" || s.suffix(1) == "?") {
			return s;
		}
		return s + ", "
	}
	
	static func a(s: String) -> String {
		if (!isConsonant(c: s.charAt(0))) {
			return "an " + s;
		}
		return "a " + s;
	}

	static func s(s: String) -> String {
		if s.count < 1 {
			return ""
		}
		
		let last = s.charAt(s.count-1)
		switch last {
		case "y":
			// rays, convoys
			if (!isConsonant(c: s.charAt(s.count - 2))) {
				return s + "s";
			}
			// harpies, cries
			return s.substr(0, to: s.count - 1) + "ies";
			
		// oxen, boxen, foxen
		case "x":
			return s.substr(0, to: s.count - 1) + "en";
		case "z":
			return s.substr(0, to: s.count - 1) + "es";
		case "h":
			return s.substr(0, to: s.count - 1) + "es";
		default:
			return s + "s";
		}
	}
	
	static func ed(s: String) -> String {
		
		let index = s.firstIndex(of: " ") ?? s.startIndex;
		var rest = "";
		var s = s;
		if (index > s.startIndex) {
			rest = String(s[index ..< s.endIndex])
			s = String(s[s.startIndex ..< index])
		}
			
		let last = s.charAt(s.count - 1);
			
		switch(last) {
		case "y":
			
			// rays, convoys
			if (isConsonant(c: s.charAt(s.count - 2))) {
				return s.substr(0, to: s.count - 1) + "ied" + rest;
				
			}
			// harpies, cries
			return s + "ed" + rest;
		case "e":
			return s + "d" + rest;
		default:
			return s + "ed" + rest;
		};
	}

	public static func installStandardModifiers(t : Tracery) {
		t.add(modifier: "uppercase") { return StandardModifiers.uppercase(s: $0) }
		t.add(modifier: "lowercase") { return StandardModifiers.lowercase(s: $0) }
		t.add(modifier: "title") { return StandardModifiers.titlecase(s: $0) }
		t.add(modifier: "caps") { return StandardModifiers.capitalize(s: $0) }
		t.add(modifier: "capitalize") { return StandardModifiers.capitalize(s: $0) }
		t.add(modifier: "capitalise") { return StandardModifiers.capitalize(s: $0) }
		t.add(modifier: "inQuotes") { return StandardModifiers.inQuotes(s: $0) }
		t.add(modifier: "quote") { return StandardModifiers.inQuotes(s: $0) }
		t.add(modifier: "comma") { return StandardModifiers.comma(s: $0) }
		t.add(modifier: "a") { return StandardModifiers.a(s: $0) }
		t.add(modifier: "s") { return StandardModifiers.s(s: $0) }
		t.add(modifier: "ed") { return StandardModifiers.ed(s: $0) }
		t.add(modifier: "n") { input in
			return input + "\n"
		}
		
//		t.add(modifier: "k", transform: KalkInterpreter.interpret)

		KalkInterpreter.registerBuiltins()
		t.add(method: "k") { input, args in
			return input + KalkInterpreter.interpret(args[0])
		}

	}
	
}

