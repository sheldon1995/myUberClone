//
//  HomeVC.swift
//  myUberClone
//
//  Created by Sheldon on 2/4/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import Firebase
import MapKit


let reuseIdentifier = "locationCell"

let driverIdentifier = "driverIdentifier"

enum actionButtonType{
    case showMenu
    case backToHome
    init(){
        self = .showMenu
    }
}
class HomeVC: UIViewController {
    // MARK: Properties
    let mapView = MKMapView()
    
    // Location manager
    let locationManager = LocationHandelr.shared.locationManager
    
    // Location input view
    let locationInputView = LocationInputView()
    
    // Location activation input view
    let inputActivationView = LocationInputActivationView()
    
    // Talbe view
    let locationTableView = UITableView()
    
    final let locationInputViewHeight:CGFloat = 200
    
    weak var delegate: HomeControllerDelegate?
    
    // Ride action view
    let rideActionViewHeight:CGFloat = 300
    
    // Action button type.
    var actionType = actionButtonType()
    
    // The route from start to destination
    var route: MKRoute?
    
    // Ride action view
    
    let rideActionView = RideActionView()
    
    // Action button
    let actionButton : UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // Action button's white background
    let buttonBackGround: UIView = {
        let whiteBackgroundView = UIView()
        whiteBackgroundView.setDimensions(height: 50, width: 50)
        whiteBackgroundView.backgroundColor = .white
        whiteBackgroundView.layer.cornerRadius = 60 / 2
        return whiteBackgroundView
    }()
    
    var user: User? {
        didSet {
            locationInputView.user = user
            
        }
    }
    
    var searchResults = [MKPlacemark]()
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure UI if user is logged in or jump to logn in page.
        checkUserIsLoggedIn()
        
        configureNavigationBar()
        
        enableLocationServices()
        
    }
    
    
    // MARK: Handlers
    @objc func actionButtonPressed(){
        switch actionType {
        case .showMenu:
            print("Show menu")
        case .backToHome:
            // self.mapView.frame =  self.view.frame
            // Center the user.
            self.mapView.setUserTrackingMode(.follow, animated: false)
            self.removeAnnotationAndPolyLine()
            UIView.animate(withDuration: 0.3){
                self.inputActivationView.alpha = 1
                self.configureActionButtonType(config: .showMenu)
                self.presentRideActionView(shouldShow: false)
                // self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            }
            //self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            
            
        }
        delegate?.handleMenuToggle()
    }
    
    // MARK: API
    
    func configureActionButtonType(config: actionButtonType){
        switch config {
        case .showMenu:
            // Add back button by changing button's image.
            actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            // Change action type
            actionType = .showMenu
        case .backToHome:
            UIView.animate(withDuration: 0.5){
                // Reshow input activation view
                self.inputActivationView.alpha = 0
                self.actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), for: .normal)
                self.actionType = .backToHome
            }
            
        }
    }
    func fetchUserData(){
        // Call searvice class
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(uid: currentUid) { (user) in
            self.user = user
        }
        
    }
    
    func fetchDrivers(){
        guard let location = locationManager?.location else {return}
        Service.shared.fetchDriverData(location: location) { (driver) in
            
            guard let coordinate = driver.location?.coordinate else {return}
            
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            // We need to loop through our all annotations to only add new one (driver) or move the old one to the new position
            var driverIsVisible : Bool {
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else {return false}
                    // If it is visible
                    if driverAnno.uid == driver.uid {
                        // Every time coordinate changes, update it.
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    else {
                        return false
                    }
                }
            }
            if !driverIsVisible{
                // Add new annotation
                self.mapView.addAnnotation(annotation)
            }
            
        }
    }
    
    
    // Check if user is logged in
    
    func checkUserIsLoggedIn(){
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
    
    @objc func handleSignOut(){
        do{
            try Auth.auth().signOut()
        }
        catch{
            print("DEBUG: Failed to sign out.")
        }
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.isHidden = true
    }
    
    func configureUI(){
        // Configure map view
        configureMap()
        
        // Configure ride action view
        configureRideActionView()
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top:view.safeAreaLayoutGuide.topAnchor, paddingTop: 80)
        // 0 means invisible.
        inputActivationView.alpha = 0
        // This is required.
        inputActivationView.delegate = self
        // After 2s, th location input view show up.
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        
        // Add action button with white background color
        buttonBackGround.addSubview(actionButton)
        actionButton.centerX(inView: buttonBackGround)
        actionButton.centerY(inView: buttonBackGround)
        
        
        view.addSubview(buttonBackGround)
        buttonBackGround.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                                paddingTop: 10, paddingLeft: 15)
        
        configureLocationTableView()
    }
    
    
    func configureRideActionView(){
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    
    func configure(){
        
        // Configure UI
        configureUI()
        
        // Fetch user data
        fetchUserData()
        
        // Fetch drivers
        fetchDrivers()
        
    }
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil){
        
        UIView.animate(withDuration: 0.3, animations: {
            // Unlinks the view from its superview and its window, and removes it from the responder chain.
            // We don't want to add same view over and over again.
            self.locationInputView.alpha = 0
            self.locationTableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
            
        }, completion: completion)
        
    }
    
    // MARK: Map
    func configureMap(){
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        // The map follows user location
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        
        
    }
    
    func enableLocationServices(){
        // Required to locate permission my current location
        
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager?.requestAlwaysAuthorization()
        case .restricted,.denied:
            break
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManager?.startUpdatingLocation()
            // The accuracy of the location data.
            
        @unknown default:
            break
        }
    }
    
    
    
    // Set location input view. (To set departion and destination)
    func configureLocationInputView(){
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: locationInputViewHeight)
        locationInputView.alpha = 0
        
        // A chained animation effect
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.3) {
                self.locationTableView.frame.origin.y = self.locationInputViewHeight
            }
        }
    }
    
    func configureLocationTableView(){
        locationTableView.delegate = self
        locationTableView.dataSource = self
        
        // Register cell.
        locationTableView.register(LocationTableCell.self, forCellReuseIdentifier: reuseIdentifier)
        locationTableView.rowHeight = 60
        
        // The view that is displayed below the table's content.
        // Won't show extra line.
        locationTableView.tableFooterView = UIView()
        let height = view.frame.height - locationInputViewHeight
        // Let y = view.frame.height to hide the table view at first.
        locationTableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(locationTableView)
        
    }
}

// MARK: MapView Help Function

extension HomeVC{
    // Give suggested locations according to search key words.
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) ->Void){
        var results = [MKPlacemark]()
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, err) in
            guard let response = response else {return}
            response.mapItems.forEach { (item) in
                
                results.append(item.placemark)
            }
            completion(results)
        }
    }
    
    func generatePolyLine(toDestination destination:MKMapItem){
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        // The type of conveyance to which the directions should apply.
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else {return}
            // Grab the first route
            self.route = response.routes[0]
            guard let polyLine = self.route?.polyline else {return}
            
            // Adds a single overlay object to the map.
            self.mapView.addOverlay(polyLine)
        }
    }
    
    func removeAnnotationAndPolyLine(){
        // Remove annotion
        self.mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                self.mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0{
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func presentRideActionView(shouldShow: Bool, destination:MKPlacemark? = nil){
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        if shouldShow {
            // Set destination detail
            guard let destination = destination else {return}
            self.rideActionView.destination = destination
        }
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
    }
}

// MARK: Table view
extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    
    // Title for header section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    // First section we only want to show recent history.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // The number of cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of cell for first section is 2
        return section==0 ? 2:searchResults.count
        
    }
    
    // Set cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationTableCell
        if indexPath.section == 1{
            cell.placeMark = searchResults[indexPath.row]
        }
        return cell
    }
    
    // Did select
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        configureActionButtonType(config: .backToHome)
        //  Add line between start and end.
        let destinationItem = MKMapItem(placemark: selectedPlacemark)
        generatePolyLine(toDestination: destinationItem)
        
        // A completion block for this function and we can run a bunch of code in here to execute once the view finishes dismissing
        dismissLocationView { _ in
            // After a user click an address, dismiss input view
            // Add annotation for destination
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            // Run a filter, we don't want driver annotion (we only have start and destination annotation left)
            let annotations = self.mapView.annotations.filter({!$0.isKind(of: DriverAnnotation.self)})
            // Change zoom level.
            self.mapView.zoomTofit(annotations: annotations)
            
            
            // Should show ride action view
            self.presentRideActionView(shouldShow: true,destination: selectedPlacemark)
            // self.mapView.frame.size.height = self.view.frame.height - self.rideActionViewHeight
            
        }
    }
    
}

// MARK : LocationInput and LocationActivationView
extension HomeVC: LocationInputActivationViewDelegate, LocationInputViewDelegate{
    
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            self.searchResults = results
            self.locationTableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        dismissLocationView() { _ in
            // To make it more smooth, use animate again
            UIView.animate(withDuration: 0.5) {
                self.inputActivationView.alpha = 1
            }
            
        }
    }
    
    
    func presentLocationInputView() {
        // Hidden the input activation view.
        inputActivationView.alpha = 0
        // Present loaction input view.
        configureLocationInputView()
    }
    
}

// MARK: MapView delegate

extension HomeVC : CLLocationManagerDelegate, MKMapViewDelegate {
    // Customized annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation{
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier:driverIdentifier)
            view.image = #imageLiteral(resourceName: "car")
            return view
        }
        return nil
    }
    
    // To dram a line according to route.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route{
            let polyLine = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyLine)
            lineRenderer.strokeColor = .black
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        else{
            return MKOverlayRenderer()
        }
    }
    
    // Show Current Location and Update Location in MKMapView in Swift
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        locationManager?.delegate = self
    //
    //        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    //
    //        mapView.mapType = MKMapType.standard
    //
    //        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    //        let region = MKCoordinateRegion(center: locValue, span: span)
    //        mapView.setRegion(region, animated: true)
    //
    //        let annotation = MKPointAnnotation()
    //        annotation.coordinate = locValue
    //        annotation.title = "Javed Multani"
    //        annotation.subtitle = "current location"
    //        mapView.addAnnotation(annotation)
    //    }
}

extension HomeVC : RideActionViewDelegate{
    func upLoadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else {return}
        guard let destinationCoordinates = view.destination?.coordinate else {return}
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, reference) in
            // What we want to happen after upload trip.
            if let error = error{
                print("DEBUG: Failed to upload trip \(error)")
            }
        
        }
    }
    
    
}
