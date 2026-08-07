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

    // Time and serves are shown as tag pills alongside the dietary tags.
    private var tags: [String] {
        guard let recipe else { return [] }
        return [recipe.timeLabel, "Serves \(recipe.servings)"] + recipe.sortedTagTexts
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = recipe?.name

        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(editRecipeTapped)
    }

    // Opens the shared recipe form prefilled with this recipe's data.
    @objc private func editRecipeTapped() {
        guard let recipe else { return }
        let editViewController = CreateRecipeViewController(draftToEdit: DraftRecipe(recipe: recipe))
        editViewController.onSave = { [weak self] updatedDraft in
            guard let self, let recipe = self.recipe else { return }
            recipe.apply(updatedDraft)
            RecipeStore.shared.save()
            self.title = recipe.name
            (self.view as? UITableView)?.reloadData()
        }
        present(UINavigationController(rootViewController: editViewController), animated: true)
    }
}

// MARK: - UITableViewDataSource

extension RecipeDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe == nil ? 0 : 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipe else { return UITableViewCell() }

        ////
        // Recipe header table cell
        ////
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeHeaderViewCell", for: indexPath)
            as! RecipeHeaderViewCell
            cell.configure(name: recipe.name ?? "", tags: tags, image: recipe.image, placeholderColor: recipe.thumbnailColor)
            return cell
        }

        ////
        // Recipe ingredients table cell
        ////
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableViewCell", for: indexPath)
            as! IngredientTableViewCell

            cell.configure(ingredients: recipe.sortedIngredients.compactMap(\.name))

            return cell
        }

        ////
        // Recipe method table cell
        ////
        let cell = tableView.dequeueReusableCell(withIdentifier: "MethodTableViewCell", for: indexPath)
        as! MethodTableViewCell

        cell.configure(steps: recipe.stepList)

        return cell
    }
}
