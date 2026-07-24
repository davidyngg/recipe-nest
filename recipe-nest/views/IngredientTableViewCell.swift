//
//  IngredientTableViewCell.swift
//  
//
//  Created by David Yang on 7/23/26.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ingredientTable: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Remove the placeholder from storyboard
        ingredientTable.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func configure(ingredients: [String]) {
        ingredientTable.arrangedSubviews.forEach { $0.removeFromSuperview() }
        ingredients.forEach {
            ingredientTable.addArrangedSubview(makeIngredientRow(ingredient: $0))
        }
    }
    
    // Handle checkmark toggling
    @objc private func checkboxTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    private func makeIngredientRow(ingredient: String) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 0
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let checkboxButton = UIButton()
        checkboxButton.contentHorizontalAlignment = .leading
        checkboxButton.setTitle(nil, for: .normal)
        checkboxButton.setImage(UIImage(systemName: "circle", withConfiguration: symbolConfig)?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal), for: .normal)
        checkboxButton.setImage(
            UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfig)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .selected)
        
        // Allow user to tap checkbox.
        checkboxButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        
        let label = UILabel()
        label.text = ingredient
        label.font = .systemFont(ofSize: 17)
        
        row.addArrangedSubview(checkboxButton)
        row.addArrangedSubview(label)
        
        NSLayoutConstraint.activate([
            checkboxButton.widthAnchor.constraint(equalToConstant: 44),
            checkboxButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        return row
    }
}
