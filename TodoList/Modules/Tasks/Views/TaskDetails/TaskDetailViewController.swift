//
//  TaskDetailViewController.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

protocol TaskDetailViewControllerDelegate: AnyObject {
    func didSaveTask()
}

class TaskDetailViewController: UIViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var delegate: TaskDetailViewControllerDelegate?

    var task: ToDoTask?
    var viewModel: AllTasksViewModel?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleTextField = UITextField()
    private let descriptionTextView = UITextView()
    private let prioritySegmentedControl = UISegmentedControl(items: ["High", "Medium", "Low"])
    private let dueDatePicker = UIDatePicker()
    private let attachmentButton = UIButton(type: .system)
    private let attachmentsCollectionView: UICollectionView
    private var attachmentURLs: [URL] = []
    private var documentInteractionController: UIDocumentInteractionController?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 130)
        attachmentsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 130)
        attachmentsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureView()
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = task == nil ? "Add Task" : "Edit Task"

        // Setup scroll view
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Add title labels and text fields
        addLabeledTextField(title: "Title:", textField: titleTextField, topAnchor: contentView.topAnchor)
        addLabeledTextView(title: "Description:", textView: descriptionTextView, topAnchor: titleTextField.bottomAnchor, constant: 20)

        let priorityLabel = UILabel()
        priorityLabel.text = "Priority:"
        priorityLabel.font = UIFont.boldSystemFont(ofSize: priorityLabel.font.pointSize)
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priorityLabel)

        prioritySegmentedControl.selectedSegmentIndex = 1
        contentView.addSubview(prioritySegmentedControl)
        prioritySegmentedControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            priorityLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            priorityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priorityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            prioritySegmentedControl.topAnchor.constraint(equalTo: priorityLabel.bottomAnchor, constant: 10),
            prioritySegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prioritySegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        let dueDateLabel = UILabel()
        dueDateLabel.text = "Due Date:"
        dueDateLabel.font = UIFont.boldSystemFont(ofSize: dueDateLabel.font.pointSize)
        dueDateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dueDateLabel)

        dueDatePicker.datePickerMode = .dateAndTime
        contentView.addSubview(dueDatePicker)
        dueDatePicker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dueDateLabel.topAnchor.constraint(equalTo: prioritySegmentedControl.bottomAnchor, constant: 20),
            dueDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            dueDatePicker.topAnchor.constraint(equalTo: dueDateLabel.bottomAnchor, constant: 10),
            dueDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
         
        ])

        attachmentButton.setTitle("Add Attachment", for: .normal)
        attachmentButton.backgroundColor = .gray
        attachmentButton.setTitleColor(.white, for: .normal)
        attachmentButton.layer.cornerRadius = 5
        attachmentButton.addTarget(self, action: #selector(addAttachment), for: .touchUpInside)
        contentView.addSubview(attachmentButton)
        attachmentButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            attachmentButton.topAnchor.constraint(equalTo: dueDatePicker.bottomAnchor, constant: 20),
            attachmentButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            attachmentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            attachmentButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        attachmentsCollectionView.delegate = self
        attachmentsCollectionView.dataSource = self
        attachmentsCollectionView.register(AttachmentCollectionViewCell.self, forCellWithReuseIdentifier: "AttachmentCell")
        contentView.addSubview(attachmentsCollectionView)
        attachmentsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            attachmentsCollectionView.topAnchor.constraint(equalTo: attachmentButton.bottomAnchor, constant: 20),
            attachmentsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            attachmentsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            attachmentsCollectionView.heightAnchor.constraint(equalToConstant: 200),
            attachmentsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTask))
        navigationItem.rightBarButtonItem = saveButton
    }

    private func addLabeledTextField(title: String, textField: UITextField, topAnchor: NSLayoutYAxisAnchor, constant: CGFloat = 20) {
        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }


    private func addLabeledTextView(title: String, textView: UITextView, topAnchor: NSLayoutYAxisAnchor, constant: CGFloat = 20) {
        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),

            textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            textView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            textView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])

        textView.delegate = self
    }
    private func configureView() {
        if let task = task {
            titleTextField.text = task.title
            descriptionTextView.text = task.taskDescription
            prioritySegmentedControl.selectedSegmentIndex = ["High", "Medium", "Low"].firstIndex(of: task.priority ?? "Medium") ?? 1
            if let dueDate = task.dueDate {
                dueDatePicker.date = dueDate
            }
            if let attachmentPaths = task.attachmentURL?.components(separatedBy: ",") {
                attachmentURLs = attachmentPaths.compactMap({ URL(string: $0) })
                attachmentsCollectionView.reloadData()
            }
        }
    }

    @objc private func saveTask() {
        guard let title = titleTextField.text, !title.isEmpty else {
            // Show an error message
            return
        }

        let description = descriptionTextView.text
        let priority = ["High", "Medium", "Low"][prioritySegmentedControl.selectedSegmentIndex]
        let dueDate = dueDatePicker.date

        let attachmentPaths = attachmentURLs.map { $0.absoluteString }.joined(separator: ",")

        if let task = task {
            viewModel?.updateTask(task, title: title, description: description, attachmentURL: URL(string: attachmentPaths), priority: priority, dueDate: dueDate)
        } else {
            viewModel?.addTask(title: title, description: description, attachmentURL: URL(string: attachmentPaths), priority: priority, dueDate: dueDate)
        }

        delegate?.didSaveTask()
        navigationController?.popViewController(animated: true)
    }

    @objc private func addAttachment() {
        let actionSheet = UIAlertController(title: "Add Attachment", message: "Choose an attachment type", preferredStyle: .actionSheet)
        
        let addImageAction = UIAlertAction(title: "Add Image", style: .default) { _ in
            self.presentImagePicker()
        }
        let addPDFAction = UIAlertAction(title: "Add PDF", style: .default) { _ in
            self.presentDocumentPicker()
        }
        let addCameraAction = UIAlertAction(title: "Use Camera", style: .default) { _ in
            self.presentCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        actionSheet.addAction(addImageAction)
        actionSheet.addAction(addPDFAction)
        actionSheet.addAction(addCameraAction)
        actionSheet.addAction(cancelAction)

        present(actionSheet, animated: true, completion: nil)
    }

    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            // Show an alert if the device doesn't have a camera
            let alert = UIAlertController(title: "Error", message: "Camera not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let cameraController = UIImagePickerController()
        cameraController.delegate = self
        cameraController.sourceType = .camera
        present(cameraController, animated: true, completion: nil)
    }

    private func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }

    // MARK: - UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        attachmentURLs.append(contentsOf: urls)
        attachmentsCollectionView.reloadData()
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            if let imageData = pickedImage.jpegData(compressionQuality: 0.8),
               let imageURL = saveImageToDocuments(imageData) {
                attachmentURLs.append(imageURL)
                attachmentsCollectionView.reloadData()
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    private func saveImageToDocuments(_ imageData: Data) -> URL? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentsURL.appendingPathComponent(fileName)
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }

    private func addDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TaskDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmentURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCell", for: indexPath) as! AttachmentCollectionViewCell
        let url = attachmentURLs[indexPath.row]
        cell.configure(with: url)
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteAttachment), for: .touchUpInside)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = attachmentURLs[indexPath.row]
        documentInteractionController = UIDocumentInteractionController(url: url)
        documentInteractionController?.delegate = self
        documentInteractionController?.presentPreview(animated: true)
    }

    @objc private func deleteAttachment(sender: UIButton) {
        let index = sender.tag
        attachmentURLs.remove(at: index)
        attachmentsCollectionView.reloadData()
    }
}

// MARK: - UIDocumentInteractionControllerDelegate
extension TaskDetailViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

// MARK: - UITextViewDelegate
extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: .greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.animate(withDuration: 0.2) {
                textView.constraints.forEach { (constraint) in
                    if constraint.firstAttribute == .height {
                        constraint.constant = newSize.height
                    }
                }
                self.view.layoutIfNeeded()
            }
        }
    }
}
