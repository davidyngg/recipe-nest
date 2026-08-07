//
//  RecipeDetailViewController.swift
//  
//
//  Created by David Yang on 7/23/26.
//

import UIKit

class RecipeDetailViewController: UIViewController {

    // Set by MyRecipesViewController when opening a recipe from the list.
    var recipe: Recipe?

    // TEMP: Default draft values.
    var draft = DraftRecipe(
        name: "Spanish Omelette",
        time: "10 min",
        serves: "4",
        ingredients: ["2 large eggs", "1/2 cup milk", "1/4 cup grated Parmesan cheese", "Salt and pepper to taste"],
        steps: ["Step 1", "Step 2", "Step 3"],
        image: nil)

    // TEMP: Misc tags
    private let miscTags = ["misc-tag 1", "misc-tag 2"]

    // Time and serves are shown as tag pills alongside the dietary tags.
    private var tags: [String] {
        [draft.time, "Serves " + draft.serves].filter { !$0.isEmpty } + miscTags
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let recipe {
            title = recipe.name
        }

        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(editRecipeTapped)
    }

    // Opens the shared recipe form prefilled with this recipe's data.
    @objc private func editRecipeTapped() {
        let editViewController = CreateRecipeViewController(draftToEdit: draft)
        editViewController.onSave = { [weak self] updatedDraft in
            self?.draft = updatedDraft
            (self?.view as? UITableView)?.reloadData()
        }
        present(UINavigationController(rootViewController: editViewController), animated: true)
    }
}

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
            cell.configure(name: draft.name, tags: tags, image: draft.image)
            return cell
        }
        
        ////
        // Recipe ingredients table cell
        ////
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableViewCell", for: indexPath)
            as! IngredientTableViewCell
            
            cell.configure(ingredients: draft.ingredients)
            
            return cell
        }
        
        ////
        // Recipe method table cell
        ////
        let cell = tableView.dequeueReusableCell(withIdentifier: "MethodTableViewCell", for: indexPath)
        as! MethodTableViewCell
        
        cell.configure(steps: draft.steps)
        
        return cell
    }
}
