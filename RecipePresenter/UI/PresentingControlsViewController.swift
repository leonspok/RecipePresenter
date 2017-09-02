//
//  PresentingControlsViewController.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 02/09/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import UIKit

class PresentingControlsViewController: UIViewController, RecipeCastingManagerDelegate {
	
	var castingManager: RecipeCastingManager? {
		didSet {
			self.castingManager?.delegate = self
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func disconnectAndClose(_ sender: Any) {
		if let manager = self.castingManager {
			manager.endCasting()
		}
		self.presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func goNext(_ sender: Any) {
		if let manager = self.castingManager {
			manager.send(.moveForward)
		}
	}
	
	@IBAction func goBack(_ sender: Any) {
		if let manager = self.castingManager {
			manager.send(.moveBackward)
		}
	}
	
	func castingManager(_ manager: RecipeCastingManager, received callback: RecipeCastingCallback) {
		print(callback)
	}
	
	func castingManager(_ manager: RecipeCastingManager, updated state: RecipeCastingManagerState) {
		if state == .idle {
			self.disconnectAndClose(self)
		}
	}
}
