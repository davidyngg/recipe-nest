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
    
    func configure(tags: [String]) {
        tagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tags.forEach { tagStack.addArrangedSubview(makeTag($0)) }
    }
    
    private func makeTag(_ text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.textAlignment = .center
        
        let pill = TagView()
        pill.backgroundColor = .systemGray6
        pill.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: pill.topAnchor, constant: 3),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -3),
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -6),
        ])
        return pill
    }
}
