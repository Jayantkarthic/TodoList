//
//  TaskDetailViewController.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//




import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import PhotosUI

protocol TaskDetailViewControllerDelegate: AnyObject {
    func didSaveTask()
}

class TaskDetailViewController: UIViewController, UINavigationControllerDelegate {
    weak var delegate: TaskDetailViewControllerDelegate?
    var task: ToDoTask?
    var viewModel: AllTasksViewModel?
    
    private let tableView = UITableView()
    private var attachmentURLs: [URL] = []
    private var documentInteractionController: UIDocumentInteractionController?
    
    // Properties to store input values
    private var titleText: String?
    private var descriptionText: String?
    private var selectedPriorityIndex: Int?
    private var dueDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureView()
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = task == nil ? "Add Task" : "Edit Task"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskDetailHeaderView.self, forCellReuseIdentifier: "TaskDetailHeaderView")
        tableView.register(AttachmentTableViewCell.self, forCellReuseIdentifier: "AttachmentTableViewCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTask))
        navigationItem.rightBarButtonItem = saveButton

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func configureView() {
        if let task = task {
            titleText = task.title
            descriptionText = task.taskDescription
            selectedPriorityIndex = ["High", "Medium", "Low"].firstIndex(of: task.priority ?? "Medium")
            dueDate = task.dueDate
            if let attachmentPaths = task.attachmentURL?.components(separatedBy: ",") {
                attachmentURLs = attachmentPaths.compactMap({ URL(string: $0) })
            }
        }
        tableView.reloadData()
    }

    @objc private func saveTask() {
        guard let headerView = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TaskDetailHeaderView,
              let title = headerView.titleTextField.text, !title.isEmpty else {
            showAlert(message: "Task name is required.")
            return
        }

        titleText = title
        descriptionText = headerView.descriptionTextView.text
        selectedPriorityIndex = headerView.prioritySegmentedControl.selectedSegmentIndex
        dueDate = headerView.dueDatePicker.date

        let description = headerView.descriptionTextView.text
        let priority = ["High", "Medium", "Low"][headerView.prioritySegmentedControl.selectedSegmentIndex]
        let dueDate = headerView.dueDatePicker.date

        let attachmentPaths = attachmentURLs.map { $0.absoluteString }.joined(separator: ",")

        if let task = task {
            viewModel?.updateTask(task, title: title, description: description, attachmentURL: URL(string: attachmentPaths), priority: priority, dueDate: dueDate)
        } else {
            viewModel?.addTask(title: title, description: description, attachmentURL: URL(string: attachmentPaths), priority: priority, dueDate: dueDate)
        }

        delegate?.didSaveTask()
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func presentImagePicker() {
        saveCurrentInputValues()
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // 0 means no limit
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    private func presentCamera() {
        saveCurrentInputValues()
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
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
        saveCurrentInputValues()
        let documentPicker = UIDocumentPickerViewController(documentTypes: [UTType.pdf.identifier], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
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

    private func saveCurrentInputValues() {
        guard let headerView = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TaskDetailHeaderView else { return }
        titleText = headerView.titleTextField.text
        descriptionText = headerView.descriptionTextView.text
        selectedPriorityIndex = headerView.prioritySegmentedControl.selectedSegmentIndex
        dueDate = headerView.dueDatePicker.date
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TaskDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskDetailHeaderView", for: indexPath) as! TaskDetailHeaderView
            cell.delegate = self
            cell.configure(withTitle: titleText, description: descriptionText, priorityIndex: selectedPriorityIndex, dueDate: dueDate)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentTableViewCell", for: indexPath) as! AttachmentTableViewCell
            cell.configure(with: attachmentURLs)
            cell.delegate = self
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension TaskDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                guard let self = self else { return }
                if let image = object as? UIImage {
                    if let imageData = image.jpegData(compressionQuality: 0.8),
                       let imageURL = self.saveImageToDocuments(imageData) {
                        DispatchQueue.main.async {
                            self.attachmentURLs.append(imageURL)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension TaskDetailViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        attachmentURLs.append(contentsOf: urls)
        tableView.reloadData()
    }
}

extension TaskDetailViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            if let imageData = pickedImage.jpegData(compressionQuality: 0.8),
               let imageURL = saveImageToDocuments(imageData) {
                attachmentURLs.append(imageURL)
                tableView.reloadData()
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIDocumentInteractionControllerDelegate
extension TaskDetailViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

// MARK: - AttachmentTableViewCellDelegate
extension TaskDetailViewController: AttachmentTableViewCellDelegate {
    func didSelectAttachment(_ url: URL) {
        documentInteractionController = UIDocumentInteractionController(url: url)
        documentInteractionController?.delegate = self
        documentInteractionController?.presentPreview(animated: true)
    }

    func deleteAttachment(at index: Int) {
        saveCurrentInputValues()
        attachmentURLs.remove(at: index)
        tableView.reloadData()
    }
}

// MARK: - TaskDetailHeaderViewDelegate
extension TaskDetailViewController: TaskDetailHeaderViewDelegate {
    func textViewDidChangeHeight(_ cell: TaskDetailHeaderView) {
        tableView.beginUpdates()
                tableView.endUpdates()
    }
    
    func didTapAddAttachment() {
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
}
