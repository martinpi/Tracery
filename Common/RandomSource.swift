//
//  RandomSource.swift
//  Tracery iOS
//
//  Created by Martin Pichlmair on 25/10/2018.
//  Copyright © 2018 Benzi Ahamed. All rights reserved.
//

import Foundation
import GameKit

@objc public protocol RandomSource {
	func next() -> Float
	func next(lowestValue: Int, highestValue: Int) -> Int
}

// this random source is a drop-in replacement for the original implementation
@objc public class FallbackRandomSource : NSObject, RandomSource {
	static var shared = FallbackRandomSource()
	
	public func next(lowestValue: Int, highestValue: Int) -> Int {
		return Int.random(in: lowestValue..<highestValue)
	}
	
	public func next() -> Float {
		return Float.random(in: 0..<1)
	}
}

// by using a single source and a set seed we can make sure that results can be reproduced with this source
@objc public class DeterministicRandomSource : NSObject, RandomSource {
	
	var source: GKARC4RandomSource
	
	public func next(lowestValue: Int, highestValue: Int) -> Int {
		let random = GKRandomDistribution(randomSource: source, lowestValue: lowestValue, highestValue: highestValue-1)
		return random.nextInt()
	}
	
	public func next() -> Float {
		return source.nextUniform()
	}
	
	init(seed: Data) {
		source = GKARC4RandomSource(seed: seed)
		source.dropValues(1024)
		super.init()
	}

}
