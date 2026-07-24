//
//  RecipeHeaderViewCell.swift
//  
//
//  Created by David Yang on 7/23/26.
//

import UIKit

class RecipeHeaderViewCell: UITableViewCell {
    
    @IBOutlet weak var tagStack: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Remove placeholder tags from the view
        tagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
