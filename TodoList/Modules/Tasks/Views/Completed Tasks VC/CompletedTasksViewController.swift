//
//  CompletedTasksViewController.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//

import UIKit
import Combine

class CompletedTasksViewController: UIViewController {

    private let tableView = UITableView()
    var viewModel: AllTasksViewModel?
    private var cancellables = Set<AnyCancellable>()

    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCompletedTasks()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Completed Tasks"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sortTasksTapped))

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Tasks"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.reuseIdentifier)
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func loadCompletedTasks() {
        tableView.reloadData()
    }

    @objc private func sortTasksTapped() {
        let alert = UIAlertController(title: "Sort Tasks", message: "Choose sorting criteria", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sort by Due Date", style: .default, handler: { [weak self] _ in
            self?.viewModel?.sortTasks(by: .dueDate)
        }))
        alert.addAction(UIAlertAction(title: "Sort by Priority", style: .default, handler: { [weak self] _ in
            self?.viewModel?.sortTasks(by: .priority)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func bindViewModel() {
        viewModel?.$filteredTasks
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)
    }
}

extension CompletedTasksViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.completedTasks.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier, for: indexPath) as! TaskTableViewCell
        cell.delegate = self
        if let task = viewModel?.completedTasks[indexPath.row] {
            cell.configure(task: task)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedTask = viewModel?.completedTasks[indexPath.row] {
            let taskDetailVC = TaskDetailViewController()
            taskDetailVC.task = selectedTask
            taskDetailVC.viewModel = viewModel
            taskDetailVC.delegate = self
            navigationController?.pushViewController(taskDetailVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let task = viewModel?.completedTasks[indexPath.row] {
                viewModel?.deleteTask(task)
            }
        }
    }
}

extension CompletedTasksViewController: TaskTableViewCellDelegate {
    func didTapCompleteButton(on cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let task = viewModel?.completedTasks[indexPath.row],
              let viewModel = viewModel else { return }

        handleTaskCompletion(task: task, viewModel: viewModel, tableView: tableView)
    }
}

extension CompletedTasksViewController: TaskDetailViewControllerDelegate {
    func didSaveTask() {
        loadCompletedTasks()
    }
}

extension CompletedTasksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        viewModel?.searchTasks(with: query)
    }
}
