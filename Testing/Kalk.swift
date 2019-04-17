//
//  Kalk.swift
//  Tracery
//
//  Created by Martin Pichlmair on 07/02/2019.
//  Copyright © 2019 Benzi Ahamed. All rights reserved.
//

import XCTest
@testable import Tracery

class Kalk: XCTestCase {

    func testKalk() {
		let t = Tracery()
		t.add(object: "2+2", named: "kalk")
		t.add(object: "int(2.0)", named: "kalk2")
		t.add(object: "int(sqr(2.0))", named: "kalkSqr")
		t.add(object: "int(pow(2.0,3.0))", named: "kalkPow")
		t.add(object: "int(rand(3.0,10.0))", named: "kalkRand2")
		t.add(object: "int(rand(10,30))", named: "kalkRand3")
		XCTAssertEqual(t.expand("#.k(#kalk#)#"), "4.0")
		XCTAssertEqual(t.expand("#.k(#kalk2#)#"), "2")
		XCTAssertEqual(t.expand("#.k(#kalkSqr#)#"), "4")
		XCTAssertEqual(t.expand("#.k(#kalkPow#)#"), "8")
		XCTAssertLessThan(Double(t.expand("#.k(#kalkRand2#)#"))!, 10.0)
		XCTAssertGreaterThan(Double(t.expand("#.k(#kalkRand2#)#"))!, 2.99)
		XCTAssertLessThan(Double(t.expand("#.k(#kalkRand3#)#"))!, 30.0)
		XCTAssertGreaterThan(Double(t.expand("#.k(#kalkRand3#)#"))!, 9.99)
    }
	
//	func testKalk2() {
//		let t = Tracery()
//		Tracery.logLevel = .verbose
//		XCTAssertEqual(t.expand("[=2+2]"), "4.0")
//	}

}
