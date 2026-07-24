//
//  TagView.swift
//  recipe-nest
//
//  Created by David Yang on 7/24/26.
//

import UIKit

class TagView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        clipsToBounds = true
    }
}
