//
//  LaunchScreenViewController.swift
//  TodoList
//
//  Created by Jayant Karthic on 20/07/24.
//

import Foundation
import UIKit
class LaunchScreenViewController: UIViewController {
    
    var window: UIWindow?
    @IBOutlet weak var imageView: UIImageView!
    var timer = Timer()
    
    private var gifImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
   

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            print("move")
            AppSession.shared.start(in: self.window )
        })
    }
    
}
