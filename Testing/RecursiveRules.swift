//
//  RecursiveRules.swift
//  Tracery
//
//  Created by Benzi on 11/03/17.
//  Copyright © 2017 Benzi Ahamed. All rights reserved.
//

import XCTest
@testable import Tracery

class RecursiveRules: XCTestCase {

    var limit = 0
    
    override func setUp() {
        limit = Tracery.maxStackDepth
		
		// disable so we can test actual case instead of fake:
//        Tracery.maxStackDepth = 20
    }
    
    override func tearDown() {
        Tracery.maxStackDepth = limit
    }
    
    func testStackOverflow() {
        let t = Tracery {[
            "a": "#b#",
            "b": "#a#",
            ]}
        XCTAssertTrue(t.expand("#a#").contains("stack overflow"))
    }

	func testStackOverflow2() {
		let t = Tracery {[
			"a": "#a# -- #a#",
			]}
		XCTAssertTrue(t.expand("#a#").contains("stack overflow"))
	}
}
