//
//  RecipesProvider.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 30/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation

protocol RecipesStorage {
	func findRecipe(query: String, completion: @escaping ([Recipe]) -> ()) -> Void
}
