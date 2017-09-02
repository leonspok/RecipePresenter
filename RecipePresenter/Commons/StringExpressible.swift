//
//  StringExpressible.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 30/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation

extension URL : ExpressibleByStringLiteral {
	public typealias StringLiteralType = String
	public init(stringLiteral value: StringLiteralType) {
		self = URL(string: value)!
	}
}
