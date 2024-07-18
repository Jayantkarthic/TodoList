//
//  BaseViewController.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import Foundation
import Combine
import UIKit
import MBProgressHUD

protocol HUDUsed: AnyObject {
    var hud: MBProgressHUD? { get set }
    func showHUD()
    func hideHUD()
}

extension HUDUsed where Self: UIViewController {
    
    func showHUD() {
        let onView = navigationController?.view ?? view
        hud = MBProgressHUD.showAdded(to: onView!, animated: true)
        hud?.mode = .customView
        hud?.isSquare = true
        hud?.backgroundColor = .black.withAlphaComponent(0.2)
        let activityView = NVActivityIndicatorView(
            frame: CGRect(origin: .zero,size: CGSize(width: 32.0,height: 32.0)),
            type: .ballSpinFadeLoader, color: UIColor(named: "Textcolor"))
        hud?.customView = activityView
        activityView.startAnimating()
    }
    
    func showStatus(message: String) {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.mode = .text
        hud?.isSquare = true
        hud?.backgroundColor = .black.withAlphaComponent(0.2)
        hud?.label.text = message
        hud?.hide(animated: true, afterDelay: 3.0)
    }
    
    
    func hideHUD() {
        hud?.hide(animated: true)
    }
    
}


class BaseViewController: UIViewController, HUDUsed {
    
    public var hud: MBProgressHUD?
    internal var cancellables   = Set<AnyCancellable>()
    
 
    
}




extension UIViewController {
    
    func screenWidth()->CGFloat{
         let screenSize = UIScreen.main.bounds
         return screenSize.width
    }
    func screenHeight()->CGFloat{
         let screenSize = UIScreen.main.bounds
         return screenSize.height
    }
    
}
