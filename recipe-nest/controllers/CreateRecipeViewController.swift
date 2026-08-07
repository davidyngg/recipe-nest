//
//  CreateRecipeViewController.swift
//  recipe-nest
//
//  Created by Mayowa Ayileka on 7/25/26.
//

import UIKit
import PhotosUI

// A lightweight draft used only by the Create flow. When the shared
// Recipe model is ready, map this into it inside `onSave`.
struct DraftRecipe {
    var name: String
    var time: String
    var serves: String
    var ingredients: [String]
    var steps: [String]
    var image: UIImage?
}

class CreateRecipeViewController: UIViewController {

    // Called with the finished draft when the user taps Save.
    var onSave: ((DraftRecipe) -> Void)?

    // When set, the form is prefilled for editing instead of starting blank.
    private let draftToEdit: DraftRecipe?

    init(draftToEdit: DraftRecipe? = nil) {
        self.draftToEdit = draftToEdit
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Fields we read back on save.
    private let nameField = CreateRecipeViewController.makeTextField(placeholder: "e.g. Miso Butter Salmon")
    private let timeField = CreateRecipeViewController.makeTextField(placeholder: "45 min")
    private let servesField = CreateRecipeViewController.makeTextField(placeholder: "4")

    // Time is chosen with an hours/minutes scroll wheel instead of typed.
    private let timePicker = UIDatePicker()

    private let ingredientsStack = UIStackView()
    private let stepsStack = UIStackView()

    // The chosen thumbnail, shown inside the photo tile.
    private let photoImageView = UIImageView()
    private var selectedImage: UIImage?

    // The "Add photo" prompt inside the tile, hidden once a photo is picked.
    private let photoPrompt = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save, target: self, action: #selector(saveTapped))

        buildLayout()
        configureTimeInput()

        if let draft = draftToEdit {
            // Editing an existing recipe: prefill everything from the draft.
            title = "Edit Recipe"
            nameField.text = draft.name
            timeField.text = draft.time
            servesField.text = draft.serves
            draft.ingredients.forEach { addIngredientRow(text: $0) }
            draft.steps.forEach { addStepRow(text: $0) }
            if let image = draft.image { setImage(image) }
        } else {
            title = "New Recipe"
            // Start with two empty ingredient rows and one step, like the mockup.
            addIngredientRow()
            addIngredientRow()
            addStepRow()
        }

        // Dismiss the keyboard when tapping empty space.
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Layout

    private func buildLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 16
        content.isLayoutMarginsRelativeArrangement = true
        content.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 32, right: 20)
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        content.addArrangedSubview(makePhotoTile())

        content.addArrangedSubview(makeFieldLabel("Recipe name"))
        content.addArrangedSubview(nameField)

        // Time and Serves sit side by side.
        content.addArrangedSubview(makeTimeServesRow())

        content.addArrangedSubview(makeSectionLabel("Ingredients"))
        ingredientsStack.axis = .vertical
        ingredientsStack.spacing = 8
        content.addArrangedSubview(ingredientsStack)
        content.addArrangedSubview(makeAddButton(title: "Add ingredient", action: #selector(addIngredientTapped)))

        content.addArrangedSubview(makeSectionLabel("Steps"))
        stepsStack.axis = .vertical
        stepsStack.spacing = 8
        content.addArrangedSubview(stepsStack)
        content.addArrangedSubview(makeAddButton(title: "Add step", action: #selector(addStepTapped)))

        content.setCustomSpacing(24, after: stepsStack)
        content.addArrangedSubview(makeSaveButton())
    }

    // MARK: - Photo tile

    private func makePhotoTile() -> UIView {
        let tile = UIControl()
        tile.backgroundColor = .secondarySystemBackground
        tile.layer.cornerRadius = 12
        tile.clipsToBounds = true
        tile.addTarget(self, action: #selector(photoTileTapped), for: .touchUpInside)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.heightAnchor.constraint(equalToConstant: 160).isActive = true

        // Filled once a photo is picked; sits behind the prompt.
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.isHidden = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(photoImageView)

        let plus = UIImageView(image: UIImage(systemName: "plus"))
        plus.tintColor = .secondaryLabel
        plus.contentMode = .scaleAspectFit

        let title = UILabel()
        title.text = "Add photo"
        title.font = .systemFont(ofSize: 17, weight: .semibold)
        title.textColor = .label

        let subtitle = UILabel()
        subtitle.text = "or take one with the camera"
        subtitle.font = .systemFont(ofSize: 14)
        subtitle.textColor = .secondaryLabel

        photoPrompt.addArrangedSubview(plus)
        photoPrompt.addArrangedSubview(title)
        photoPrompt.addArrangedSubview(subtitle)
        photoPrompt.axis = .vertical
        photoPrompt.alignment = .center
        photoPrompt.spacing = 4
        // The prompt is decorative; let taps pass straight through to the tile.
        photoPrompt.isUserInteractionEnabled = false
        photoPrompt.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(photoPrompt)

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: tile.topAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: tile.bottomAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: tile.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: tile.trailingAnchor),

            photoPrompt.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            photoPrompt.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            plus.heightAnchor.constraint(equalToConstant: 28),
        ])
        return tile
    }

    // MARK: - Time / Serves

    private func makeTimeServesRow() -> UIView {
        let time = UIStackView(arrangedSubviews: [makeFieldLabel("Time"), timeField])
        time.axis = .vertical
        time.spacing = 6

        let serves = UIStackView(arrangedSubviews: [makeFieldLabel("Serves"), servesField])
        serves.axis = .vertical
        serves.spacing = 6
        servesField.keyboardType = .numberPad

        let row = UIStackView(arrangedSubviews: [time, serves])
        row.axis = .horizontal
        row.spacing = 16
        row.distribution = .fillEqually
        return row
    }

    // Swaps the Time field's keyboard for an hours/minutes countdown wheel.
    // Tapping the field slides the wheel up; a Done button dismisses it.
    private func configureTimeInput() {
        timePicker.datePickerMode = .countDownTimer   // shows "hours" + "min" wheels
        timePicker.minuteInterval = 5                 // 5-min steps suit cooking times
        timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)

        // Use the wheel as the field's input view instead of the keyboard.
        timeField.inputView = timePicker
        timeField.tintColor = .clear                  // hide the text caret; it's not typeable

        // A small toolbar above the wheel with a Done button.
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissTimePicker)),
        ]
        timeField.inputAccessoryView = toolbar
    }

    // Called each time the wheel moves; formats the duration into the field.
    @objc private func timeChanged() {
        timeField.text = CreateRecipeViewController.formatDuration(timePicker.countDownDuration)
    }

    @objc private func dismissTimePicker() {
        view.endEditing(true)
    }

    // Turns a duration in seconds into a short label, e.g. "1 hr 30 min".
    private static func formatDuration(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 && minutes > 0 { return "\(hours) hr \(minutes) min" }
        if hours > 0 { return "\(hours) hr" }
        return "\(minutes) min"
    }

    // MARK: - Ingredient / step rows

    @objc private func addIngredientTapped() { addIngredientRow() }
    @objc private func addStepTapped() { addStepRow() }

    private func addIngredientRow(text: String? = nil) {
        let field = CreateRecipeViewController.makeTextField(placeholder: "Add an ingredient…")
        field.text = text

        let handle = UIImageView(image: UIImage(systemName: "line.3.horizontal"))
        handle.tintColor = .tertiaryLabel
        handle.contentMode = .center
        handle.widthAnchor.constraint(equalToConstant: 24).isActive = true

        let remove = UIButton(type: .system)
        remove.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        remove.tintColor = .systemRed
        remove.widthAnchor.constraint(equalToConstant: 28).isActive = true

        let row = UIStackView(arrangedSubviews: [handle, field, remove])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        remove.addAction(UIAction { [weak self] _ in
            self?.ingredientsStack.removeArrangedSubview(row)
            row.removeFromSuperview()
        }, for: .touchUpInside)

        ingredientsStack.addArrangedSubview(row)
    }

    private func addStepRow(text: String? = nil) {
        let index = stepsStack.arrangedSubviews.count + 1

        let number = UILabel()
        number.text = "\(index)"
        number.font = .systemFont(ofSize: 15, weight: .bold)
        number.textColor = .white
        number.textAlignment = .center
        number.backgroundColor = .systemBlue
        number.layer.cornerRadius = 13
        number.clipsToBounds = true
        number.translatesAutoresizingMaskIntoConstraints = false
        number.widthAnchor.constraint(equalToConstant: 26).isActive = true
        number.heightAnchor.constraint(equalToConstant: 26).isActive = true

        let field = CreateRecipeViewController.makeTextField(
            placeholder: index == 1 ? "Step 1 — what do we do first?" : "Step \(index)")
        field.text = text

        let row = UIStackView(arrangedSubviews: [number, field])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        stepsStack.addArrangedSubview(row)
    }

    // MARK: - Actions

    @objc private func photoTileTapped() {
        let sheet = UIAlertController(title: "Recipe photo", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        })
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentCamera()
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // iPad needs an anchor for the popover.
        sheet.popoverPresentationController?.sourceView = view
        present(sheet, animated: true)
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    private func setImage(_ image: UIImage) {
        selectedImage = image
        photoImageView.image = image
        photoImageView.isHidden = false
        photoPrompt.isHidden = true
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty else {
            let alert = UIAlertController(title: "Name required",
                                          message: "Give your recipe a name before saving.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let draft = DraftRecipe(
            name: name,
            time: timeField.text ?? "",
            serves: servesField.text ?? "",
            ingredients: collectValues(from: ingredientsStack),
            steps: collectValues(from: stepsStack),
            image: selectedImage)

        onSave?(draft)
        dismiss(animated: true)
    }

    // Pulls the non-empty text from every UITextField inside a stack's rows.
    private func collectValues(from stack: UIStackView) -> [String] {
        stack.arrangedSubviews
            .compactMap { $0 as? UIStackView }
            .flatMap { $0.arrangedSubviews }
            .compactMap { ($0 as? UITextField)?.text }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    // MARK: - Reusable builders

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }

    private func makeFieldLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private func makeAddButton(title: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 6
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading
        button.tintColor = .systemBlue
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeSaveButton() -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = "Save recipe"
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }

    private static func makeTextField(placeholder: String) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.font = .systemFont(ofSize: 17)
        field.borderStyle = .roundedRect
        field.backgroundColor = .secondarySystemBackground
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return field
    }
}

// MARK: - Photo picker delegates

extension CreateRecipeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async { self?.setImage(image) }
        }
    }
}

extension CreateRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                              didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            setImage(image)
        }
    }
}
