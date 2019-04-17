//
//  TextFormat.swift
//  Tracery
//
//  Created by Benzi on 21/03/17.
//  Copyright © 2017 Benzi Ahamed. All rights reserved.
//

import XCTest
@testable import Tracery

class TextFormat: XCTestCase {

    
    func testPlaintextFormat() {
     
        let lines = [
            "[origin]",
            "hello world",
        ]
        
        let t = Tracery(lines: lines)
        
        XCTAssertEqual(t.expand("#origin#"), "hello world")
        
    }
	
	func testPlaintextFormatMultiline() {
		
		let fableFile = Bundle(for: type(of: self)).path(forResource: "fable", ofType: "txt")!
		let t = Tracery.init(path: fableFile)
		
			print(t.expand("#multiline#"))
			XCTAssertFalse(t.expand("#multiline#").isEmpty)
			XCTAssertEqual(t.expand("#multiline#"), "the first\nthe second")

	}

	func testPlaintextFormatRegexp() {
		
		let lines = [
			"//string==>gift",
			"//cow==>curse",
			"[origin]",
			"This string is a cow",
			]
		
		let t = Tracery(lines: lines)

		print(t.expand("#origin#"))
		XCTAssertEqual(t.expand("#origin#"), "This gift is a curse")

	}
	
	func testRegexp() {
		let rex = RegularExpressions()
		
		rex.patterns["a"] = "A"
		rex.patterns["b"] = "B"
		rex.patterns["[0-9]"] = "Oh"

		XCTAssertEqual(rex.applyAll("abba"), "ABBA")
		XCTAssertEqual(rex.applyAll("0123"), "OhOhOhOh")
	}
	
	func testPlaintextFormatAllowsMultiRuleCreation() {
		
		let lines = [
			"[origin]",
			"#second#",
			"[second]",
			"overwritten",
			"[second]",
			"result",
			]
		
		let t = Tracery(lines: lines)
		
		XCTAssertEqual(t.expand("#origin#"), "result")
		
	}

    
    func testPlaintextFormatAllowsEmptyRuleCreation() {

        let lines = [
            "[binary]",
            "0#binary#",
            "1#binary#",
            "#empty#",
            "",
            "[empty]",
            ]
        
        let t = Tracery(lines: lines)
        
        XCTAssertFalse(t.expand("#binary#").contains("stack overflow"))

    }
    
    func testPlaintextFile() {
        
        let fableFile = Bundle(for: type(of: self)).path(forResource: "fable", ofType: "txt")!
        let t = Tracery.init(path: fableFile)
        
        for _ in 0..<10 {
			print(t.expand("#fable#"))
            XCTAssertFalse(t.expand("#fable#").isEmpty)
        }
        
    }
    
}
