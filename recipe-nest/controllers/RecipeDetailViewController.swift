//
//  RecipeDetailViewController.swift
//  
//
//  Created by David Yang on 7/23/26.
//

import UIKit

class RecipeDetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(editRecipeTapped)
    }

    // Opens the shared recipe form prefilled with this recipe's data.
    @objc private func editRecipeTapped() {
        let draft = DraftRecipe(
            name: name,
            time: time,
            serves: serves,
            ingredients: ingredients,
            steps: steps,
            image: nil)
        let editViewController = CreateRecipeViewController(draftToEdit: draft)
        editViewController.onSave = { updatedDraft in
            print("Recipe updated: \(updatedDraft.name)")
        }
        present(UINavigationController(rootViewController: editViewController), animated: true)
    }
}

// TEMP: Recipe test data
let name = "Spanish Omelette"
let time = "10 min"
let serves = "4"
let tags: [String] = [time, serves, "dairy-free", "nut-free"]
let ingredients: [String] = ["2 large eggs", "1/2 cup milk", "1/4 cup grated Parmesan cheese", "Salt and pepper to taste"]
let steps: [String] = ["Step 1", "Step 2", "Step 3"]
// TEMP: Recipe test data

// MARK: - UITableViewDataSource

extension RecipeDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ////
        // Recipe header table cell
        ////
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeHeaderViewCell", for: indexPath)
            as! RecipeHeaderViewCell
            cell.configure(name: name, tags: tags)
            return cell
        }
        
        ////
        // Recipe ingredients table cell
        ////
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableViewCell", for: indexPath)
            as! IngredientTableViewCell
            
            cell.configure(ingredients: ingredients)
            
            return cell
        }
        
        ////
        // Recipe method table cell
        ////
        let cell = tableView.dequeueReusableCell(withIdentifier: "MethodTableViewCell", for: indexPath)
        as! MethodTableViewCell
        
        cell.configure(steps: steps)
        
        return cell
    }
}
