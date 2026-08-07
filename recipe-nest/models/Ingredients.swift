//
//  Ingredients.swift
//
//
//  Created by David Yang on 7/23/26.
//

import Foundation

struct Ingredient: Codable, Hashable {
    var name: String
    var quantity: String

    var displayText: String {
        quantity.isEmpty ? name : "\(quantity) \(name)"
    }
}
