//
//  Recipes.swift
//
//
//  Created by David Yang on 7/23/26.
//

import Foundation
import UIKit

struct Recipe: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var category: String
    var timeMinutes: Int
    var servings: Int
    var tags: [String]
    var ingredients: [Ingredient]
    var steps: [String]
    var thumbnailColorHex: String

    var timeLabel: String {
        timeMinutes >= 60 && timeMinutes % 60 == 0 ? "\(timeMinutes / 60) hr" : "\(timeMinutes) min"
    }

    var thumbnailColor: UIColor {
        UIColor(hex: thumbnailColorHex)
    }
}

final class RecipeStore {
    static let shared = RecipeStore()

    private(set) var recipes: [Recipe] = []

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("recipes.json")
    }()

    private init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Recipe].self, from: data) else {
            recipes = Recipe.sampleRecipes
            return
        }
        recipes = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(recipes) else { return }
        try? data.write(to: fileURL)
    }

    func add(_ recipe: Recipe) {
        recipes.append(recipe)
        save()
    }

    func update(_ recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[index] = recipe
        save()
    }

    func delete(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
        save()
    }
}

extension Recipe {
    static let sampleRecipes: [Recipe] = [
        Recipe(name: "Miso Butter Salmon", category: "Dinner", timeMinutes: 45, servings: 4,
               tags: ["pescatarian", "gluten-free"],
               ingredients: [
                Ingredient(name: "salmon fillets", quantity: "2"),
                Ingredient(name: "white miso", quantity: "2 tbsp"),
                Ingredient(name: "butter, softened", quantity: "3 tbsp"),
                Ingredient(name: "soy sauce", quantity: "1 tbsp"),
                Ingredient(name: "scallions, sliced", quantity: "2"),
                Ingredient(name: "steamed rice, to serve", quantity: ""),
               ],
               steps: [
                "Pat the salmon dry and season lightly with salt.",
                "Whisk the miso, soft butter and soy into a smooth paste.",
                "Sear salmon skin-side down 4 min, flip, then spoon over the miso butter.",
                "Rest 2 min, scatter scallions and serve over rice.",
               ],
               thumbnailColorHex: "#D98255"),
        Recipe(name: "Weeknight Carbonara", category: "Quick", timeMinutes: 25, servings: 2,
               tags: ["vegetarian-friendly"],
               ingredients: [
                Ingredient(name: "spaghetti", quantity: "200g"),
                Ingredient(name: "eggs", quantity: "2"),
                Ingredient(name: "parmesan, grated", quantity: "50g"),
                Ingredient(name: "guanciale, diced", quantity: "100g"),
                Ingredient(name: "black pepper", quantity: "to taste"),
               ],
               steps: [
                "Boil the spaghetti in salted water until al dente.",
                "Render the guanciale in a cold pan until crisp.",
                "Whisk eggs with parmesan and pepper.",
                "Toss hot pasta with guanciale, then off heat with the egg mixture.",
               ],
               thumbnailColorHex: "#E8C79A"),
        Recipe(name: "Charred Broccoli", category: "Vegetarian", timeMinutes: 20, servings: 4,
               tags: ["vegan", "gluten-free"],
               ingredients: [
                Ingredient(name: "broccoli, cut into florets", quantity: "1 head"),
                Ingredient(name: "olive oil", quantity: "2 tbsp"),
                Ingredient(name: "garlic, minced", quantity: "2 cloves"),
                Ingredient(name: "lemon", quantity: "1/2"),
               ],
               steps: [
                "Toss broccoli with oil, garlic, salt and pepper.",
                "Roast at 450°F until charred at the edges, about 15 min.",
                "Finish with a squeeze of lemon.",
               ],
               thumbnailColorHex: "#7A9A6E"),
        Recipe(name: "Brown Butter Banana Bread", category: "Baking", timeMinutes: 60, servings: 8,
               tags: ["vegetarian"],
               ingredients: [
                Ingredient(name: "ripe bananas, mashed", quantity: "3"),
                Ingredient(name: "butter", quantity: "1/2 cup"),
                Ingredient(name: "sugar", quantity: "3/4 cup"),
                Ingredient(name: "egg", quantity: "1"),
                Ingredient(name: "flour", quantity: "1 1/2 cups"),
                Ingredient(name: "baking soda", quantity: "1 tsp"),
               ],
               steps: [
                "Brown the butter in a saucepan until nutty, then cool slightly.",
                "Whisk browned butter, sugar, egg and mashed bananas together.",
                "Fold in flour and baking soda until just combined.",
                "Bake at 350°F for about 50 minutes.",
               ],
               thumbnailColorHex: "#B98A5A"),
        Recipe(name: "Thai Green Curry", category: "Dinner", timeMinutes: 35, servings: 4,
               tags: ["gluten-free", "dairy-free"],
               ingredients: [
                Ingredient(name: "green curry paste", quantity: "3 tbsp"),
                Ingredient(name: "coconut milk", quantity: "1 can"),
                Ingredient(name: "chicken thigh, sliced", quantity: "1 lb"),
                Ingredient(name: "bell pepper, sliced", quantity: "1"),
                Ingredient(name: "fish sauce", quantity: "1 tbsp"),
                Ingredient(name: "basil leaves", quantity: "handful"),
               ],
               steps: [
                "Fry the curry paste in a splash of coconut milk until fragrant.",
                "Add chicken and cook until no longer pink.",
                "Pour in remaining coconut milk and simmer with the peppers.",
                "Season with fish sauce and finish with basil.",
               ],
               thumbnailColorHex: "#5F8A4E"),
        Recipe(name: "Sourdough Pancakes", category: "Baking", timeMinutes: 30, servings: 4,
               tags: ["vegetarian"],
               ingredients: [
                Ingredient(name: "sourdough discard", quantity: "1 cup"),
                Ingredient(name: "flour", quantity: "1/2 cup"),
                Ingredient(name: "milk", quantity: "1/2 cup"),
                Ingredient(name: "egg", quantity: "1"),
                Ingredient(name: "sugar", quantity: "1 tbsp"),
                Ingredient(name: "baking soda", quantity: "1/2 tsp"),
               ],
               steps: [
                "Whisk sourdough discard, flour, milk, egg and sugar into a batter.",
                "Stir in baking soda just before cooking.",
                "Cook on a hot griddle until bubbly, then flip.",
               ],
               thumbnailColorHex: "#D9B98A"),
    ]
}

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgbValue & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
