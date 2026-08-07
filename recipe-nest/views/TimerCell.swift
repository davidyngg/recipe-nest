//
//  TimerCell.swift
//
//
//  Created by Noah Sellers on 7/31/26.
//

import UIKit

protocol TimerCellDelegate: AnyObject {
    func timerCellDidToggle(_ cell: TimerCell)
    func timerCellDidReset(_ cell: TimerCell)
}

class TimerCell: UITableViewCell {

    weak var delegate: TimerCellDelegate?

    private let nameLabel = UILabel()
    private let timeLabel = UILabel()
    private let toggleButton = UIButton()
    private let resetButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
    }

    private func setUpViews() {
        selectionStyle = .default

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 30, weight: .regular)

        toggleButton.tintColor = .systemBlue
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)

        let resetConfig = UIImage.SymbolConfiguration(pointSize: 22)
        resetButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle", withConfiguration: resetConfig), for: .normal)
        resetButton.tintColor = .systemGray
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, timeLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView(arrangedSubviews: [resetButton, toggleButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(textStack)
        contentView.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            buttonStack.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: 12),

            toggleButton.widthAnchor.constraint(equalToConstant: 44),
            toggleButton.heightAnchor.constraint(equalToConstant: 44),
            resetButton.widthAnchor.constraint(equalToConstant: 44),
            resetButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    func configure(with timer: RecipeTimer) {
        nameLabel.text = timer.label
        updateTimeLabel(remaining: timer.displayRemaining)

        let symbolName = timer.isRunning ? "pause.fill" : "play.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 22)
        toggleButton.setImage(UIImage(systemName: symbolName, withConfiguration: config), for: .normal)
    }

    func updateTimeLabel(remaining: TimeInterval) {
        timeLabel.text = remaining.timerDisplay
    }

    @objc private func toggleTapped() {
        delegate?.timerCellDidToggle(self)
    }

    @objc private func resetTapped() {
        delegate?.timerCellDidReset(self)
    }
}
