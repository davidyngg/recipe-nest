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
    }
}

// MARK: - UITableViewDataSource

extension RecipeDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ////
        // Recipe header table cell
        ////
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeHeaderViewCell", for: indexPath)
            as! RecipeHeaderViewCell
            cell.configure(tags: ["vegan", "gluten-free", "dairy-free", "nut-free"])
            return cell
        }
        
        ////
        // Recipe ingredients table cell
        ////
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableViewCell", for: indexPath)
        as! IngredientTableViewCell
        
        cell.configure(ingredients: ["2 cups flour", "1 tsp salt", "3 eggs", "1 cup milk"])
        
        return cell
    }
}
