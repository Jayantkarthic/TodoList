//
//  TaskDetailHeaderView.swift
//  TodoList
//
//  Created by Jayant Karthic on 20/07/24.
//


import UIKit

protocol TaskDetailHeaderViewDelegate: AnyObject {
    func didTapAddAttachment()
    func textViewDidChangeHeight(_ cell: TaskDetailHeaderView)
}

class TaskDetailHeaderView: UITableViewCell {
    weak var delegate: TaskDetailHeaderViewDelegate?
    
    let titleTextField = UITextField()
    let descriptionTextView = UITextView()
    let prioritySegmentedControl = UISegmentedControl(items: ["High", "Medium", "Low"])
    let dueDatePicker = UIDatePicker()
    let attachmentButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(prioritySegmentedControl)
        contentView.addSubview(dueDatePicker)
        contentView.addSubview(attachmentButton)

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
            dueDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        attachmentButton.setTitle("Add Attachment", for: .normal)
        attachmentButton.backgroundColor = .gray
        attachmentButton.setTitleColor(.white, for: .normal)
        attachmentButton.layer.cornerRadius = 5
        attachmentButton.addTarget(self, action: #selector(addAttachmentTapped), for: .touchUpInside)
        attachmentButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            attachmentButton.topAnchor.constraint(equalTo: dueDatePicker.bottomAnchor, constant: 20),
            attachmentButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            attachmentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            attachmentButton.heightAnchor.constraint(equalToConstant: 44),
            attachmentButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
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

    @objc private func addAttachmentTapped() {
        delegate?.didTapAddAttachment()
    }
    
    func configure(withTitle title: String?, description: String?, priorityIndex: Int?, dueDate: Date?) {
        titleTextField.text = title
        descriptionTextView.text = description
        prioritySegmentedControl.selectedSegmentIndex = priorityIndex ?? 1
        dueDatePicker.date = dueDate ?? Date()
    }
}

// MARK: - UITextViewDelegate
extension TaskDetailHeaderView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
          delegate?.textViewDidChangeHeight(self)
      }
      
}
