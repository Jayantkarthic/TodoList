//
//  SceneDelegate.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()
        
        let allTasksViewController = AllTasksViewController()
        let allTasksViewModel = AllTasksViewModel(context: context)
        allTasksViewController.viewModel = allTasksViewModel
        
        let completedTasksViewController = CompletedTasksViewController()
        completedTasksViewController.viewModel = allTasksViewModel

        allTasksViewController.tabBarItem = UITabBarItem(title: "All Tasks", image: UIImage(systemName: "list.bullet"), tag: 0)
        completedTasksViewController.tabBarItem = UITabBarItem(title: "Completed Tasks", image: UIImage(systemName: "checkmark.circle"), tag: 1)
        
        let allTasksNavController = UINavigationController(rootViewController: allTasksViewController)
        let completedTasksNavController = UINavigationController(rootViewController: completedTasksViewController)
        
        tabBarController.viewControllers = [allTasksNavController, completedTasksNavController]
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
}
