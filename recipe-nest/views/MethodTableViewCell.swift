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
            methodTable.addArrangedSubview(makeStepRow(number: index + 1, step: step))
        }
    }
    
    private func makeStepRow(number: Int, step: String) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .firstBaseline
        row.spacing = 12
        
        let numberLabel = UILabel()
        numberLabel.text = "\(number)."
        numberLabel.font = .systemFont(ofSize: 17, weight: .bold)
        numberLabel.textColor = .systemBlue
        numberLabel.textAlignment = .center
        
        let label = UILabel()
        label.text = step
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        
        row.addArrangedSubview(numberLabel)
        row.addArrangedSubview(label)
        
        NSLayoutConstraint.activate([
            numberLabel.widthAnchor.constraint(equalToConstant: 28),
        ])
        return row
    }
}
