//
//  DevHomeViewController.swift
//  recipe-nest
//
//  TEMPORARY scaffolding so the Create Recipe flow can be run and tested in
//  isolation before the app is wired together. Safe to delete once Sahar hooks
//  the real navigation up — it touches nothing the rest of the team owns.
//

import UIKit

class DevHomeViewController: UIViewController {

    // Shows the result of the most recent save so we can see the round-trip work.
    private let resultLabel = UILabel()

    // Shown once a recipe is saved and opens it in the recipe detail view.
    private let viewRecipeButton = UIButton(configuration: .filled())
    private var savedDraft: DraftRecipe?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Dev Home"

        // A button that opens the Create Recipe screen.
        var config = UIButton.Configuration.filled()
        config.title = "Create Recipe"
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium
        let openButton = UIButton(configuration: config)
        openButton.addTarget(self, action: #selector(openCreateRecipe), for: .touchUpInside)

        resultLabel.text = "No recipe saved yet."
        resultLabel.textColor = .secondaryLabel
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center

        // Hidden until the first recipe is saved.
        viewRecipeButton.configuration?.title = "View Recipe"
        viewRecipeButton.configuration?.baseBackgroundColor = .systemBlue
        viewRecipeButton.configuration?.cornerStyle = .medium
        viewRecipeButton.isHidden = true
        viewRecipeButton.addTarget(self, action: #selector(viewRecipeTapped), for: .touchUpInside)

        // Stack the button above the result label.
        let stack = UIStackView(arrangedSubviews: [openButton, resultLabel, viewRecipeButton])
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
        ])
    }

    @objc private func openCreateRecipe() {
        let createVC = CreateRecipeViewController()

        // When the user taps Save, CreateRecipeViewController hands us the draft
        // through this callback. Keep it and offer a button to view it.
        createVC.onSave = { [weak self] draft in
            self?.savedDraft = draft
            self?.resultLabel.isHidden = true
            self?.viewRecipeButton.isHidden = false
        }

        // The Create screen uses a nav bar (Cancel / Save), so present it inside
        // a navigation controller. A page sheet is the modern modal style.
        let nav = UINavigationController(rootViewController: createVC)
        present(nav, animated: true)
    }

    @objc private func viewRecipeTapped() {
        guard let draft = savedDraft else { return }

        // The detail view is the root of RecipeDetail.storyboard's navigation
        // controller; instantiate it and hand over the saved draft.
        let storyboard = UIStoryboard(name: "RecipeDetail", bundle: nil)
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let detailViewController = nav.topViewController as! RecipeDetailViewController
        detailViewController.draft = draft

        // Presented modally, so give it a way to close.
        detailViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { _ in nav.dismiss(animated: true) })

        present(nav, animated: true)
    }
    
    
}
