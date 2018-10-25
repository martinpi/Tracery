//
//  RandomSource.swift
//  Tracery iOS
//
//  Created by Martin Pichlmair on 25/10/2018.
//  Copyright © 2018 Benzi Ahamed. All rights reserved.
//

import Foundation
import GameKit

public protocol RandomSource {
	func next() -> Float
	func next(lowestValue: Int, highestValue: Int) -> Int
}

class FallbackRandomSource : RandomSource {
	static var shared = FallbackRandomSource()
	
	public func next(lowestValue: Int, highestValue: Int) -> Int {
		return Int.random(in: lowestValue..<highestValue)
	}
	
	public func next() -> Float {
		return Float.random(in: 0..<1)
	}
	
	init() {
	}
}


class DefaultRandomSource : RandomSource {
	
	var source: GKARC4RandomSource
	
	public func next(lowestValue: Int, highestValue: Int) -> Int {
		let random = GKRandomDistribution(randomSource: source, lowestValue: lowestValue, highestValue: highestValue)
		return random.nextInt()
	}
	
	public func next() -> Float {
		return source.nextUniform()
	}
	
	init(seed: Data) {
		source = GKARC4RandomSource(seed: seed)
	}

}
