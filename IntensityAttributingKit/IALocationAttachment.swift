//
//  IALocationAttachment.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/26/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation
import MapKit


/** Concrete subclass of IATextAttachment for handling location attachments. See discussion in comments of IATextAttachment for more info on why this is constructed this way.
 */
open class IALocationAttachment:IATextAttachment {
    
    
    override open var localID: String {
        get{return "lat\(placemark.coordinate.latitude)lon\(placemark.coordinate.longitude)"}
    }
    
    override open var attachmentType:IAAttachmentType {
        return .location
    }
    
    override open var showingPlaceholder:Bool {
        return self._image == nil
    }

    var latitude:CLLocationDegrees {
        return placemark.coordinate.latitude
    }
    var longitude:CLLocationDegrees {
        return placemark.coordinate.longitude
    }

    open let placemark:IAPlacemark
    
    fileprivate var isGeneratingSnapshot:Bool {
        return self.snapshotter != nil
    }

    ///Storage for UIImage of static map.
    fileprivate var _image:UIImage?
    override open var image: UIImage? {
        get {return _image}
        set {_image = newValue}
    }
    

    init!(placemark:IAPlacemark){
        guard placemark.addressDictionary != nil && placemark.region != nil else {return nil}
        self.placemark = placemark
        super.init(data: nil, ofType: nil)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        guard let pm = aDecoder.decodeObject(forKey: "placemark") as? IAPlacemark else {return nil}
        self.placemark = pm
        super.init(coder: aDecoder)
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(placemark, forKey: "placemark")
    }
    
    public init!(portableDict:[String:AnyObject]){
        guard let addressDict = portableDict["addressDictionary"] as? [String:AnyObject], let lat = portableDict["coordinate"]?["latitude"] as? Double, let lon = portableDict["coordinate"]?["longitude"] as? Double, let radius = portableDict["radius"] as? Double else {return nil}
        
        self.placemark = IAPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat,longitude: lon),
            addressDictionary: addressDict,
            placename: portableDict["placename"] as? String,
            radius: radius)
        
        super.init(data: nil, ofType: nil)
    }
    
    deinit{
        if snapshotter != nil && snapshotter!.isLoading == true {
            snapshotter!.cancel()
        }
    }
    
    ///The portable dict format is intended to be easily convertable to JSON for transfer.
    func convertToPortableDict()->[String:AnyObject]!{
        guard let addressDictionary = placemark.addressDictionary, let region = placemark.region as? CLCircularRegion else {print("IALocationAttachment.convertToPortableDict found nil addressDictionary or region in placemark");return nil} //This check should be superfulous since we dont allow an init without these values being set
        var dict:[String:AnyObject] = [:]
        var ad:[String:AnyObject] = [:]
        for (key,value) in addressDictionary {
            if let sKey = key as? String {
                ad[sKey] = value as AnyObject?
            }
        }
        dict["addressDictionary"] = ad as AnyObject?
        var coord:[String:AnyObject] = [:]
        coord["latitude"] = placemark.coordinate.latitude as AnyObject?
        coord["longitude"] = placemark.coordinate.longitude as AnyObject?
        dict["coordinate"] = coord as AnyObject?
        
        dict["radius"] = region.radius as AnyObject?
        if let pm = placemark.placename {
            dict["placename"] = pm as AnyObject?
        }
        
        return dict
    }
    
    fileprivate var snapshotter:MKMapSnapshotter?
    
    func generateImage(){
        guard self._image == nil && self.snapshotter == nil else {return}
        
        let regionSize:CLLocationDistance = ((placemark.region as? CLCircularRegion)?.radius ?? 1000) * 2.0
        
        let snapshotOptions:MKMapSnapshotOptions = {
            let options = MKMapSnapshotOptions()
            options.region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, regionSize, regionSize)
            options.size = CGSize(width: 320,height: 320)
            return options
        }()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if let pn = placemark.placename {
            annotation.title = pn
            annotation.subtitle = placemark.name
        } else {
            annotation.title = placemark.name
        }
        
        self.snapshotter = MKMapSnapshotter(options: snapshotOptions)
        self.snapshotter!.start(with: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)) { snapshot, error in
            guard let snapshot = snapshot else {
                DispatchQueue.main.async(execute: { 
                    defer{self.snapshotter = nil}
                })
                return
            }
            
            let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let image = snapshot.image
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: CGPoint.zero)
            
            let visibleRect = CGRect(origin: CGPoint.zero, size: image.size)
            
            var point = snapshot.point(for: annotation.coordinate)
            if visibleRect.contains(point) {
                point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2)
                point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2)
                pin.image?.draw(at: point)
            }
            
            let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            
            DispatchQueue.main.async(execute: {
                self._image = compositeImage
                self.snapshotter = nil
                self.emitContentReadyNotification(nil)
            })
        }
        
    }
    
    
    override func imageForThumbSize(_ thumbSize:IAThumbSize)->UIImage{
        let cachingName = thumbCatchName(forSize: thumbSize)
        if let thumb = IATextAttachment.thumbCache.object(forKey: cachingName as AnyObject) as? UIImage {
            return thumb
        } else if image != nil {
            let thumb = image!.resizeImageToFit(maxSize: thumbSize.size)
            IATextAttachment.thumbCache.setObject(thumb, forKey: cachingName as AnyObject)
            return thumb
        } else {
            generateImage()
            return IAPlaceholder.forSize(thumbSize, attachType: .image)
        }
    }
    
    open func mapItemForLocation()->MKMapItem{
        let mapitem = MKMapItem(placemark: placemark)
        mapitem.name = placemark.placename ?? placemark.name
        return mapitem
    }
    
    open override func attemptToLoadResource() -> Bool {
        if self._image != nil {
            return true
        } else if isGeneratingSnapshot == false {
            generateImage()
        }
        return false
    }
}

