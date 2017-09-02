//
//  RootViewController.swift
//  RecipePresenter TV
//
//  Created by Игорь Савельев on 02/09/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, RecipePresentingAdvertiserDelegate {
	let sessionManager = MCPresentingSessionManager()
	lazy var advertiser: MCPresentingAdvertiser = { [unowned self] in
		var advertiser = MCPresentingAdvertiser.init(sessionManager: self.sessionManager)
		advertiser.delegate = self
		return advertiser
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		self.advertiser.startAdvertising()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func advertiser(_ advertiser: RecipePresentingAdvertiser, receivedInviteFrom source: RecipePresentingSource, response: (Bool) -> Void) {
		guard source is MCPresentingSource else {
			response(false)
			return
		}
		response(true)
	}
	
	func advertiser(_ advertiser: RecipePresentingAdvertiser, successfullyInvitedFrom source: RecipePresentingSource) {
		guard let source = source as? MCPresentingSource else {
			return
		}
		
		let manager = MCPresentingManager.init(sessionManager: self.sessionManager, source: source)
		DispatchQueue.main.async {
			let recipeVC = RecipeViewController.init(nibName: String(describing: RecipeViewController.self), bundle: nil)
			recipeVC.manager = manager
			self.present(recipeVC, animated: true, completion: nil)
		}
	}
}
