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

	func testPlaintextFormatAllowsMultiRuleCreation() {
		
		let lines = [
			"[origin]",
			"#second#",
//			"",
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
