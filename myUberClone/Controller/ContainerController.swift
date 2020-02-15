//
//  ContainerController.swift
//  myUberClone
//
//  Created by Sheldon on 2/10/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import Firebase
class ContainerController: UIViewController {
    // MARK: Properties
    let homeVC = HomeVC()
    var menuVC : MenuController!
    var isExpanded = false
    let blackView = UIView()
    lazy var xOrigin = self.view.frame.width - 80
    
     private var user: User? {
           didSet {
               guard let user = user else { return }
               homeVC.user = user
               configureMenuController(withUser: user)
           }
       }
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        print("container view did load")
        checkIfUserIsLoggedIn()
        
      
    }
    
    // MARK: Handlers
    
    
    // MARK: Data
    func checkIfUserIsLoggedIn(){
        print("checkIfUserIsLoggedIn")
        if Auth.auth().currentUser?.uid == nil{
            print("nil")
            // Present login in controller.
        }
        else {
            print("not nill")
            configure()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            presentLoginController()
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    // MARK: UI
    func presentLoginController() {
        DispatchQueue.main.async {
            let nav = UINavigationController(rootViewController: LoginVC())
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func configure(){
        view.backgroundColor = .backgroundColor
        configureHomeController()
        
        // fetchUserData()
    }
    
 
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    // Configure homw controller
    func configureHomeController(){
        addChild(homeVC)
        homeVC.didMove(toParent: self)
        view.addSubview(homeVC.view)
        homeVC.delegate = self
    }
    

    func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        if shouldExpand{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeVC.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
            }, completion: nil)
        }
        else{
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeVC.view.frame.origin.x = 0
            }, completion: completion)
        }
    }
    
    
    func configureMenuController(withUser user: User){
        menuVC = MenuController(user: user)
        addChild(menuVC)
        menuVC.didMove(toParent: self)
        view.insertSubview(menuVC.view, at: 0)
        menuVC.delegate = self
        configureBlackView()
    }
    
    func configureBlackView(){
        
    }
    
    
    
    
}
// MARK: - HomeControllerDelegate

extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle() {
        
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
}

// MARK: - MenuControllerDelegate
extension ContainerController: MenuControllerDelegate {
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded) { _ in
            switch option {
            case .yourTrips:
                break
            case .logout:
                let alert = UIAlertController(title: nil,
                                              message: "Are you sure you want to log out?",
                                              preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                    // Call log out
                    self.signOut()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            case .settings:
                print("setting")
//                guard let user = self.user else { return }
//                let controller = SettingsController(user: user)
//                controller.delegate = self
//                let nav = UINavigationController(rootViewController: controller)
//                self.present(nav, animated: true, completion: nil)
            }
        }
    }
}
