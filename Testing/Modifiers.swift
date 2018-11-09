//
//  Modifiers.swift
//  Tracery
//
//  Created by Martin Pichlmair on 09/10/2018.
//  Copyright © 2018 Benzi Ahamed. All rights reserved.
//

import Foundation

import XCTest
@testable import Tracery

class TestModifiers: XCTestCase {

	func testCapitalisation() {
		let t = Tracery()
		t.add(object: "jack", named: "person")
		XCTAssertEqual(t.expand("#person.uppercase#"), "JACK")
		XCTAssertEqual(t.expand("#person.lowercase#"), "jack")
		XCTAssertEqual(t.expand("#person.caps#"), "Jack")
	}
	
	func testSigns() {
		let t = Tracery()
		t.add(object: "harpy", named: "creature")
		XCTAssertEqual(t.expand("#creature.inQuotes#"), "\"harpy\"")
		XCTAssertEqual(t.expand("#creature.comma#"), "harpy, ")
	}
	
	func testSuffizes() {
		let t = Tracery()
		t.add(object: "harpy", named: "creature")
		XCTAssertEqual(t.expand("#creature.a#"), "a harpy")
		XCTAssertEqual(t.expand("#creature.s#"), "harpies")
		XCTAssertEqual(t.expand("#creature.ed#"), "harpied")
	}

}

