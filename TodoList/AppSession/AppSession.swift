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

    func start(in window: UIWindow?) {
        window?.rootViewController = createTabBarController()
        window?.makeKeyAndVisible()
    }

    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()

        let allTasksVC = AllTasksViewController()
        let allTasksNav = UINavigationController(rootViewController: allTasksVC)
        allTasksNav.tabBarItem = UITabBarItem(title: "All Tasks", image: UIImage(systemName: "list.bullet"), tag: 0)

        let completedTasksVC = CompletedTasksViewController()
        let completedTasksNav = UINavigationController(rootViewController: completedTasksVC)
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
