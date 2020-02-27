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
        
        checkIfUserIsLoggedIn()
        
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    

    
    // MARK: Data
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil{
            // Seague to login page.
            // Without DispatchQueue.main.async, doesn't work.
            // Because we have to do it on main thread.
            DispatchQueue.main.async {
                
                let nav = UINavigationController(rootViewController: LoginVC())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav,animated: true,completion: nil )
            }
        }
        else{
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
    
    // MARK: Configure
    
    
    func presentLoginController() {
        DispatchQueue.main.async {
            let nav = UINavigationController(rootViewController: LoginVC())
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func configure(){
        fetchUserData()
        
        configureHomeController()
        
    }
    
    func fetchUserData(){
        // Call searvice class
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(uid: currentUid) { (user) in
            self.user = user
        }
    }
    
    
    
    // Configure home controller
    func configureHomeController(){
        addChild(homeVC)
        homeVC.didMove(toParent: self)
        homeVC.configure()
        view.addSubview(homeVC.view)
        homeVC.delegate = self
    }
    
    
    func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        
        if shouldExpand{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeVC.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
                self.blackView.frame = self.homeVC.view.frame
            }, completion: nil)
        }
        else{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.blackView.alpha = 0
                self.homeVC.view.frame.origin.x = 0
                self.blackView.frame = self.homeVC.view.frame
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    // Hide starus bar
    func animateStatusBar(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    func configureMenuController(withUser user: User){
        menuVC = MenuController(user: user)
        addChild(menuVC)
        menuVC.didMove(toParent: self)
        // Home/Menu/Container
        // Insert at menu controller at first postition
        view.insertSubview(menuVC.view, at: 0)
        menuVC.delegate = self
        configureBlackView()
    }
    
    func configureBlackView(){
        blackView.frame = self.view.bounds
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    // MARK: Handlers
    @objc func dissMenu(){
        isExpanded = false
        animateMenu(shouldExpand: isExpanded)
    }
    
    
    
}
// MARK: - HomeControllerDelegate

extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle() {
        // True -> False, False -> True
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
                alert.pruneNegativeWidthConstraints()
                self.present(alert, animated: true, completion: nil)
            case .settings:
                guard let user = self.user else { return }
                let controller = SettingVC(user: user)
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
}

extension ContainerController : SettingVCDelegate{
    func updateUser(_ controller: SettingVC) {
        self.user = controller.user
    }
    
    
}
