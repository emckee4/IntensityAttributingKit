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
    private var locationManagerDelegateShim:IALocationManagerDelegateShim!
    var delegate:IALocationPickerDelegate?

    var longPressGestureRecognizer:UILongPressGestureRecognizer!
    
    

    var selectedLocation:MKPointAnnotation?
    var selectedPlacemark:CLPlacemark?
    
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
    private var hasZoomedToUser:Bool = false
    
    ///Since MKUserLocation is immutable but required to get the system to use the private MKModernUserLocationView, we attach this label to said view in the detailCalloutAccessoryView to enable a display of location data in the user callout in the position where a subtitle would display text.
    private var userDetailLabel:UILabel!
    
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
        
        
        mapView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        mapView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        mapView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        mapView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true

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
        userDetailLabel.font = UIFont.systemFontOfSize(12)
    }
    
    func setupToolbar(){
        toolbar = UIToolbar()
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.heightAnchor.constraintEqualToConstant(44.0).active = true
        toolbar.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        toolbar.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        toolbar.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(IALocationPickerVC.cancelAndDismiss(_:)))
        confirmButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(IALocationPickerVC.confirmSelection(_:)))
        confirmButton.enabled = false
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton, flexSpace, confirmButton], animated: false)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        IAKitPreferences.locationManager.delegate = locationManagerDelegateShim.previousDelegate
        geocoder.cancelGeocode()
    }
    
  
    //MARK:-GestureRecognizers

    
    func longPressDetected(sender:UILongPressGestureRecognizer!){
        guard sender.state == .Began else {return}
        print("longpress detected")
        let locPoint = sender.locationInView(mapView)
        if selectedLocation == nil {
            let loc = mapView.convertPoint(locPoint, toCoordinateFromView: mapView)
            selectedLocation = MKPointAnnotation()
            selectedLocation!.coordinate = loc
            selectedLocation!.title = "Selected Location"
            mapView.addAnnotation(selectedLocation!)
            reverseGeocode(selectedLocation!)
        }
    }
    
    //MARK:- MapView delegate functions
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print("view for annotation")
        guard !(annotation is MKUserLocation) else {return nil}
        var pin:MKPinAnnotationView!
        if let oldPin = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView {
            pin = oldPin
            pin.annotation = annotation
        } else {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }

        pin.canShowCallout = true
        pin.draggable = true
        
        return pin
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("did select \(view)")
        confirmButton.enabled = true
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        print("didDeselect")
        confirmButton.enabled = false
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        print("didChangeDragState")
        if newState == .Ending && view.annotation != nil{
            selectedPlacemark = nil
            reverseGeocode(view.annotation!)
        }
        
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        print("didAddAnnotationViews")
        for item in views where item.annotation is MKUserLocation{
            //item.rightCalloutAccessoryView = userCheckButton
            item.detailCalloutAccessoryView = userDetailLabel
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        userPlacemark = nil
        reverseGeocode(userLocation)
    }
    
    func reverseGeocode(annotation: MKAnnotation){
        
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
            } else {
                self.selectedPlacemark = placemark
                if let name = placemark.name {
                    if Int(name) != nil {
                        self.selectedLocation?.title = (placemark.subAdministrativeArea != nil ? "\(placemark.subAdministrativeArea!), " : "") + (placemark.administrativeArea != nil ? "\(placemark.administrativeArea!), " : "") + (placemark.country != nil ? "\(placemark.country!), " : "")
                    } else {
                        self.selectedLocation?.title = name
                    }
                }
            }
        }
    }
    
    
    //MARK:- LocationManagerDelegate and AuthCheck
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        checkAuthStatus()
    }
 
    func checkAuthStatus(){
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways,.AuthorizedWhenInUse:
            mapView.showsUserLocation = true
        case .NotDetermined:
            IAKitPreferences.locationManager.requestWhenInUseAuthorization()
        default:
            break //Location not authorized
        }
    }
    
    func confirmSelection(sender:AnyObject!){
        guard let selection = mapView.selectedAnnotations.first else {return}
        var finalPlacemark:IAPlacemark!
        //var isUser:Bool = false
        if selection is MKUserLocation {
            //isUser = true
            if selection.coordinate.isEqualTo(location: userPlacemark?.location?.coordinate ?? CLLocationCoordinate2D()) {
                finalPlacemark = IAPlacemark(placemark: userPlacemark!)
            } else {
                finalPlacemark = IAPlacemark(coordinate: selection.coordinate, addressDictionary: nil)
            }
        } else if selection is MKPointAnnotation {
            //isUser = false
            if selection.coordinate.isEqualTo(location: selectedPlacemark?.location?.coordinate ?? CLLocationCoordinate2D()) {
                finalPlacemark = IAPlacemark(placemark: selectedPlacemark!)
            } else {
                finalPlacemark = IAPlacemark(coordinate: selection.coordinate, addressDictionary: nil)
            }
        }
        delegate?.locationPickerController(self, location: finalPlacemark)
    }
    
    func cancelAndDismiss(sender:AnyObject!){
        delegate?.locationPickerControllerDidCancel(self)
    }


}



protocol IALocationPickerDelegate:class {
    func locationPickerController(picker: IALocationPickerVC, location:IAPlacemark)
    func locationPickerControllerDidCancel(picker: IALocationPickerVC)->Void
    
}


extension CLLocationCoordinate2D {
    ///Default epsilon is around 2.2 meters
    func isEqualTo(location location:CLLocationCoordinate2D, withEpsilon epsilon:CLLocationDegrees = 0.00002)->Bool{
        return abs(self.latitude - location.latitude) < epsilon && abs(self.longitude - location.longitude) < epsilon
    }
}


