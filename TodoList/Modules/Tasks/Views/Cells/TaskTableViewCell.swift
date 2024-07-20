//
//  TaskTableViewCell.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//


import UIKit

protocol TaskTableViewCellDelegate: AnyObject {
    func didTapCompleteButton(on cell: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {

    weak var delegate: TaskTableViewCellDelegate?

    static let reuseIdentifier = "TaskTableViewCell"

    private let titleLabel = UILabel()
    private let priorityLabel = UILabel()
    private let titleHeadingLabel = UILabel()
    private let priorityHeadingLabel = UILabel()
    private let dueDateHeadingLabel = UILabel()
    private let dueDateLabel = UILabel()
    private let completeButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleHeadingLabel.text = "Title:"
        priorityHeadingLabel.text = "Priority:"
        dueDateHeadingLabel.text = "Due Date:"
        
        titleHeadingLabel.font = UIFont.boldSystemFont(ofSize: 15)
        priorityHeadingLabel.font = UIFont.boldSystemFont(ofSize: 15)
        dueDateHeadingLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        priorityLabel.font = UIFont.systemFont(ofSize: 15)
        dueDateLabel.font = UIFont.systemFont(ofSize: 15)
        
        
        titleHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        dueDateHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        dueDateLabel.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleHeadingLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priorityHeadingLabel)
        contentView.addSubview(priorityLabel)
        contentView.addSubview(dueDateHeadingLabel)
        contentView.addSubview(dueDateLabel)
        contentView.addSubview(completeButton)

        NSLayoutConstraint.activate([
            titleHeadingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleHeadingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            titleLabel.leadingAnchor.constraint(equalTo: titleHeadingLabel.trailingAnchor, constant: 5),
            titleLabel.centerYAnchor.constraint(equalTo: titleHeadingLabel.centerYAnchor),

            priorityHeadingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priorityHeadingLabel.topAnchor.constraint(equalTo: titleHeadingLabel.bottomAnchor, constant: 5),

            priorityLabel.leadingAnchor.constraint(equalTo: priorityHeadingLabel.trailingAnchor, constant: 5),
            priorityLabel.centerYAnchor.constraint(equalTo: priorityHeadingLabel.centerYAnchor),

            dueDateHeadingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dueDateHeadingLabel.topAnchor.constraint(equalTo: priorityHeadingLabel.bottomAnchor, constant: 5),

            dueDateLabel.leadingAnchor.constraint(equalTo: dueDateHeadingLabel.trailingAnchor, constant: 5),
            dueDateLabel.centerYAnchor.constraint(equalTo: dueDateHeadingLabel.centerYAnchor),
            dueDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            completeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            completeButton.widthAnchor.constraint(equalToConstant: 48),
            completeButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        completeButton.layer.cornerRadius = 12
        completeButton.layer.borderWidth = 1
        completeButton.layer.borderColor = UIColor.gray.cgColor
        completeButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        completeButton.tintColor = .clear
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }

    func configure(task: ToDoTask) {
        titleLabel.text = task.title
        priorityLabel.text = task.priority
        if let date = task.dueDate {
            dueDateLabel.text = "\(date.formatted(date: .abbreviated, time: .shortened))"
        }
        completeButton.tintColor = task.isCompleted ? .systemBlue : .clear
    }

    @objc private func completeButtonTapped() {
        delegate?.didTapCompleteButton(on: self)
    }
}

