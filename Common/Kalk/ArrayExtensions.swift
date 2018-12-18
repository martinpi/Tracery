//
//  ArrayExtensions.swift
//  Ephemerald
//
//  Created by Martin Pichlmair on 24/10/2018.
//  Copyright © 2018 Broken Rules. All rights reserved.
//

import Foundation

extension Array where Element:Hashable {
	var orderedSet: Array {
		var unique = Set<Element>()
		return filter { element in
			return unique.insert(element).inserted
		}
	}
}

extension Collection where Indices.Iterator.Element == Index {
	subscript (safe index: Index) -> Iterator.Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

