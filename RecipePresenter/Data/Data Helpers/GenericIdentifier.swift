//
//  GenericIdentifier.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 30/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation

struct GenericIdentifier<T>: RawRepresentable, Hashable, Equatable {
	var hashValue: Int {
		return self.rawValue.hashValue
	}
	
	typealias RawValue = String
	
	let rawValue: RawValue
	init?(rawValue: RawValue) {
		self.rawValue = rawValue
	}
}
