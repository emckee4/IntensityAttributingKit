//
//  IALocationPicker.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/30/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation
import MapKit
//import CoreLocation
class IALocationPickerVC:UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    var mapView:MKMapView!
    var geocoder:CLGeocoder!
    fileprivate var locationManagerDelegateShim:IALocationManagerDelegateShim!
    var delegate:IALocationPickerDelegate?

    var longPressGestureRecognizer:UILongPressGestureRecognizer!
    
    

    var selectedLocation:MKPointAnnotation?
    var selectedPlacemark:CLPlacemark?
    var lastGeolocatedUserLocation:CLPlacemark?
    
    var userPlacemark:CLPlacemark? {
        didSet{
            if userPlacemark != nil {
                userDetailLabel.text = userPlacemark?.name
                userDetailLabel.sizeToFit()
            } else {
                userDetailLabel.text = nil
                userDetailLabel.sizeToFit()
            }
        }
    }
    
    ///This will become true the first time a geolocation for the user is found. This is used to indicate whether the camera should adjust to the newly found position.
    fileprivate var hasZoomedToUser:Bool = false
    
    ///Since MKUserLocation is immutable but required to get the system to use the private MKModernUserLocationView, we attach this label to said view in the detailCalloutAccessoryView to enable a display of location data in the user callout in the position where a subtitle would display text.
    fileprivate var userDetailLabel:UILabel!
    
    var toolbar:UIToolbar!
    var confirmButton:UIBarButtonItem!
    var cancelButton:UIBarButtonItem!
    
    
    //MARK:-Setup and lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.delegate = self
        
        
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        geocoder = CLGeocoder()

        setupToolbar()
        
        //longpress recognizer
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(IALocationPickerVC.longPressDetected(_:)) )
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        
        
        
        //location manager delegatation
        locationManagerDelegateShim = IALocationManagerDelegateShim()
        locationManagerDelegateShim.previousDelegate = IAKitPreferences.locationManager.delegate
        locationManagerDelegateShim.currentDelegate = self
        IAKitPreferences.locationManager.delegate = locationManagerDelegateShim
        checkAuthStatus()
        
        userDetailLabel = UILabel()
        userDetailLabel.font = UIFont.systemFont(ofSize: 12)
    }
    
    func setupToolbar(){
        toolbar = UIToolbar()
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        toolbar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(IALocationPickerVC.cancelAndDismiss(_:)))
        confirmButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(IALocationPickerVC.confirmSelection(_:)))
        confirmButton.isEnabled = false
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton, flexSpace, confirmButton], animated: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IAKitPreferences.locationManager.delegate = locationManagerDelegateShim.previousDelegate
        geocoder.cancelGeocode()
    }
    
  
    //MARK:-GestureRecognizers

    
    func longPressDetected(_ sender:UILongPressGestureRecognizer!){
        guard sender.state == .began else {return}
        print("longpress detected")
        let locPoint = sender.location(in: mapView)
        if selectedLocation == nil {
            let loc = mapView.convert(locPoint, toCoordinateFrom: mapView)
            selectedLocation = MKPointAnnotation()
            selectedLocation!.coordinate = loc
            selectedLocation!.title = "Selected Location"
            mapView.addAnnotation(selectedLocation!)
            reverseGeocode(selectedLocation!)
            mapView.selectAnnotation(selectedLocation!, animated: true)
        }
    }
    
    //MARK:- MapView delegate functions
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("view for annotation")
        guard !(annotation is MKUserLocation) else {return nil}
        var pin:MKPinAnnotationView!
        if let oldPin = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView {
            pin = oldPin
            pin.annotation = annotation
        } else {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }

        pin.canShowCallout = true
        pin.isDraggable = true
        
        return pin
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("did select \(view)")
        confirmButton.isEnabled = true
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("didDeselect")
        confirmButton.isEnabled = false
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        print("didChangeDragState")
        if newState == .ending && view.annotation != nil{
            selectedPlacemark = nil
            reverseGeocode(view.annotation!)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("didAddAnnotationViews")
        for item in views where item.annotation is MKUserLocation{
            //item.rightCalloutAccessoryView = userCheckButton
            item.detailCalloutAccessoryView = userDetailLabel
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        userPlacemark = nil
        reverseGeocode(userLocation)
    }
    
    func reverseGeocode(_ annotation: MKAnnotation){
        
        geocoder.reverseGeocodeLocation(CLLocation(latitude: annotation.coordinate.latitude,longitude: annotation.coordinate.longitude)) { (placemarkArray, error) in
        
            guard let placemark = placemarkArray?.first else {print("no placemark");return}
            print("placemark: \(placemark.name ?? ""), aoi: \(placemark.areasOfInterest ?? [])")
            
            if annotation is MKUserLocation {
                self.userPlacemark = placemark
                if self.hasZoomedToUser == false, let region = placemark.region as? CLCircularRegion{
                    let convertedRegion = MKCoordinateRegionMakeWithDistance(region.center, region.radius, region.radius)
                    self.mapView.setRegion(convertedRegion, animated: true)
                    self.hasZoomedToUser = true
                }
                self.lastGeolocatedUserLocation = placemark
            } else {
                guard placemark.location?.coordinate != nil else {return}
                self.selectedPlacemark = placemark
                if let name = placemark.name {
                    if Int(name) != nil {
                        let title:String = (placemark.subAdministrativeArea != nil ? "\(placemark.subAdministrativeArea!), " : "") + (placemark.administrativeArea != nil ? "\(placemark.administrativeArea!), " : "") + (placemark.country != nil ? "\(placemark.country!), " : "")
                        self.selectedLocation?.title = title
                    } else {
                        self.selectedLocation?.title = name
                    }
                }
            }
        }
    }
    
    
    //MARK:- LocationManagerDelegate and AuthCheck
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthStatus()
    }
 
    func checkAuthStatus(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways,.authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .notDetermined:
            IAKitPreferences.locationManager.requestWhenInUseAuthorization()
        default:
            break //Location not authorized
        }
    }
    
    func confirmSelection(_ sender:AnyObject!){
        guard let selection = mapView.selectedAnnotations.first else {return}
        var finalPlacemark:IAPlacemark!
        //var isUser:Bool = false
        var mapViewDeltaMeters:CLLocationDistance!
        if mapView.frame.height > mapView.frame.width {
            mapViewDeltaMeters = mapView.region.span.latitudeDelta * 111000 * Double(mapView.frame.width / mapView.frame.height)
        } else {
            mapViewDeltaMeters = mapView.region.span.latitudeDelta * 111000
        }
        
        if selection is MKUserLocation {
            //isUser = true
            if let upc = userPlacemark?.location?.coordinate, selection.coordinate.isEqualTo(location: upc) {
            finalPlacemark = IAPlacemark(placemark: userPlacemark!)
            } else if let upc = userPlacemark?.location?.coordinate, let lastGeoLoc = lastGeolocatedUserLocation?.location?.coordinate, upc.isEqualTo(location: lastGeoLoc, withEpsilon: 0.00009) {
                finalPlacemark = IAPlacemark(coordinate: selection.coordinate, addressDictionary: lastGeolocatedUserLocation!.addressDictionary as? [String : Any])
            } else {
                var addressDict:[String:Any]?
                if let singleUnwrappedName = selection.subtitle, let subName = singleUnwrappedName {
                    addressDict = ["name":subName]
                }
                finalPlacemark = IAPlacemark(coordinate: selection.coordinate, addressDictionary: addressDict)
            }
        } else if selection is MKPointAnnotation {
            //isUser = false
            if selectedPlacemark?.location?.coordinate != nil && selection.coordinate.isEqualTo(location: selectedPlacemark!.location!.coordinate, withEpsilon: 0.00008) {
                finalPlacemark = IAPlacemark(placemark: selectedPlacemark!)
            } else {
                let addressDict = selectedPlacemark?.addressDictionary as? [String:Any]
                finalPlacemark = IAPlacemark(coordinate: selection.coordinate, addressDictionary: addressDict)
            }
        }
        delegate?.locationPickerController(self, location: finalPlacemark, mapViewDeltaMeters: mapViewDeltaMeters)
    }
    
    func cancelAndDismiss(_ sender:AnyObject!){
        delegate?.locationPickerControllerDidCancel(self)
    }


}



protocol IALocationPickerDelegate:class {
    func locationPickerController(_ picker: IALocationPickerVC, location:IAPlacemark, mapViewDeltaMeters:CLLocationDistance)
    func locationPickerControllerDidCancel(_ picker: IALocationPickerVC)->Void
    
}


extension CLLocationCoordinate2D {
    ///Default epsilon is around 2.2 meters
    func isEqualTo(location:CLLocationCoordinate2D, withEpsilon epsilon:CLLocationDegrees = 0.00002)->Bool{
        return abs(self.latitude - location.latitude) < epsilon && abs(self.longitude - location.longitude) < epsilon
    }
}


