//
//  MethodTableViewCell.swift
//  recipe-nest
//
//  Created by David Yang on 7/30/26.
//

import UIKit

class MethodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var methodTable: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Remove the placeholder from storyboard
        methodTable.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func configure(steps: [String]) {
        methodTable.arrangedSubviews.forEach { $0.removeFromSuperview() }
        steps.enumerated().forEach { index, step in
            methodTable.addArrangedSubview(makeStepRow(index: index + 1, step: step))
        }
    }
    
    private func makeStepRow(index: Int, step: String) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        
        let number = UILabel()
        number.text = "\(index)"
        number.font = .systemFont(ofSize: 15, weight: .bold)
        number.textColor = .white
        number.textAlignment = .center
        number.backgroundColor = .systemBlue
        number.layer.cornerRadius = 13
        number.clipsToBounds = true
        number.translatesAutoresizingMaskIntoConstraints = false
        number.widthAnchor.constraint(equalToConstant: 26).isActive = true
        number.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        let label = UILabel()
        label.text = step
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        
        row.addArrangedSubview(number)
        row.addArrangedSubview(label)
        
        return row
    }
}
