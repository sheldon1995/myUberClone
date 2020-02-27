//
//  SettingVC.swift
//  myUberClone
//
//  Created by Sheldon on 2/26/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit


class SettingVC: UITableViewController {
    
    // MARK: Properties
    private let reuseIdentifier = "LocationCell"
    
    var user: User
    
    let locationManager = LocationHandler.shared.locationManager
    
    var delegate : SettingVCDelegate?
    var userInfoUpdated = false
    
    private lazy var profileHeader : SettingProfileHeaderVC = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        let headerView = SettingProfileHeaderVC(user: user, frame: frame)
        return headerView
    }()
    
    
    // MARK: Life Cycle
    
    init(user: User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        configureTable()
        
        
        
    }
    
    // MARK: - Table Cell
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationTableCell
        guard let type = LocationType(rawValue: indexPath.row) else {return cell}
        cell.titleLabel.text = type.description
        cell.addressLabel.text = locationText(forType: type)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else {return}
        guard let location = locationManager?.location else {return}
        
        let controller = AddLocationVC(type: type, location: location)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
    
    // MARK: Table Header
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        
        let title = UILabel()
        title.text = "Favoriates"
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
        view.addSubview(title)
        title.centerY(inView: view,leftAnchor: view.leftAnchor,paddingLeft: 16)
        return view
    }
    
    // MARK: Help Functions
    
    func locationText(forType type: LocationType) -> String{
        switch type {
        case .home:
            return user.homeLocation ?? type.subtitle
        case .work:
            return user.workLocation ?? type.subtitle
        }
    }
    
    func configureTable(){
        tableView.register(LocationTableCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.backgroundColor = .white
        tableView.tableHeaderView = profileHeader
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Settings"
        navigationController?.navigationBar.backgroundColor = .backgroundColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
    }
    
    
    // MARK: Handlers
    
    @objc func handleDismiss(){
        // Update the user
        if userInfoUpdated{
            delegate?.updateUser(self)
        }
        dismiss(animated: true, completion: nil)
        
    }
    
}

extension SettingVC : AddLocationVCDelegate{
    // Upload location to server and assin location string to user.
    func uploadLocation(type: LocationType, locationString: String) {
        PassengerService.shared.saveLocation(type: type, locationString: locationString) { (err, ref) in
            // Dismiss addloaction vc
            self.dismiss(animated: true, completion: nil)
            self.userInfoUpdated = true
            switch type{
            case .home:
                self.user.homeLocation = locationString
            case .work:
                self.user.workLocation = locationString
            }
            self.tableView.reloadData()
        }
    }
    
    
}


