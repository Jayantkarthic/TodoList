//
//  TaskHelper.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import UIKit

extension UIViewController {
    func handleTaskCompletion(task: ToDoTask, viewModel: AllTasksViewModel, tableView: UITableView) {
        let title = task.isCompleted ? "Mark Incomplete" : "Mark Complete"
        let message = task.isCompleted ? "Are you sure you want to mark this task as incomplete?" : "Are you sure you want to mark this task as complete?"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            viewModel.toggleTaskCompletion(task)
            tableView.reloadData()
            self.notifyAllTasksViewController()
        }))
        present(alert, animated: true, completion: nil)
    }

    private func notifyAllTasksViewController() {
        if let tabBarController = self.tabBarController,
           let allTasksNavVC = tabBarController.viewControllers?.first as? UINavigationController,
           let allTasksVC = allTasksNavVC.viewControllers.first as? AllTasksViewController {
            allTasksVC.loadTasks()
        }
    }
}

extension Notification.Name {
    static let tasksUpdated = Notification.Name("tasksUpdated")
}
