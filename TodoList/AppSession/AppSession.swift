//
//  AppSession.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//

import UIKit

class AppSession {
    static let shared = AppSession()

    private init() {}

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func start(in window: UIWindow?) {
        window?.rootViewController = createTabBarController()
        window?.overrideUserInterfaceStyle = .light
        window?.makeKeyAndVisible()
    }

    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()

        let allTasksViewController = AllTasksViewController()
        let allTasksViewModel = AllTasksViewModel(context: context)
        allTasksViewController.viewModel = allTasksViewModel

        let completedTasksViewController = CompletedTasksViewController()
        completedTasksViewController.viewModel = allTasksViewModel

        let allTasksNav = UINavigationController(rootViewController: allTasksViewController)
        allTasksNav.tabBarItem = UITabBarItem(title: "All Tasks", image: UIImage(systemName: "list.bullet"), tag: 0)

        let completedTasksNav = UINavigationController(rootViewController: completedTasksViewController)
        completedTasksNav.tabBarItem = UITabBarItem(title: "Completed Tasks", image: UIImage(systemName: "checkmark.circle"), tag: 1)

        tabBarController.viewControllers = [allTasksNav, completedTasksNav]

        return tabBarController
    }
}

extension UITabBarController {
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let topBorder = UIView()
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1)
        topBorder.backgroundColor = UIColor.lightGray
        tabBar.addSubview(topBorder)
    }
}
