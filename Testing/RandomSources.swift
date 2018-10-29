//
//  RandomSources.swift
//  Tracery
//
//  Created by Martin Pichlmair on 29/10/2018.
//  Copyright © 2018 Benzi Ahamed. All rights reserved.
//

import XCTest
@testable import Tracery

class RandomSources: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testDefaultRandom() {
		let rs = FallbackRandomSource.shared
		for _ in 0..<1000 {
			let v = rs.next(lowestValue: 0, highestValue: 10)
			XCTAssertTrue(v >= 0 && v < 10)
		}
	}

	func testDeterministicRandomRange() {
		let seed = 333
		var s = seed
		let data = withUnsafePointer(to: &s) {
			Data(bytes: UnsafePointer($0), count: MemoryLayout.size(ofValue: seed))
		}
		
		let rs = DeterministicRandomSource(seed: data )
		for _ in 0..<1000 {
			let v = rs.next(lowestValue: 0, highestValue: 10)
			XCTAssertTrue(v >= 0 && v < 10)
		}
	}

	func testDeterministicRandomDeterminism() {
		let seed = 333
		var s = seed
		let data = withUnsafePointer(to: &s) {
			Data(bytes: UnsafePointer($0), count: MemoryLayout.size(ofValue: seed))
		}
		
		let rs1 = DeterministicRandomSource(seed: data )
		let rs2 = DeterministicRandomSource(seed: data )
		for _ in 0..<1000 {
			XCTAssertTrue(rs1.next() == rs2.next())
		}
	}

}
