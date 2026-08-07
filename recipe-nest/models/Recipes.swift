//
//  Recipes.swift
//
//
//  Created by David Yang on 7/23/26.
//

import CoreData
import UIKit

// Recipe, Ingredient and Tag are CoreData entities defined in
// Model.xcdatamodeld; Xcode generates their classes at build time.

final class RecipeStore {
    static let shared = RecipeStore()

    private(set) var recipes: [Recipe] = []

    // Recipes are created and mutated in this context, then persisted via save().
    var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    private init() {
        seedSampleRecipesIfNeeded()
        refresh()
    }

    private func refresh() {
        let request = Recipe.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true,
                                                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        recipes = (try? context.fetch(request)) ?? []
    }

    // Persists any uncommitted changes and refreshes the cache.
    func save() {
        PersistenceController.shared.save()
        refresh()
    }

    // CoreData objects are mutated in place, so adding or updating just saves.
    func add(_ recipe: Recipe) { save() }
    func update(_ recipe: Recipe) { save() }

    func delete(_ recipe: Recipe) {
        context.delete(recipe)
        save()
    }

    // MARK: - Sample data

    // Inserts the sample recipes on first launch only.
    private func seedSampleRecipesIfNeeded() {
        let seededKey = "didSeedSampleRecipes"
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }

        // Reuses one Tag object per tag text across all samples.
        var tagsByText: [String: Tag] = [:]
        func tag(_ text: String) -> Tag {
            if let existing = tagsByText[text] { return existing }
            let tag = Tag(context: context)
            tag.text = text
            tagsByText[text] = tag
            return tag
        }

        func recipe(_ name: String, category: String, timeMinutes: Int16, servings: Int16,
                    tags: [Tag], ingredients: [String], steps: [String], colorHex: String) {
            let recipe = Recipe(context: context)
            recipe.id = UUID()
            recipe.name = name
            recipe.category = category
            recipe.timeMinutes = timeMinutes
            recipe.servings = servings
            tags.forEach(recipe.addToTags)
            ingredients.forEach { text in
                let ingredient = Ingredient(context: context)
                ingredient.name = text
                recipe.addToIngredients(ingredient)
            }
            recipe.steps = steps
            recipe.thumbnailColorHex = colorHex
        }

        recipe("Miso Butter Salmon", category: "Dinner", timeMinutes: 45, servings: 4,
               tags: [tag("pescatarian"), tag("gluten-free")],
               ingredients: [
                "2 salmon fillets",
                "2 tbsp white miso",
                "3 tbsp butter, softened",
                "1 tbsp soy sauce",
                "2 scallions, sliced",
                "steamed rice, to serve",
               ],
               steps: [
                "Pat the salmon dry and season lightly with salt.",
                "Whisk the miso, soft butter and soy into a smooth paste.",
                "Sear salmon skin-side down 4 min, flip, then spoon over the miso butter.",
                "Rest 2 min, scatter scallions and serve over rice.",
               ],
               colorHex: "#D98255")
        recipe("Weeknight Carbonara", category: "Quick", timeMinutes: 25, servings: 2,
               tags: [tag("vegetarian-friendly")],
               ingredients: [
                "200g spaghetti",
                "2 eggs",
                "50g parmesan, grated",
                "100g guanciale, diced",
                "black pepper, to taste",
               ],
               steps: [
                "Boil the spaghetti in salted water until al dente.",
                "Render the guanciale in a cold pan until crisp.",
                "Whisk eggs with parmesan and pepper.",
                "Toss hot pasta with guanciale, then off heat with the egg mixture.",
               ],
               colorHex: "#E8C79A")
        recipe("Charred Broccoli", category: "Vegetarian", timeMinutes: 20, servings: 4,
               tags: [tag("vegan"), tag("gluten-free")],
               ingredients: [
                "1 head broccoli, cut into florets",
                "2 tbsp olive oil",
                "2 cloves garlic, minced",
                "1/2 lemon",
               ],
               steps: [
                "Toss broccoli with oil, garlic, salt and pepper.",
                "Roast at 450°F until charred at the edges, about 15 min.",
                "Finish with a squeeze of lemon.",
               ],
               colorHex: "#7A9A6E")
        recipe("Brown Butter Banana Bread", category: "Baking", timeMinutes: 60, servings: 8,
               tags: [tag("vegetarian")],
               ingredients: [
                "3 ripe bananas, mashed",
                "1/2 cup butter",
                "3/4 cup sugar",
                "1 egg",
                "1 1/2 cups flour",
                "1 tsp baking soda",
               ],
               steps: [
                "Brown the butter in a saucepan until nutty, then cool slightly.",
                "Whisk browned butter, sugar, egg and mashed bananas together.",
                "Fold in flour and baking soda until just combined.",
                "Bake at 350°F for about 50 minutes.",
               ],
               colorHex: "#B98A5A")
        recipe("Thai Green Curry", category: "Dinner", timeMinutes: 35, servings: 4,
               tags: [tag("gluten-free"), tag("dairy-free")],
               ingredients: [
                "3 tbsp green curry paste",
                "1 can coconut milk",
                "1 lb chicken thigh, sliced",
                "1 bell pepper, sliced",
                "1 tbsp fish sauce",
                "handful basil leaves",
               ],
               steps: [
                "Fry the curry paste in a splash of coconut milk until fragrant.",
                "Add chicken and cook until no longer pink.",
                "Pour in remaining coconut milk and simmer with the peppers.",
                "Season with fish sauce and finish with basil.",
               ],
               colorHex: "#5F8A4E")
        recipe("Sourdough Pancakes", category: "Baking", timeMinutes: 30, servings: 4,
               tags: [tag("vegetarian")],
               ingredients: [
                "1 cup sourdough discard",
                "1/2 cup flour",
                "1/2 cup milk",
                "1 egg",
                "1 tbsp sugar",
                "1/2 tsp baking soda",
               ],
               steps: [
                "Whisk sourdough discard, flour, milk, egg and sugar into a batter.",
                "Stir in baking soda just before cooking.",
                "Cook on a hot griddle until bubbly, then flip.",
               ],
               colorHex: "#D9B98A")

        UserDefaults.standard.set(true, forKey: seededKey)
        PersistenceController.shared.save()
    }
}

// MARK: - View-facing helpers (kept from the old struct)

extension Recipe {
    var timeLabel: String {
        timeMinutes >= 60 && timeMinutes % 60 == 0 ? "\(timeMinutes / 60) hr" : "\(timeMinutes) min"
    }

    var thumbnailColor: UIColor {
        guard let thumbnailColorHex else { return .systemGray5 }
        return UIColor(hex: thumbnailColorHex)
    }

    var stepList: [String] {
        steps ?? []
    }

    // Decodes the stored JPEG data for display.
    var image: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }

    // Ingredients and tags come back from CoreData unordered; sort for display.
    var sortedIngredients: [Ingredient] {
        (ingredients?.allObjects as? [Ingredient])?.sorted { ($0.name ?? "") < ($1.name ?? "") } ?? []
    }

    var sortedTagTexts: [String] {
        (tags?.allObjects as? [Tag])?.compactMap(\.text).sorted() ?? []
    }
}

// MARK: - Create/edit form (DraftRecipe) mapping

extension Recipe {
    // Applies edits from the recipe form. Category, tags and thumbnail color
    // aren't editable there, so they're left untouched.
    func apply(_ draft: DraftRecipe) {
        guard let context = managedObjectContext else { return }

        name = draft.name

        let minutes = Recipe.minutes(from: draft.time)
        if minutes > 0 { timeMinutes = minutes }

        if let serves = Int16(draft.serves), serves > 0 { servings = serves }

        // Replace the ingredients wholesale. They're owned by the recipe, so
        // they must be deleted from the context, not just unlinked.
        sortedIngredients.forEach { context.delete($0) }
        draft.ingredients.forEach { text in
            let ingredient = Ingredient(context: context)
            ingredient.name = text
            addToIngredients(ingredient)
        }

        steps = draft.steps

        // The edit form is prefilled with the existing image, so this also
        // preserves it when the user didn't pick a new one.
        imageData = draft.image?.jpegData(compressionQuality: 0.8)
    }

    // Parses the form's time formats: "1 hr 30 min", "1 hr", "45 min".
    static func minutes(from timeString: String) -> Int16 {
        let tokens = timeString.split(separator: " ")
        var total: Int16 = 0
        var index = 0
        while index + 1 < tokens.count, let value = Int16(tokens[index]) {
            total += tokens[index + 1].hasPrefix("hr") ? value * 60 : value
            index += 2
        }
        return total
    }

    // Formats minutes the way the form's time picker does, e.g. "1 hr 30 min".
    static func timeString(from minutes: Int16) -> String {
        let hours = minutes / 60
        let remainder = minutes % 60
        if hours > 0 && remainder > 0 { return "\(hours) hr \(remainder) min" }
        if hours > 0 { return "\(hours) hr" }
        return "\(remainder) min"
    }
}

extension DraftRecipe {
    // Builds a form draft from an existing recipe, for editing.
    init(recipe: Recipe) {
        name = recipe.name ?? ""
        time = Recipe.timeString(from: recipe.timeMinutes)
        serves = recipe.servings > 0 ? "\(recipe.servings)" : ""
        ingredients = recipe.sortedIngredients.compactMap(\.name)
        steps = recipe.stepList
        image = recipe.image
    }
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
