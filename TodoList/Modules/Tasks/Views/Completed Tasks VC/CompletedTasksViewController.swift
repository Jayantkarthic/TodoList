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
    private let searchBar = UISearchBar()
    
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.isHidden = true
        imageView.image = UIImage(named: "NoTasksCompleted")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCompletedTasks()
        bindViewModel()
        setupTapGesture()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Completed Tasks"
     
        
   
        searchBar.placeholder = "Search Tasks"
        searchBar.delegate = self
        searchBar.sizeToFit()
        view.addSubview(searchBar)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        
        placeholderImageView.contentMode = .scaleAspectFit
        placeholderImageView.isHidden = true
        view.addSubview(placeholderImageView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 200),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func loadCompletedTasks() {
        tableView.reloadData()
        updatePlaceholder()
    }
    private func updatePlaceholder() {
        if viewModel?.completedTasks.isEmpty == true {
            tableView.isHidden = true
            placeholderImageView.isHidden = false
        } else {
            tableView.isHidden = false
            placeholderImageView.isHidden = true
        }
    }
   
    private func bindViewModel() {
        viewModel?.$filteredTasks
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
                updatePlaceholder()
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

extension CompletedTasksViewController :UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.searchTasks(with: searchText)
    }
}
