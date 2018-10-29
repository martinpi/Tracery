//
//  ExtensionCalls.swift
//  Tracery
//
//  Created by Benzi on 11/03/17.
//  Copyright © 2017 Benzi Ahamed. All rights reserved.
//

import XCTest
@testable import Tracery

class ExtensionCalls: XCTestCase {

    func testCallWithoutBrackets() {
        let t = Tracery()
        
        var invoked = false
		t.add(call: "msg") {_,_ in
            invoked = true
        }
        
        _ = t.expand("#.msg#")
        XCTAssertTrue(invoked)
    }
    
    func testCallWithBrackets() {
        let t = Tracery()
        
        var invoked = false
		t.add(call: "msg") {_,_ in
            invoked = true
        }
        
        _ = t.expand("#.msg()#")
        XCTAssertTrue(invoked)
    }

	func testCallWithArg() {
		let t = Tracery()
		
		var invoked = false
		t.add(call: "msg") {_,arguments in
			invoked = true
			XCTAssertTrue(arguments.count == 1)
		}
		
		_ = t.expand("#.msg(arg)#")
		XCTAssertTrue(invoked)
	}

	func testCallWithArgs() {
		let t = Tracery()
		
		var invoked = false
		t.add(call: "msg") {_,arguments in
			invoked = true
			XCTAssertTrue(arguments.count == 2)
		}
		
		_ = t.expand("#.msg(arg1,arg2)#")
		XCTAssertTrue(invoked)
	}
	
}
