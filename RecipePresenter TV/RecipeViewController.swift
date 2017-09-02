//
//  RecipeViewController.swift
//  RecipePresenter TV
//
//  Created by Игорь Савельев on 02/09/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController, RecipePresentingManagerDelegate {
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var stepVCContainer: UIView?
	
	var manager: MCPresentingManager? {
		didSet {
			if let manager = self.manager {
				manager.delegate = self
			}
		}
	}
	var recipe: Recipe? {
		didSet {
			self.stepIndex = 0
			updateCurrentStep()
		}
	}
	var stepIndex: UInt = 0 {
		didSet {
			if let recipe = self.recipe {
				self.titleLabel?.text = "Step \(self.stepIndex+1) of \(recipe.steps.count)"
			}
			self.manager?.send(.stepChanged(index: self.stepIndex))
		}
	}
	var currentStepVC: RecipeStepViewController? = nil {
		didSet {
			if let vc = self.currentStepVC, let container = self.stepVCContainer {
				vc.view.frame = container.bounds
				vc.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
				container.addSubview(vc.view)
				self.addChildViewController(vc)
				vc.didMove(toParentViewController: self)
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		updateCurrentStep()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func updateCurrentStep() {
		if let recipe = self.recipe, self.stepIndex >= 0, self.stepIndex < recipe.steps.count {
			let newVC = RecipeStepViewController.init(nibName: String(describing: RecipeStepViewController.self), bundle: nil)
			newVC.step = recipe.steps[Int(self.stepIndex)]
			self.currentStepVC = newVC
		}
	}
	
	func moveToNextStep(animated: Bool) {
		guard let recipe = self.recipe, self.stepIndex < recipe.steps.count-1 else {
			return
		}
		if (animated) {
			if let vc = self.currentStepVC {
				UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: [.allowAnimatedContent], animations: {
					vc.view.transform = CGAffineTransform.init(translationX: -100.0, y: 0)
					vc.view.alpha = 0
				}, completion: { (result) in
					vc.view.removeFromSuperview()
					vc.removeFromParentViewController()
				})
			}
			let newVC = RecipeStepViewController.init(nibName: String(describing: RecipeStepViewController.self), bundle: nil)
			self.stepIndex += 1
			newVC.step = recipe.steps[Int(self.stepIndex)]
			self.currentStepVC = newVC
			newVC.view.transform = CGAffineTransform.init(translationX: 100.0, y: 0)
			newVC.view.alpha = 0
			UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: [.allowAnimatedContent], animations: {
				newVC.view.transform = .identity
				newVC.view.alpha = 1.0
			}, completion: nil)
		} else {
			if let vc = self.currentStepVC {
				vc.view.removeFromSuperview()
				vc.removeFromParentViewController()
			}
			let newVC = RecipeStepViewController.init(nibName: String(describing: RecipeStepViewController.self), bundle: nil)
			self.stepIndex += 1
			newVC.step = recipe.steps[Int(self.stepIndex)]
			self.currentStepVC = newVC
		}
	}
	
	func moveToPreviousStep(animated: Bool) {
		guard let recipe = self.recipe, self.stepIndex > 0 else {
			return
		}
		if (animated) {
			if let vc = self.currentStepVC {
				UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: [.allowAnimatedContent], animations: {
					vc.view.transform = CGAffineTransform.init(translationX: 100.0, y: 0)
					vc.view.alpha = 0
				}, completion: { (result) in
					vc.view.removeFromSuperview()
					vc.removeFromParentViewController()
				})
			}
			let newVC = RecipeStepViewController.init(nibName: String(describing: RecipeStepViewController.self), bundle: nil)
			self.stepIndex -= 1
			newVC.step = recipe.steps[Int(self.stepIndex)]
			self.currentStepVC = newVC
			newVC.view.transform = CGAffineTransform.init(translationX: -100.0, y: 0)
			newVC.view.alpha = 0
			UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: [.allowAnimatedContent], animations: {
				newVC.view.transform = .identity
				newVC.view.alpha = 1.0
			}, completion: nil)
		} else {
			if let vc = self.currentStepVC {
				vc.view.removeFromSuperview()
				vc.removeFromParentViewController()
			}
			let newVC = RecipeStepViewController.init(nibName: String(describing: RecipeStepViewController.self), bundle: nil)
			self.stepIndex -= 1
			newVC.step = recipe.steps[Int(self.stepIndex)]
			self.currentStepVC = newVC
		}
	}
    
	@IBAction func goToNextStep(_ sender: Any) {
		self.moveToNextStep(animated: true)
	}
	
	@IBAction func goToPreviousStep(_ sender: Any) {
		self.moveToPreviousStep(animated: true)
	}
	
	@IBAction func disconnectAndClose(_ sender: Any) {
		self.manager?.disconnect()
	}
	
	func presentingManager(_ presentingManager: RecipePresentingManager, received action: RecipeCastingAction) {
		DispatchQueue.main.async {
			switch action {
			case .moveForward:
				self.goToNextStep(presentingManager)
			case .moveBackward:
				self.goToPreviousStep(presentingManager)
			case let .start(recipe: recipe):
				self.recipe = recipe
			case .stop:
				self.disconnectAndClose(presentingManager)
			default:
				break;
			}
		}
	}
	
	func lostConnection(_ presentingManager: RecipePresentingManager) {
		DispatchQueue.main.async {
			self.presentingViewController?.dismiss(animated: true, completion: nil)
		}
	}
}
