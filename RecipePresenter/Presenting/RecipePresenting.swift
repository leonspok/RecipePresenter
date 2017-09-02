//
//  RecipePresenting.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 01/09/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation

protocol RecipePresentingAdvertiser {
	var delegate: RecipePresentingAdvertiserDelegate? { get set }
	
	func startAdvertising()
	func stopAdvertising()
}

protocol RecipePresentingAdvertiserDelegate {
	func advertiser(_ advertiser: RecipePresentingAdvertiser, receivedInviteFrom source: RecipePresentingSource, response: (Bool) -> Void)
	func advertiser(_ advertiser: RecipePresentingAdvertiser, successfullyInvitedFrom source: RecipePresentingSource)
}

protocol RecipePresentingSource {
	var name: String! { get }
}

protocol RecipePresentingManager {
	var presentingRecipe: Recipe? { get }
	var source: RecipePresentingSource { get }
	var delegate: RecipePresentingManagerDelegate? { get set }
	
	func disconnect()
	func send(_ callback: RecipeCastingCallback)
}

enum RecipePresentingManagerState {
	case starting
	case presenting(stepIndex: UInt)
	case finishing
}

protocol RecipePresentingManagerDelegate {
	func presentingManager(_ presentingManager: RecipePresentingManager, received action: RecipeCastingAction)
	func lostConnection(_ presentingManager: RecipePresentingManager)
}
