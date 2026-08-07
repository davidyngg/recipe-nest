//
//  RecipeCardCell.swift
//
//
//  Created by Noah Sellers on 7/31/26.
//

import UIKit

protocol RecipeCardCellDelegate: AnyObject {
    func recipeCardCellDidSwipeToDelete(_ cell: RecipeCardCell)
}

class RecipeCardCell: UICollectionViewCell {

    weak var delegate: RecipeCardCellDelegate?

    private let thumbnailView = UIView()
    private let thumbnailImageView = UIImageView()
    private let timeBadge = UILabel()
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
    }

    private func setUpViews() {
        thumbnailView.layer.cornerRadius = 14
        thumbnailView.clipsToBounds = true
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false

        timeBadge.font = .systemFont(ofSize: 12, weight: .semibold)
        timeBadge.textColor = .white
        timeBadge.textAlignment = .center
        timeBadge.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        timeBadge.layer.cornerRadius = 8
        timeBadge.clipsToBounds = true
        timeBadge.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        thumbnailView.addSubview(thumbnailImageView)
        thumbnailView.addSubview(timeBadge)
        contentView.addSubview(thumbnailView)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            thumbnailView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailView.heightAnchor.constraint(equalTo: thumbnailView.widthAnchor, multiplier: 0.85),

            thumbnailImageView.topAnchor.constraint(equalTo: thumbnailView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: thumbnailView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: thumbnailView.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: thumbnailView.bottomAnchor),

            timeBadge.leadingAnchor.constraint(equalTo: thumbnailView.leadingAnchor, constant: 8),
            timeBadge.bottomAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: -8),
            timeBadge.heightAnchor.constraint(equalToConstant: 20),
            timeBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),

            nameLabel.topAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
        ])

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeGesture.direction = .left
        contentView.addGestureRecognizer(swipeGesture)
    }

    func configure(with recipe: Recipe) {
        // The thumbnail color shows through when the recipe has no photo.
        thumbnailView.backgroundColor = recipe.thumbnailColor
        thumbnailImageView.image = recipe.image
        timeBadge.text = "  \(recipe.timeLabel)  "
        nameLabel.text = recipe.name
    }

    @objc private func handleSwipeLeft() {
        delegate?.recipeCardCellDidSwipeToDelete(self)
    }
}
