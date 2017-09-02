//
//  RecipesStorageMock.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 30/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation

class RecipesStorageMock: RecipesStorage {
	func findRecipe(query: String, completion: @escaping ([Recipe]) -> ()) {
		DispatchQueue.global(qos: .userInteractive).async {
			let url = Bundle.main.url(forResource: "recipe", withExtension: "json")
			let decoder = JSONDecoder()
			if let recipeURL = url {
				do {
					let recipe =  try decoder.decode(Recipe.self, from: Data.init(contentsOf: recipeURL))
					let recipes = [recipe].filter({ (recipe) -> Bool in
						return query.count > 0 && recipe.title.lowercased().hasPrefix(query.lowercased())
					})
					completion(recipes)
				} catch _ {
					completion([])
				}
			} else {
				completion([])
			}
		}
	}
}
