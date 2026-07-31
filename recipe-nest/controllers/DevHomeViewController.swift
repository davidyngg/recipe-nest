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

        // Stack the button above the result label, centred on screen.
        let stack = UIStackView(arrangedSubviews: [openButton, resultLabel])
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
        // through this callback. For now we just display what we received.
        createVC.onSave = { [weak self] draft in
            self?.resultLabel.text = """
            Saved: \(draft.name)
            \(draft.ingredients.count) ingredients · \(draft.steps.count) steps
            """
        }

        // The Create screen uses a nav bar (Cancel / Save), so present it inside
        // a navigation controller. A page sheet is the modern modal style.
        let nav = UINavigationController(rootViewController: createVC)
        present(nav, animated: true)
    }
}
