//
//  AddLocationVC.swift
//  myUberClone
//
//  Created by Sheldon on 2/26/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import MapKit
class AddLocationVC: UITableViewController {
    
    
    // MARK: Properties
    let searchBar = UISearchBar()
    // A utility object for generating a list of completion strings based on a partial search string that you provide.
    let searchCompleter = MKLocalSearchCompleter()
    
    var delegate : AddLocationVCDelegate?
    var searchResutlts = [MKLocalSearchCompletion](){
        didSet{
             tableView.reloadData()
        }
    }
    
    let type: LocationType
    // Use the location to set a regin and to search
    let location:CLLocation
    
    // MARK: Lift Cycle
    
    init(type: LocationType, location: CLLocation){
        self.type = type
        self.location = location
        super.init(nibName:nil,bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        configureNavgationBar()
        
        configureTable()
        
        configureSearchBar()
        
        configureSearchCompleter()

    }
    
    // MARK: Help Functions
    func configureSearchBar(){
        searchBar.placeholder = "Search by address"
        // Resizes and moves the receiver view so it just encloses its subviews.
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.barStyle = .black
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.white
        navigationItem.titleView = searchBar
    }
    
    func configureNavgationBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
               navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.backgroundColor = .backgroundColor
    }
    
    func configureTable(){
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AddLocation")
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.addShadow()
    }
    
    
    func configureSearchCompleter(){
        let regin = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        searchCompleter.region = regin
        searchCompleter.delegate = self
    }
    
    @objc func handleDismiss(){
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResutlts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "AddLocation")
        let result = searchResutlts[indexPath.row]

        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResutlts[indexPath.row]
        let locationString = result.title + " " + result.subtitle
        let trimmedString = locationString.replacingOccurrences(of: ", United States", with: "")
        delegate?.uploadLocation(type: type, locationString: trimmedString)
    }
}


// MARK: UISearchBarDelegate
extension AddLocationVC : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // The search string for which you want completions.
        searchCompleter.queryFragment = searchText
    }
}

// MARK: MKLocalSearchCompleterDelegate
extension AddLocationVC : MKLocalSearchCompleterDelegate{

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Append result and reload table data.
        searchResutlts = completer.results
    }
}
