//
//  IAString.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/26/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


/**The IAString is the core data structure at the heart of the IntensityAttributingKit. It's similar in concept to an NSAttributedString except that it's designed to more abstractly represent the data that may be displayed via varying schemes.
*/
open class IAString {
    
    internal(set) open var text:String {
        didSet{self.length = self.text.utf16.count}
    }
    internal(set) var intensities:[Int] = []
    
    internal(set) var baseAttributes:CollapsingArray<IABaseAttributes>
    
    
    internal(set) var links:[RangeValuePair<URL>] = []

    open internal(set) var attachments: IAAttachmentArray = IAAttachmentArray()
    open var attachmentCount:Int {
        return attachments.count
    }

    open var baseOptions:IAStringOptions!
    
    ///Based on UTF16 count of text. All other counts should stay in sync with this.
    fileprivate(set) open var length:Int
    
    //////////////////////////////////////
    
    open var avgIntensity:Int {return intensities.reduce(0, +) / intensities.count}
    
    open var hasAttachmentsWithPlaceholders:Bool {
        for (_,attach) in self.attachments {
            guard !attach.showingPlaceholder else {return true}
        }
        return false
    }
    
    ///Converts the iaString to a dictionary which is ready for direct coversion to JSON except for containing an iaTextAttachments key which needs to be stripped out and handled separately when uploading.
    open func convertToAlmostJSONReadyDict(useStringURLs:Bool = false)->[String:Any]{
        var dict:[String:Any] = [:]
        dict[IAStringKeys.text] = self.text as Any?
        dict[IAStringKeys.intensities] = self.intensities as Any?
        
        dict[IAStringKeys.baseAttributes] = self.baseAttributes.asRVPArray as Any?
        let urlRVPs = self.links.map({$0.asArray})
        if useStringURLs {
            var stringRVPs:[[Any]] = []
            for rvp in urlRVPs {
                guard rvp.count == 3 else {continue}
                guard let urlString = (rvp[2] as? URL)?.absoluteString else {continue}
                stringRVPs.append([rvp[0],rvp[1],urlString])
            }
            dict[IAStringKeys.linkRVPs] = stringRVPs as Any?
        } else {
            dict[IAStringKeys.nsurlRVPs] = urlRVPs
        }
        
        
        dict[IAStringKeys.options] = baseOptions.asOptionsDict() as Any?
        
        
        var attachDict:[Int:IATextAttachment] = [:]
        for (loc,attach) in self.attachments {
            attachDict[loc] = attach
        }
        dict[IAStringKeys.iaTextAttachments] = attachDict as Any?
        return dict
    }
    
    ///This functions as an inverse of convertToAlmostJSONReadyDict but it can accept attachments in IAStringKeys.attachments format (for which it will insert placeholders) or in .iaTextAttachments format. If preferedSmoothing and/or renderScheme are embeded in the renderOptions dictionary then this will pull them out automatically.
    public init!(dict:[String:AnyObject]){
        guard let newText = dict[IAStringKeys.text] as? String, let newIntensities = dict[IAStringKeys.intensities] as? [Int], let rawBaseAtts = dict[IAStringKeys.baseAttributes] as? [[Int]] else {
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
                if let urlString = textRVP[2] as? String, let start = textRVP[0] as? Int, let end = textRVP[1] as? Int {
                    if let url = URL(string: urlString) {
                        self.links.append(RangeValuePair(value: url, startIndex: start, endIndex: end))
                    }
                }
            }
        } else if let newURLs = dict[IAStringKeys.nsurlRVPs] as? [[AnyObject]] {
            for urlRVP in newURLs {
                if let url = (urlRVP[2] as? URL), let start = urlRVP[0] as? Int, let end = urlRVP[1] as? Int {
                    self.links.append(RangeValuePair(value: url, startIndex: start, endIndex: end))
                }
            }
        } else {
            print("IAString(dict) received no link info")
            return nil
        }
        
        if let iaAttachments = dict[IAStringKeys.iaTextAttachments] as? [Int:IATextAttachment] {
            for (key, attach) in iaAttachments.sorted(by: {$0.0 < $1.0}) {
                self.attachments[key] = attach
            }
        } else if let newAttachments = dict[IAStringKeys.attachments] as? [Int:AnyObject]{
            //(loc, attachInfo)
            for (_) in newAttachments {
                print("IAString.init(dict:) received attachment \(newAttachments) in non IATA form")
//                guard let attachTypeString = attachInfo["attachType"] as? String, attachType =
//                guard let filename = attachInfo["name"] as? String, remoteURLString = attachInfo["url"] as? String else {continue}
//                guard let remoteURL = NSURL(string: remoteURLString) else {continue}
//                let newAttach = IAImageAttachment(filename: filename, remoteURL: remoteURL, localURL: nil)
//                print("IAString 123: fix IAImageAttachment init")
//                self.attachments[loc] = newAttach
            }
        }
        
        if let opts = IAStringOptions(optionsDict: (dict[IAStringKeys.options] as? [String:AnyObject])) {
            self.baseOptions = opts
        } else {
            self.baseOptions = IAKitPreferences.iaStringDefaultBaseOptions
        }
        
    }
    
    ///This is intended for initialization of IAIntermediate within the module. It provides only minimal sanity checks.
    fileprivate init!(text:String, intensities:[Int], attributes:IABaseAttributes, baseOptions:IAStringOptions = IAKitPreferences.iaStringDefaultBaseOptions){
        self.text = text
        self.length = self.text.utf16.count
        guard intensities.count == self.length else {baseAttributes = [];return nil}
        self.intensities = intensities
        self.baseAttributes = CollapsingArray.init(repeatedValue: attributes, count: self.length)
        self.baseOptions = baseOptions
    }
    
    init(text:String, intensity:Int, attributes:IABaseAttributes, baseOptions:IAStringOptions = IAKitPreferences.iaStringDefaultBaseOptions){
        self.text = text
        self.length = self.text.utf16.count
        self.intensities = Array<Int>(repeating: intensity,count: self.length)
        self.baseAttributes = CollapsingArray.init(repeatedValue: attributes, count: self.length)
        self.baseOptions = baseOptions
    }
    
    ///Initializes an empty IAString with default options
    init(){
        self.text = ""
        self.length = 0
        self.baseAttributes = CollapsingArray<IABaseAttributes>()
        //self.renderScheme = IAKitPreferences.defaultTransformer
        self.baseOptions = IAKitPreferences.iaStringDefaultBaseOptions
    }
    
    
    func scanLinks(){
        invalidateLinks()
        let detector = try! NSDataDetector(types: 8191)
        detector.enumerateMatches(in: self.text, options: .withTransparentBounds, range: NSRange(location: 0, length: self.length)) { (result, flags, stop) -> Void in
            if let result = result {
                print("result: \(result.resultType)")
                if let url = result.url {
                    print("url result: \(result.url!)")
                    self.links.append(RangeValuePair(value: url, range: result.range))
                    //TODO: might want to check if there's already a url in any of the given range.
                }
            }
        }
    }
    
    func invalidateLinks(){
        self.links = []
    }
 
    init!(withText:String, intensities:[Int], baseAtts:CollapsingArray<IABaseAttributes>, attachments:IAAttachmentArray? = nil, baseOptions:IAStringOptions = IAKitPreferences.iaStringDefaultBaseOptions){
        self.text = withText
        self.length = withText.utf16.count
        self.intensities = intensities
        self.baseAttributes = baseAtts
        if let attaches = attachments {
            self.attachments = attaches
        }
        self.baseOptions = baseOptions
        guard length == self.baseAttributes.count && length == self.intensities.count && self.attachments.lastLoc <= length else {return nil}
    }
    
    ///Initializes an IAString with a length of 1 consisting of an attachment.
    init!(withAttachment:IATextAttachment,intensity:Int,baseAtts:IABaseAttributes, baseOptions:IAStringOptions = IAKitPreferences.iaStringDefaultBaseOptions){
        self.text = "\u{FFFC}"
        self.length = text.utf16.count
        self.intensities = [intensity]
        self.baseAttributes = CollapsingArray<IABaseAttributes>(arrayLiteral: baseAtts)
        self.attachments.insertAttachment(withAttachment, atLoc: 0)
        self.baseOptions = baseOptions
        guard length == self.baseAttributes.count && length == self.intensities.count && self.attachments.lastLoc <= length else {return nil}
    }
    
    
    func urlAtIndex(_ index:Int)->(url:URL, urlRange:CountableRange<Int>)?{
        if let rvpIndex = links.index(where: {$0.range.contains(index)}){
            let rvp = links[rvpIndex] 
            return (url:rvp.value, urlRange:rvp.range)
        } else {
            return nil
        }
    }
}
