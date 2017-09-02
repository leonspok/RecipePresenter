//
//  RecipeTranslator.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 31/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation

protocol RecipeCastingTargetsBrowser {
	var suggestedTarget: RecipeCastingTarget? { get }
	var targets: [RecipeCastingTarget] { get }
	var delegate: RecipeCastingTargetsBrowserDelegate? { get set }
	
	func startBrowsing()
	func stopBrowsing()
}

protocol RecipeCastingTargetsBrowserDelegate {
	func targetsBrowser(_ targetsBrowser: RecipeCastingTargetsBrowser, updated suggestedTarget: RecipeCastingTarget?)
	func targetsBrowser(_ targetsBrowser: RecipeCastingTargetsBrowser, found targets: [RecipeCastingTarget])
}

protocol RecipeCastingTarget {
	var name: String! { get }
}

protocol RecipeCastingManager {
	var castingRecipe: Recipe? { get }
	var state: RecipeCastingManagerState { get }
	var currentTarget: RecipeCastingTarget? { get }
	var delegate: RecipeCastingManagerDelegate? { get set }
	
	func beginCasting(with target: RecipeCastingTarget, recipe: Recipe)
	func endCasting()
	
	func send(_ action: RecipeCastingAction)
}

enum RecipeCastingManagerState {
	case waiting
	case casting
	case idle
}

protocol RecipeCastingManagerDelegate {
	func castingManager(_ manager: RecipeCastingManager, received callback: RecipeCastingCallback)
	func castingManager(_ manager: RecipeCastingManager, updated state: RecipeCastingManagerState)
}
