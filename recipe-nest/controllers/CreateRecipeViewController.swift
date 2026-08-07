//
//  CreateRecipeViewController.swift
//
//
//  Created by Noah Sellers on 7/31/26.
//
//  Placeholder for the Create Recipe view (photo, name, time, servings,
//  ingredients, steps) — Mayowa's view per the design doc.

import UIKit

class CreateRecipeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Recipe"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))

        let label = UILabel()
        label.text = "Create Recipe — coming soon"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        dismiss(animated: true)
    }
}
