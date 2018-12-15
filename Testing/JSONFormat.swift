//
//  JSONFormat.swift
//  Tracery
//
//  Created by Martin Pichlmair on 27/11/2018.
//  Copyright © 2018 Benzi Ahamed. All rights reserved.
//

import XCTest
@testable import Tracery

class JSONFormat: XCTestCase {

    func testExample() {
		let lines = [
		"{",
			"\"origin\" : [",
			"\"#chain#\"",
			"],",
			"\"chain\" : [",
			"\"hello world\"",
			"]",
		"}"]
		
		let t = Tracery(json: lines)
		XCTAssertEqual(t.expand("#origin#"), "hello world")
    }
}
