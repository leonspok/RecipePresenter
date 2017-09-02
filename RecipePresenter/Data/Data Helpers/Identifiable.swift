//
//  Identifiable.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 30/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation

protocol Identifiable: Hashable {
	typealias Identifier = GenericIdentifier<Self>
	var uid: Identifier? { get set }
}

func ==<T: Identifiable> (lhs: T, rhs: T) -> Bool {
	guard let lhsUID = lhs.uid, let rhsUID = rhs.uid else {
		return false
	}
	return lhsUID == rhsUID
}
