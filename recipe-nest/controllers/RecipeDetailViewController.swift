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
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "RecipeHeaderViewCell", for: indexPath)
        }
        return tableView.dequeueReusableCell(withIdentifier: "IngredientTableViewCell", for: indexPath)
    }
}
