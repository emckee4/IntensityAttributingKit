//
//  IAPlacemark.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 9/8/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import MapKit


///Typealias of IAPlacemark for MKPlacemark to allow for future differention of IAPlacemark as a subclass
//public typealias IAPlacemark = MKPlacemark
public class IAPlacemark:MKPlacemark {
    ///User defined placename
    public let placename:String?
    private var _region:CLRegion?
    override public var region: CLRegion?{
        return _region
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.placename = aDecoder.decodeObjectForKey("placename") as? String
        super.init(coder: aDecoder)
        self._region = (aDecoder.decodeObjectForKey("_region") as? CLCircularRegion) ?? super.region
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(placename, forKey: "placename")
        aCoder.encodeObject(_region, forKey: "_region")
    }
    
    override init(placemark: CLPlacemark) {
        self.placename = nil
        super.init(placemark: placemark)
        self._region = super.region
    }
    
    init(placemark: CLPlacemark, placename:String?) {
        self.placename = placename
        super.init(placemark: placemark)
        self._region = super.region
    }
    
    init(placemark: CLPlacemark, region:CLCircularRegion?) {
        self.placename = nil
        super.init(placemark: placemark)
        self._region = region ?? super.region
    }
    
    init(placemark: CLPlacemark, placename:String?, region:CLCircularRegion?) {
        self.placename = placename
        super.init(placemark: placemark)
        self._region = region ?? super.region
    }
    
    override init(coordinate: CLLocationCoordinate2D, addressDictionary: [String : AnyObject]?) {
        self.placename = nil
        super.init(coordinate: coordinate, addressDictionary: addressDictionary)
        self._region = super.region
    }
    
    public init(coordinate: CLLocationCoordinate2D, addressDictionary: [String : AnyObject]?, placename:String?, radius:CLLocationDistance?) {
        self.placename = placename
        super.init(coordinate: coordinate, addressDictionary: addressDictionary)
        if radius != nil {
            self._region = CLCircularRegion(center: coordinate, radius: radius!, identifier: "IAPlacemark Region")
        } else {
            self._region = super.region
        }
    }
    
}
