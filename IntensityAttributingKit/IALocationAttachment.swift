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
public class IALocationAttachment:IATextAttachment {
    
    
    override public var localID: String {
        get{return "lat\(placemark.coordinate.latitude)lon\(placemark.coordinate.longitude)"}
    }
    
    override public var attachmentType:IAAttachmentType {
        return .location
    }
    
    override public var showingPlaceholder:Bool {
        return self._image == nil
    }

    var latitude:CLLocationDegrees {
        return placemark.coordinate.latitude
    }
    var longitude:CLLocationDegrees {
        return placemark.coordinate.longitude
    }

    public let placemark:IAPlacemark
    
    private var isGeneratingSnapshot:Bool {
        return self.snapshotter != nil
    }

    ///Storage for UIImage of static map.
    private var _image:UIImage?
    override public var image: UIImage? {
        get {return _image}
        set {_image = newValue}
    }
    

    init!(placemark:IAPlacemark){
        guard placemark.addressDictionary != nil && placemark.region != nil else {return nil}
        self.placemark = placemark
        super.init(data: nil, ofType: nil)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        guard let pm = aDecoder.decodeObjectForKey("placemark") as? IAPlacemark else {return nil}
        self.placemark = pm
        super.init(coder: aDecoder)
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(placemark, forKey: "placemark")
    }
    
    public init!(portableDict:[String:AnyObject]){
        guard let addressDict = portableDict["addressDictionary"] as? [String:AnyObject], lat = portableDict["coordinate"]?["latitude"] as? Double, lon = portableDict["coordinate"]?["longitude"] as? Double, radius = portableDict["radius"] as? Double else {return nil}
        
        self.placemark = IAPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat,longitude: lon),
            addressDictionary: addressDict,
            placename: portableDict["placename"] as? String,
            radius: radius)
        
        super.init(data: nil, ofType: nil)
    }
    
    deinit{
        if snapshotter != nil && snapshotter!.loading == true {
            snapshotter!.cancel()
        }
    }
    
    ///The portable dict format is intended to be easily convertable to JSON for transfer.
    func convertToPortableDict()->[String:AnyObject]!{
        guard let addressDictionary = placemark.addressDictionary, region = placemark.region as? CLCircularRegion else {print("IALocationAttachment.convertToPortableDict found nil addressDictionary or region in placemark");return nil} //This check should be superfulous since we dont allow an init without these values being set
        var dict:[String:AnyObject] = [:]
        var ad:[String:AnyObject] = [:]
        for (key,value) in addressDictionary {
            if let sKey = key as? String {
                ad[sKey] = value
            }
        }
        dict["addressDictionary"] = ad
        var coord:[String:AnyObject] = [:]
        coord["latitude"] = placemark.coordinate.latitude
        coord["longitude"] = placemark.coordinate.longitude
        dict["coordinate"] = coord
        
        dict["radius"] = region.radius
        if let pm = placemark.placename {
            dict["placename"] = pm
        }
        
        return dict
    }
    
    private var snapshotter:MKMapSnapshotter?
    
    func generateImage(){
        guard self._image == nil && self.snapshotter == nil else {return}
        
        let regionSize:CLLocationDistance = ((placemark.region as? CLCircularRegion)?.radius ?? 1000) * 2.0
        
        let snapshotOptions:MKMapSnapshotOptions = {
            let options = MKMapSnapshotOptions()
            options.region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, regionSize, regionSize)
            options.size = CGSizeMake(320,320)
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
        self.snapshotter!.startWithQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { snapshot, error in
            guard let snapshot = snapshot else {
                dispatch_async(dispatch_get_main_queue(), { 
                    defer{self.snapshotter = nil}
                })
                return
            }
            
            let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let image = snapshot.image
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.drawAtPoint(CGPoint.zero)
            
            let visibleRect = CGRect(origin: CGPoint.zero, size: image.size)
            
            var point = snapshot.pointForCoordinate(annotation.coordinate)
            if visibleRect.contains(point) {
                point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2)
                point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2)
                pin.image?.drawAtPoint(point)
            }
            
            let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            
            dispatch_async(dispatch_get_main_queue(), {
                self._image = compositeImage
                self.snapshotter = nil
                self.emitContentReadyNotification(nil)
            })
        }
        
    }
    
    
    override func imageForThumbSize(thumbSize:IAThumbSize)->UIImage{
        let cachingName = thumbCatchName(forSize: thumbSize)
        if let thumb = IATextAttachment.thumbCache.objectForKey(cachingName) as? UIImage {
            return thumb
        } else if image != nil {
            let thumb = image!.resizeImageToFit(maxSize: thumbSize.size)
            IATextAttachment.thumbCache.setObject(thumb, forKey: cachingName)
            return thumb
        } else {
            generateImage()
            return IAPlaceholder.forSize(thumbSize, attachType: .image)
        }
    }
    
    public func mapItemForLocation()->MKMapItem{
        let mapitem = MKMapItem(placemark: placemark)
        mapitem.name = placemark.placename ?? placemark.name
        return mapitem
    }
    
    
}

