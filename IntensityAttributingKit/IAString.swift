//
//  IAString.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/26/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


public class IAString {
    
    internal(set) public var text:String {
        didSet{self.length = self.text.utf16.count}
    }
    internal(set) var intensities:[Int] = []
    
    internal(set) var baseAttributes:CollapsingArray<IABaseAttributes>
    
    
    internal(set) var links:[RangeValuePair<NSURL>] = []

    public internal(set) var attachments: IAAttachmentArray = IAAttachmentArray()
    public var attachmentCount:Int {
        return attachments.count
    }
    
    public var renderScheme:IntensityTransformers!
    public var renderOptions:[String:AnyObject] = [:]
    
    public var thumbSize:ThumbSize = .Medium {
        didSet{self.attachments.setThumbSizes(self.thumbSize)}
    }
    
    public var preferedSmoothing: IAStringTokenizing = .Char

    ///Based on UTF16 count of text. All other counts should stay in sync with this.
    private(set) public var length:Int
    
    //////////////////////////////////////
    
    public var avgIntensity:Int {return intensities.reduce(0, combine: +) / intensities.count}
    
    public var hasAttachmentsWithPlaceholders:Bool {
        for (_,attach) in self.attachments {
            guard !attach.isPlaceholder else {return true}
        }
        return false
    }
    
    ///Converts the iaString to a dictionary which is ready for direct coversion to JSON except for containing an iaTextAttachments key which needs to be stripped out and handled separately when uploading.
    public func convertToAlmostJSONReadyDict(useStringURLs useStringURLs:Bool = false)->[String:AnyObject]{
        var dict:[String:AnyObject] = [:]
        dict[IAStringKeys.text] = self.text
        dict[IAStringKeys.intensities] = self.intensities
        
        dict[IAStringKeys.baseAttributes] = self.baseAttributes.asRVPArray
        let urlRVPs = self.links.map({$0.asArray})
        if useStringURLs {
            var stringRVPs:[[AnyObject]] = []
            for rvp in urlRVPs {
                guard rvp.count == 3 else {continue}
                guard let urlString = (rvp[2] as? NSURL)?.absoluteString else {continue}
                stringRVPs.append([rvp[0],rvp[1],urlString])
            }
            dict[IAStringKeys.linkRVPs] = stringRVPs
        } else {
            dict[IAStringKeys.nsurlRVPs] = urlRVPs
        }
        
        
        
        var combinedOpts = self.renderOptions
        combinedOpts[IAStringKeys.renderScheme] = renderScheme?.rawValue ?? IAKitOptions.singleton.defaultScheme.rawValue
        combinedOpts[IAStringKeys.preferedSmoothing] = self.preferedSmoothing.shortLabel
        
        dict[IAStringKeys.options] = combinedOpts
    
        
        //TODO: Choosing of source of data/ conversion should occur in IATextAttachment
        var attachDict:[Int:IATextAttachment] = [:]
        for (loc,attach) in self.attachments {
//            //let nsTA = attachVWR.value as! IATextAttachment
//            if let data = attach.contents {
//                dataDict[loc] = data
//            } else if let wrapper = attach.fileWrapper where wrapper.regularFileContents != nil {
//                dataDict[loc] = wrapper.regularFileContents!
//            } else if let image = attach.image {
//                dataDict[loc] = UIImageJPEGRepresentation(image, 0.8)!
//            } else {
//                print("error converting text attachment to NSData. Appending empty placeholder instead")
//                dataDict[loc] = NSData()
//            }
            attachDict[loc] = attach
        }
        dict[IAStringKeys.iaTextAttachments] = attachDict
        return dict
    }
    
    ///This functions as an inverse of convertToAlmostJSONReadyDict but it can accept attachments in IAStringKeys.attachments format (for which it will insert placeholders) or in .iaTextAttachments format. If preferedSmoothing and/or renderScheme are embeded in the renderOptions dictionary then this will pull them out automatically.
    public init!(dict:[String:AnyObject]){
        guard let newText = dict[IAStringKeys.text] as? String, newIntensities = dict[IAStringKeys.intensities] as? [Int], rawBaseAtts = dict[IAStringKeys.baseAttributes] as? [[Int]] else {
            print("IAIntermediate received incomplete data"); self.text = ""; self.length = 0; self.baseAttributes = []; return nil
        }
        //string
        self.text = newText
        self.length = self.text.utf16.count
        //array
        self.intensities = newIntensities
        
        //arrays of VWRs
        self.baseAttributes = CollapsingArray<IABaseAttributes>()
        for intRVP in rawBaseAtts {
            self.baseAttributes.appendRepeatedValue(IABaseAttributes(rawValue:intRVP[2]), count: intRVP[1] - intRVP[0])
        }
        
        if let newLinks = dict[IAStringKeys.linkRVPs] as? [[AnyObject]]{
            for textRVP in newLinks {
                if let urlString = textRVP[2] as? String, start = textRVP[0] as? Int, end = textRVP[1] as? Int {
                    if let url = NSURL(string: urlString) {
                        self.links.append(RangeValuePair(value: url, startIndex: start, endIndex: end))
                    }
                }
            }
        } else if let newURLs = dict[IAStringKeys.nsurlRVPs] as? [[AnyObject]] {
            for urlRVP in newURLs {
                if let url = (urlRVP[2] as? NSURL), start = urlRVP[0] as? Int, end = urlRVP[1] as? Int {
                    self.links.append(RangeValuePair(value: url, startIndex: start, endIndex: end))
                }
            }
        } else {
            print("IAString(dict) received no link info")
            return nil
        }
        
        if let iaAttachments = dict[IAStringKeys.iaTextAttachments] as? [Int:IATextAttachment] {
            for (key, attach) in iaAttachments.sort({$0.0 < $1.0}) {
                self.attachments[key] = attach
            }
        } else if let newAttachments = dict[IAStringKeys.attachments] as? [Int:AnyObject]{
            for (loc, attachInfo) in newAttachments {
                guard let filename = attachInfo["name"] as? String, remoteURLString = attachInfo["url"] as? String else {continue}
                guard let remoteURL = NSURL(string: remoteURLString) else {continue}
                let newAttach = IATextAttachment(filename: filename, remoteURL: remoteURL, localURL: nil)
                self.attachments[loc] = newAttach
            }
        } 
        
        //single value
        
        if let opts = dict[IAStringKeys.options] as? [String:AnyObject]{
            self.renderOptions = opts
        }
        
        if let scheme = dict[IAStringKeys.renderScheme] as? String {
            self.renderScheme = IntensityTransformers(rawValue: scheme)
            self.renderOptions.removeValueForKey(IAStringKeys.renderScheme)
        } else if let scheme = self.renderOptions.removeValueForKey(IAStringKeys.renderScheme) as? String where IntensityTransformers(rawValue: scheme) != nil{
            self.renderScheme = IntensityTransformers(rawValue: scheme)
        } else {
            self.renderScheme = IAKitOptions.singleton.defaultScheme
        }
        
        if let ps = dict[IAStringKeys.preferedSmoothing] as? String where IAStringTokenizing(shortLabel: ps) != nil{
            self.preferedSmoothing = IAStringTokenizing(shortLabel: ps)
            self.renderOptions.removeValueForKey(IAStringKeys.preferedSmoothing)
        } else if let ps = self.renderOptions.removeValueForKey(IAStringKeys.preferedSmoothing) as? String where IAStringTokenizing(shortLabel: ps) != nil{
            self.preferedSmoothing = IAStringTokenizing(shortLabel: ps)
        }
        
    }
    
    ///This is intended for initialization of IAIntermediate within the module. It provides only minimal sanity checks.
    private init!(text:String, intensities:[Int], attributes:IABaseAttributes){
        self.text = text
        self.length = self.text.utf16.count
        guard intensities.count == self.length else {baseAttributes = [];return nil}
        self.intensities = intensities
        self.baseAttributes = CollapsingArray.init(repeatedValue: attributes, count: self.length)
    }
    
    init(text:String, intensity:Int, attributes:IABaseAttributes){
        self.text = text
        self.length = self.text.utf16.count
        self.intensities = Array<Int>(count:self.length,repeatedValue:intensity)
        self.baseAttributes = CollapsingArray.init(repeatedValue: attributes, count: self.length)
    }
    
    ///Initializes an empty IAString with default options
    init(){
        self.text = ""
        self.length = 0
        self.baseAttributes = CollapsingArray<IABaseAttributes>()
        self.renderScheme = IAKitOptions.singleton.defaultScheme
    }
    
    
    func scanLinks(){
        invalidateLinks()
        let detector = try! NSDataDetector(types: 8191)
        detector.enumerateMatchesInString(self.text, options: .WithTransparentBounds, range: NSRange(location: 0, length: self.length)) { (result, flags, stop) -> Void in
            if let result = result {
                print("result: \(result.resultType)")
                if let url = result.URL {
                    print("url result: \(result.URL!)")
                    self.links.append(RangeValuePair(value: url, range: result.range))
                    //TODO: might want to check if there's already a url in any of the given range.
                }
            }
        }
    }
    
    func invalidateLinks(){
        self.links = []
    }
 
    init!(withText:String, intensities:[Int], baseAtts:CollapsingArray<IABaseAttributes>, attachments:IAAttachmentArray? = nil){
        self.text = withText
        self.length = withText.utf16.count
        self.intensities = intensities
        self.baseAttributes = baseAtts
        if let attaches = attachments {
            self.attachments = attaches
        }
        guard length == self.baseAttributes.count && length == self.intensities.count && self.attachments.lastLoc <= length else {return nil}
    }
}
