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
    let locationManager = LocationHandler.shared.locationManager
    
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
            // Only fetch Drivers, doesn't show location input activation view for driver.
            if user?.accountType == .passenger{
                self.fetchDrivers()
                configureLocationInputActivationView()
                
                observeCurrentTrip()
                
                configureSavedUserLocation()
            }
            else{
                // Observe trips as a driver
                observeTrips()
                
            }
        }
    }
    
    var trip: Trip?{
        didSet{
            guard let user = user else {return}
            // Only show pick up manager to driver
            if user.accountType == .driver {
                guard let trip = trip else {return}
                let controller = PickupVC(trip: trip)
                controller.delegate = self
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
            else {
                
            }
        }
    }
    
    var searchResults = [MKPlacemark]()
    
    var savedLocation = [MKPlacemark]()
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureNavigationBar()
        
        enableLocationServices()
        
        
    }
    
    
    // MARK: Handlers
    @objc func actionButtonPressed(){
        switch actionType {
        case .showMenu:
             delegate?.handleMenuToggle()
        case .backToHome:
            // Center the user.
            guard let coordinate = locationManager?.location?.coordinate else {return}
            self.removeAnnotationAndPolyLine()
            UIView.animate(withDuration: 0.3){
                self.inputActivationView.alpha = 1
                self.configureActionButtonType(config: .showMenu)
                self.presentRideActionView(shouldShow: false)
            }
            let regin = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            self.mapView.setRegion(regin, animated: true)
            
        }
    }
    
    // MARK: Passenger API
    
    func startTrip(){
        guard let trip = self.trip else {return}
        DriverService.shared.updateTripState(trip, .inProgress) { (err, ref) in
            // Pick the users means Trip is in progress
            self.rideActionView.config = .tripInProgress
            // Remove poly lines
            self.removeAnnotationAndPolyLine()
            
            self.mapView.addAnnotationAndSelect(forCoordinates: trip.destinationCoordinates)
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            // Begin to moniter whether arrive at destination
            self.setCustomerRegin(withType: .destination, withCoordinates: trip.destinationCoordinates)
            // Generate new line between current user's location to destination
            self.generatePolyLine(toDestination: mapItem)
            self.mapView.zoomTofit(annotations: self.mapView.annotations)
        }
    }
    
    // The current user is observing his current trip's state.
    func observeCurrentTrip(){
        PassengerService.shared.obserCurrentTrip { (trip) in
            
            self.trip = trip
            guard let state = trip.state else {return}
            switch state{
            case .requested:
                break
            case .accepted:
                self.shouldPresentLoadingView(false)
                // Remove poly line when driver accept
                self.removeAnnotationAndPolyLine()
                // We want to zoom in on the drive that's picked up
                guard let driverUid = trip.driverUid else {return}
                self.zoomForActiveTrip(withDriverId: driverUid)
                Service.shared.fetchUserData(uid: driverUid) { (driver) in
                    self.presentRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .arrivedAtDestination:
                self.rideActionView.config = .endTrip
            case .completed:
                PassengerService.shared.deleteTrip { (err, reference) in
                    self.presentRideActionView(shouldShow: false)
                    self.removeAnnotationAndPolyLine()
                    self.centerAtMap()
                    self.actionType = .showMenu
                    self.configureActionButtonType(config: .showMenu)
                    self.inputActivationView.alpha = 1
                    self.presentAlertController(withTitle: "Trip Completed", withMessage: "We hope you enjoyed your trip")
                }
            case .rejected:
                self.shouldPresentLoadingView(false)
                self.presentAlertController(withTitle: "OMG", withMessage: "We couldn't find a driver..")
    
                PassengerService.shared.deleteTrip { (err, ref) in
                    self.centerAtMap()
                    self.inputActivationView.alpha = 1
                    self.removeAnnotationAndPolyLine()
                    self.configureActionButtonType(config: .showMenu)
                }
            }
            
        }
    }
    
    
    func fetchDrivers(){
        
        guard let location = locationManager?.location else {return}
        // Observe any changes
        PassengerService.shared.fetchDriverData(location: location) { (driver) in
            
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
                        self.zoomForActiveTrip(withDriverId: driverAnno.uid)
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
    // MARK: Driver API
    
    // ConfigureTrips
    func observeTrips(){
        DriverService.shared.observeTrips { (trip) in
            self.trip = trip
        }
    }
    
    func observeCancelledTrip(trip:Trip){
        // Observe whethere the trip is canceled.
        DriverService.shared.observeTripCanceled(trip){
            self.removeAnnotationAndPolyLine()
            self.presentRideActionView(shouldShow: false)
            self.centerAtMap()
            self.presentAlertController(withTitle: "Woops", withMessage: "The passenger has cancelled this trip!")
        }
        
    }
    
    
    // MARK: Shared API
    
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
    

    func configureNavigationBar(){
        navigationController?.navigationBar.isHidden = true
    }
    
    func configureUI(){
        // Configure map view
        configureMap()
        
        // Configure ride action view
        configureRideActionView()
        
        // Configure aciton button
        configureAcitonButton()
        
        configureLocationTableView()
    }
    
    func configureAcitonButton(){
        // Add action button with white background color
        buttonBackGround.addSubview(actionButton)
        actionButton.centerX(inView: buttonBackGround)
        actionButton.centerY(inView: buttonBackGround)
        
        
        view.addSubview(buttonBackGround)
        buttonBackGround.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                                paddingTop: 10, paddingLeft: 15)
    }
    
    func configureRideActionView(){
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    func configureLocationInputActivationView(){
        
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
    }
    
    
    func configure(){
        
        // Configure UI
        configureUI()
        
    }
    
    func configureSavedUserLocation(){
        guard let user = user else {return}
        savedLocation.removeAll()
        if let homeLocation = user.homeLocation{
            geocodeAddressString(address: homeLocation)
        }
        if let workLocation = user.workLocation{
            geocodeAddressString(address: workLocation)
        }
    }
    
    // Transfer string address to MKPlaceMark
    func geocodeAddressString(address: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let clPlaceMark = placemarks?.first else {return}
            let placemark = MKPlacemark(placemark: clPlaceMark)
            self.savedLocation.append(placemark)
            self.locationTableView.reloadData()
        }
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
        locationManager?.delegate = self
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
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("DEBUG: Did strart monitor....")
        if region.identifier == AnnotationType.pickup.rawValue{
            print("DEBUG: Did start montioring pick up regin \(region)")
        }
        if region.identifier == AnnotationType.destination.rawValue{
            print("DEBUG: Did start montioring destination regin \(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        guard let trip = trip else {return}
        
        if region.identifier == AnnotationType.pickup.rawValue{
            // Reset trip's state
            DriverService.shared.updateTripState(trip, .driverArrived) { (error, database) in
                // The driver is close to passenger
                self.rideActionView.config = .pickupPassenger
            }
        }
        
        if region.identifier == AnnotationType.destination.rawValue{
            DriverService.shared.updateTripState(trip, .arrivedAtDestination) { (error, database) in
                // The driver is close to passenger
                self.rideActionView.config = .endTrip
            }
            
        }
        
        
        
    }
}

// MARK: MapView Help Function

extension HomeVC{
    
    
    
    func zoomForActiveTrip(withDriverId id:String){
        
        var annotations = [MKAnnotation]()
        self.mapView.annotations.forEach { (annotation) in
            // check the uid and see if annotation's equal to trip's driver id.
            if let driverAnno = annotation as? DriverAnnotation{
                if driverAnno.uid == id{
                    annotations.append(driverAnno)
                    
                }
            }
            if let userAnno = annotation as? MKUserLocation{
                annotations.append(userAnno)
            }
        }
        if annotations.count == 2
        {
            self.mapView.zoomTofit(annotations: annotations)
        }
        
        
        
    }
    
    func setCustomerRegin(withType type: AnnotationType,withCoordinates coordinates:CLLocationCoordinate2D){
        // Creat an regin for the passenger
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: type.rawValue)
        // Moniter whether the driven enter the regin
        locationManager?.startMonitoring(for: region)
        print("DEBUG: Did set regin \(region)")
    }
    
    // Let the user center at the screen
    func centerAtMap(){
        guard let coordinate = self.locationManager?.location?.coordinate else {return}
        let regin = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(regin, animated: true)
    }
    
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
        // Source
        request.source = MKMapItem.forCurrentLocation()
        // Location
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
    
    func presentRideActionView(shouldShow: Bool, destination:MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user: User? = nil){
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            // Configure UI ride action view
            guard let config = config else {return}
            
            if let user = user{
                self.rideActionView.user = user
            }
            
            // Set destination detail
            if let destination = destination{
                self.rideActionView.destination = destination
            }
            
            self.rideActionView.config = config
            
        }
        
    }
}

// MARK: Table view
extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    
    // Title for header section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Saved Locations" : "Search Results"
    }
    
    // First section we only want to show recent history.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // The number of cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of cell for first section is 2
        return section==0 ? savedLocation.count : searchResults.count
        
    }
    
    // Set cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationTableCell
        if indexPath.section == 0{
            cell.placeMark = savedLocation[indexPath.row]
        }
        if indexPath.section == 1{
            cell.placeMark = searchResults[indexPath.row]
        }
        return cell
    }
    
    // Did select
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = indexPath.section == 0 ? savedLocation[indexPath.row] : searchResults[indexPath.row]
        configureActionButtonType(config: .backToHome)
        //  Add line between start and end.
        let destinationItem = MKMapItem(placemark: selectedPlacemark)
        generatePolyLine(toDestination: destinationItem)
        
        // A completion block for this function and we can run a bunch of code in here to execute once the view finishes dismissing
        dismissLocationView { _ in
            // After a user click an address, dismiss input view
            // Add annotation for destination
            self.mapView.addAnnotationAndSelect(forCoordinates: selectedPlacemark.coordinate)
            
            // Run a filter, we don't want driver annotion (we only have start and destination annotation left)
            let annotations = self.mapView.annotations.filter({!$0.isKind(of: DriverAnnotation.self)})
            // Change zoom level.
            self.mapView.zoomTofit(annotations: annotations)
            
            
            // Should show ride action view
            self.presentRideActionView(shouldShow: true,destination: selectedPlacemark, config: .requestRide)
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
    
    // This function is called whenever a user updates location.
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else {return}
        guard user.accountType == .driver else {return}
        guard let location = userLocation.location else {return}
        DriverService.shared.updateDriverLocation(location: location)
    }
    
    // Customized annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation{
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier:driverIdentifier)
            view.image = #imageLiteral(resourceName: "car")
            return view
        }
        return nil
    }
    
    
    // The renderer object is responsible for drawing the contents of your overlay when asked to do
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route{
            let polyLine = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyLine)
            lineRenderer.strokeColor = .systemOrange
            lineRenderer.lineWidth = 4
            
            return lineRenderer
        }
        else{
            return MKOverlayRenderer()
        }
    }
}

// MARK: RideActionViewDelegate
extension HomeVC : RideActionViewDelegate{
    
    func dropOffPassenger() {
        guard let trip = self.trip else {return}
        DriverService.shared.updateTripState(trip, .completed) { (err, ref) in
            self.removeAnnotationAndPolyLine()
            self.centerAtMap()
            self.presentRideActionView(shouldShow: false)
        }
    }
    
    
    func pickupPassenger() {
        startTrip()
    }
    
    
    func cancelTrip() {
        PassengerService.shared.deleteTrip { (error, ref) in
            if let error = error{
                print("DEBUG: Fail to delete trip: ",error.localizedDescription)
                return
            }
            self.centerAtMap()
            self.presentRideActionView(shouldShow: false)
            self.removeAnnotationAndPolyLine()
            
            // Add back button by changing button's image.
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            // Change action type
            self.actionType = .showMenu
            UIView.animate(withDuration: 0.3){
                self.inputActivationView.alpha = 1
            }
        }
        
        
    }
    
    func upLoadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else {return}
        guard let destinationCoordinates = view.destination?.coordinate else {return}
        
        // Present loading view
        shouldPresentLoadingView(true, message: "Finding you a ride...")
        
        PassengerService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, reference) in
            // What we want to happen after upload trip.
            if let error = error{
                print("DEBUG: Failed to upload trip \(error)")
            }
            UIView.animate(withDuration: 0.3) {
                // Hide ride actio view.
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
    
}


// MARK: PickupVCDelegate
extension HomeVC : PickupVCDelegate {
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip
        // Update the trip
        self.trip?.state = trip.state
        // Add annotation of pick-up location
        self.mapView.addAnnotationAndSelect(forCoordinates: trip.pickupCoordinates)
        
        // When a driver accepts a trip. Start monitor
        self.setCustomerRegin(withType: .pickup, withCoordinates: trip.pickupCoordinates)
        
        // Add polyLine of pick-up location
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyLine(toDestination: mapItem)
        // Zoom to fit
        mapView.zoomTofit(annotations: mapView.annotations)
        
        // Observe cancelled trip
        observeCancelledTrip(trip: trip)
        
        // Dismiss pick up page
        self.dismiss(animated: true){
            guard let passengerUid = trip.passengerUid else {return}
            // Present ride action view
            Service.shared.fetchUserData(uid: passengerUid) { (passenger) in
                self.presentRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
            
        }
        
    }
    
    
}
