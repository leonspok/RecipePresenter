//
//  RecipeViewController.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 31/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController, UIScrollViewDelegate, RecipeCastingTargetsBrowserDelegate {

	@IBOutlet weak var scrollView: UIScrollView?
	@IBOutlet weak var previewImage: UIImageView?
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var descriptionLabel: UILabel?
	@IBOutlet weak var suggestedDeviceButton: UIButton!
	
	var recipe: Recipe? = nil {
		didSet {
			self.updateRecipeInfo()
		}
	}
	
	lazy internal(set) var sessionManager: MCCastingSessionManager = {
		return MCCastingSessionManager()
	}()
	lazy internal(set) var browser: RecipeCastingTargetsBrowser = { [unowned self] in
		return MCTargetsBrowser.init(sessionManager: self.sessionManager)
	}()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.largeTitleDisplayMode = .never
		self.updateRecipeInfo()
		self.browser.delegate = self
		self.updateSuggestedDeviceButton()
		self.suggestedDeviceButton.layer.cornerRadius = 5.0
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.browser.startBrowsing()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.browser.stopBrowsing()
	}
	
	func updateSuggestedDeviceButton() {
		self.suggestedDeviceButton.isEnabled = self.browser.suggestedTarget != nil
		if let target = self.browser.suggestedTarget, let name = target.name {
			self.suggestedDeviceButton.setTitle("Present on \"\(name)\"", for: .normal)
		} else {
			self.suggestedDeviceButton.setTitle("0 devices available", for: .normal)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	internal func updateRecipeInfo() {
		if let recipe = self.recipe {
			self.title = recipe.title
			self.titleLabel?.text = recipe.title
			self.descriptionLabel?.text = recipe.description
			if let imageURLStr = recipe.previewImageURL, let imageURL = URL.init(string: imageURLStr) {
				DispatchQueue.global(qos: .userInteractive).async {
					if let data = try? Data.init(contentsOf: imageURL), let image = UIImage.init(data: data) {
						DispatchQueue.main.async { [weak self] in
							if let strongSelf = self {
								strongSelf.previewImage?.image = image
								strongSelf.previewImage?.superview?.setNeedsLayout()
								UIView.animate(withDuration: 0.2, animations: {
									strongSelf.previewImage?.superview?.layoutIfNeeded()
								})
							}
						}
					}
				}
			}
		} else {
			self.title = nil
			self.titleLabel?.text = nil
			self.descriptionLabel?.text = nil
			self.previewImage?.image = nil
		}
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y > 0 {
			self.previewImage?.transform = CGAffineTransform.init(translationX: 0, y: scrollView.contentOffset.y/3)
		} else {
			let ratio = 1.0+abs(scrollView.contentOffset.y)/100.0
			self.previewImage?.transform = CGAffineTransform.init(scaleX: ratio, y: ratio)
		}
	}
		
	@IBAction func presentOnSuggestedDevice(_ sender: Any) {
		let castingManager = MCCastingManager.init(sessionManager: self.sessionManager)
		castingManager.beginCasting(with: self.browser.suggestedTarget!, recipe: self.recipe!)
		
		let controlsVC = PresentingControlsViewController.init(nibName: String(describing: PresentingControlsViewController.self), bundle: nil)
		controlsVC.castingManager = castingManager
		controlsVC.modalPresentationStyle = .overFullScreen
		self.present(controlsVC, animated: true, completion: nil)
	}
	
	func targetsBrowser(_ targetsBrowser: RecipeCastingTargetsBrowser, updated suggestedTarget: RecipeCastingTarget?) {
		DispatchQueue.main.async {
			self.updateSuggestedDeviceButton()
		}
	}
	
	func targetsBrowser(_ targetsBrowser: RecipeCastingTargetsBrowser, found targets: [RecipeCastingTarget]) {
		//nothing to do
	}
}
