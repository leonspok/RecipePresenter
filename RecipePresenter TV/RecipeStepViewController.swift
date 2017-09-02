//
//  RecipeStepViewController.swift
//  RecipePresenter TV
//
//  Created by Игорь Савельев on 02/09/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import UIKit

class RecipeStepViewController: UIViewController, UITableViewDataSource {
	@IBOutlet weak var textLabel: UILabel?
	@IBOutlet weak var tableView: UITableView?
	
	var step: Recipe.Step? = nil {
		didSet {
			updateStepInfo()
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.textLabel?.superview?.layer.cornerRadius = 20.0
		updateStepInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func updateStepInfo() {
		if let step = self.step {
			self.textLabel?.text = step.fullDescription
		} else {
			self.textLabel?.text = nil
		}
		self.tableView?.reloadData()
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let step = self.step else {
			return 0
		}
		switch section {
		case 0:
			return step.ingredients.count
		case 1:
			return step.instruments.count
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell = {
			guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
				return UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
			}
			return cell
		}()
		
		guard let step = self.step else {
			return cell
		}
		switch indexPath.section {
		case 0:
			let ingredient = step.ingredients[indexPath.row]
			cell.textLabel?.text = ingredient.name
			switch ingredient.amount {
			case let Recipe.Ingredient.Amount.indefinite(tip: tip):
				cell.detailTextLabel?.text = tip
			case let Recipe.Ingredient.Amount.definite(amount: amount, unit: unit):
				if let unit = unit {
					cell.detailTextLabel?.text = "\(amount) \(unit)"
				} else {
					cell.detailTextLabel?.text = "\(amount)"
				}
			}
		case 1:
			let instrument = step.instruments[indexPath.row]
			cell.textLabel?.text = instrument.name
			cell.detailTextLabel?.text = "x \(instrument.amount)"
		default:
			break
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Ingredients"
		case 1:
			return "Instruments"
		default:
			return ""
		}
	}
}
