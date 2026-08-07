//
//  MyRecipesViewController.swift
//
//
//  Created by Noah Sellers on 7/31/26.
//

import UIKit

class MyRecipesViewController: UIViewController {

    private let store = RecipeStore.shared

    private var categories: [String] = []
    private var selectedCategory: String = "All"
    private var searchText: String = ""

    private var filteredRecipes: [Recipe] {
        store.recipes.filter { recipe in
            (selectedCategory == "All" || recipe.category == selectedCategory) &&
            (searchText.isEmpty || recipe.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    private let searchBar = UISearchBar()

    private let chipScrollView = UIScrollView()
    private let chipStack = UIStackView()
    private var chipButtons: [String: UIButton] = [:]

    private let addButton = UIButton(type: .system)

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecipeCardCell.self, forCellWithReuseIdentifier: "RecipeCardCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Recipes"
        view.backgroundColor = .systemBackground

        setUpSearchBar()
        setUpChips()
        setUpCollectionView()
        setUpAddButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    // MARK: - Layout

    private static func makeLayout() -> UICollectionViewLayout {
        // Two columns per row.
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.47), heightDimension: .absolute(190))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(190))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Search

    private func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search recipes"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
        ])
    }

    // MARK: - Category chips

    private func setUpChips() {
        categories = ["All"] + Array(Set(store.recipes.map(\.category))).sorted()

        chipStack.axis = .horizontal
        chipStack.spacing = 8
        chipStack.translatesAutoresizingMaskIntoConstraints = false
        chipScrollView.showsHorizontalScrollIndicator = false
        chipScrollView.translatesAutoresizingMaskIntoConstraints = false

        chipScrollView.addSubview(chipStack)
        view.addSubview(chipScrollView)

        for category in categories {
            let button = makeChipButton(title: category)
            chipButtons[category] = button
            chipStack.addArrangedSubview(button)
        }
        updateChipSelection()

        NSLayoutConstraint.activate([
            chipScrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            chipScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chipScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chipScrollView.heightAnchor.constraint(equalToConstant: 36),

            chipStack.topAnchor.constraint(equalTo: chipScrollView.topAnchor),
            chipStack.bottomAnchor.constraint(equalTo: chipScrollView.bottomAnchor),
            chipStack.leadingAnchor.constraint(equalTo: chipScrollView.leadingAnchor, constant: 16),
            chipStack.trailingAnchor.constraint(equalTo: chipScrollView.trailingAnchor, constant: -16),
            chipStack.heightAnchor.constraint(equalTo: chipScrollView.heightAnchor),
        ])
    }

    private func makeChipButton(title: String) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)

        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func chipTapped(_ sender: UIButton) {
        guard let category = sender.configuration?.title else { return }
        selectedCategory = category
        updateChipSelection()
        collectionView.reloadData()
    }

    private func updateChipSelection() {
        for (category, button) in chipButtons {
            let isSelected = category == selectedCategory
            button.backgroundColor = isSelected ? .systemBlue : .systemGray6
            button.configuration?.baseForegroundColor = isSelected ? .white : .label
        }
    }

    @objc private func addRecipeTapped() {
        let createRecipeViewController = CreateRecipeViewController()
        let navController = UINavigationController(rootViewController: createRecipeViewController)
        navController.modalPresentationStyle = .automatic
        present(navController, animated: true)
    }

    // MARK: - Collection view

    private func setUpCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: chipScrollView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Floating add button

    private func setUpAddButton() {
        addButton.backgroundColor = .systemBlue
        addButton.tintColor = .white
        addButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)), for: .normal)
        addButton.layer.cornerRadius = 28
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOpacity = 0.25
        addButton.layer.shadowRadius = 6
        addButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        addButton.addTarget(self, action: #selector(addRecipeTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension MyRecipesViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredRecipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCardCell", for: indexPath) as! RecipeCardCell
        cell.delegate = self
        cell.configure(with: filteredRecipes[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipe = filteredRecipes[indexPath.item]
        let storyboard = UIStoryboard(name: "RecipeDetail", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "RecipeDetailViewController") as? RecipeDetailViewController else { return }
        detailViewController.recipe = recipe
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - RecipeCardCellDelegate

extension MyRecipesViewController: RecipeCardCellDelegate {
    func recipeCardCellDidSwipeToDelete(_ cell: RecipeCardCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let recipe = filteredRecipes[indexPath.item]

        let alert = UIAlertController(title: "Delete \"\(recipe.name)\"?", message: "This can't be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.store.delete(recipe)
            self?.collectionView.reloadData()
        })
        present(alert, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension MyRecipesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
