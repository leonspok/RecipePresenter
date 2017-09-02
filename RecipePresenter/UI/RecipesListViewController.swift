//
//  RecipesListViewController.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 31/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import UIKit

class RecipesListViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var tableView: UITableView!
	
	var storage: RecipesStorage?
	var recipes: [Recipe] = [] {
		didSet {
			self.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Recipes"
		self.navigationItem.largeTitleDisplayMode = .automatic
		
		self.navigationItem.searchController = UISearchController.init(searchResultsController: nil)
		self.navigationItem.searchController?.dimsBackgroundDuringPresentation = false
		self.navigationItem.searchController?.searchResultsUpdater = self
		
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
	
	func updateSearchResults(for searchController: UISearchController) {
		if let storage = self.storage, let query = searchController.searchBar.text {
			storage.findRecipe(query: query, completion: { (recipes) in
				DispatchQueue.main.async {
					self.recipes = recipes
				}
			})
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.recipes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		cell.textLabel?.text = self.recipes[indexPath.row].title
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let recipe = self.recipes[indexPath.row]
		let recipeVC = RecipeViewController.init(nibName: String(describing: RecipeViewController.self), bundle: nil)
		recipeVC.recipe = recipe
		if let _ = self.presentedViewController {
			self.dismiss(animated: true) {
				self.navigationController?.pushViewController(recipeVC, animated: true)
			}
		} else {
			self.navigationController?.pushViewController(recipeVC, animated: true)
		}
	}
}
