//
//  AddEditTimerViewController.swift
//
//
//  Created by Noah Sellers on 7/31/26.
//

import UIKit

class AddEditTimerViewController: UIViewController {

    private let existingTimer: RecipeTimer?
    private let store = TimerStore.shared

    var onSave: (() -> Void)?

    private let labelField = UITextField()
    private let durationPicker = UIDatePicker()

    init(timer: RecipeTimer?) {
        self.existingTimer = timer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = existingTimer == nil ? "New Timer" : "Edit Timer"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))

        labelField.placeholder = "Timer name (e.g. Pasta)"
        labelField.borderStyle = .roundedRect
        labelField.text = existingTimer?.label
        labelField.translatesAutoresizingMaskIntoConstraints = false

        durationPicker.datePickerMode = .countDownTimer
        durationPicker.countDownDuration = existingTimer?.duration ?? 300
        durationPicker.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [labelField, durationPicker])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    @objc private func saveTapped() {
        let name = labelField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let duration = durationPicker.countDownDuration
        guard !name.isEmpty, duration > 0 else { return }

        if var timer = existingTimer {
            timer.label = name
            timer.duration = duration
            timer.reset()
            store.update(timer)
        } else {
            let timer = RecipeTimer(label: name, duration: duration, endDate: nil, remaining: duration)
            store.add(timer)
        }

        onSave?()
        navigationController?.popViewController(animated: true)
    }
}
