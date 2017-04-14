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
open class IAPlacemark:MKPlacemark {
    ///User defined placename
    open let placename:String?
    fileprivate var _region:CLRegion?
    override open var region: CLRegion?{
        return _region
    }

    var mapViewLatitudeDelta:CLLocationDistance?
    
    required public init?(coder aDecoder: NSCoder) {
        self.placename = aDecoder.decodeObject(forKey: "placename") as? String
        super.init(coder: aDecoder)
        self._region = (aDecoder.decodeObject(forKey: "_region") as? CLCircularRegion) ?? super.region
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(placename, forKey: "placename")
        aCoder.encode(_region, forKey: "_region")
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
    
    override init(coordinate: CLLocationCoordinate2D, addressDictionary: [String : Any]?) {
        self.placename = nil
        super.init(coordinate: coordinate, addressDictionary: addressDictionary)
        if super.region == nil {
            self._region = CLCircularRegion(center: coordinate, radius: 10, identifier: "IAPlacemark Region")
        } else {
            self._region = super.region
        }
    }
    
    public init(coordinate: CLLocationCoordinate2D, addressDictionary: [String : Any]?, placename:String?, radius:CLLocationDistance?) {
        self.placename = placename
        super.init(coordinate: coordinate, addressDictionary: addressDictionary)
        if radius != nil {
            self._region = CLCircularRegion(center: coordinate, radius: radius!, identifier: "IAPlacemark Region")
        } else {
            self._region = super.region
        }
    }
}
