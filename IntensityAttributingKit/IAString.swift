//
//  IAString.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/26/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


public class IAString {
    
    internal(set) var text:String {
        didSet{self.length = self.text.utf16.count}
    }
    internal(set) var intensities:[Int] = []
    
    internal(set) var baseAttributes:CollapsingArray<IABaseAttributes>
    
    
    internal(set) var links:[RangeValuePair<NSURL>] = []

    internal(set) var attachments: IAAttachmentArray = IAAttachmentArray()
    public var attachmentCount:Int {
        return attachments.count
    }
    
    var renderScheme:IntensityTransformers!
    var renderOptions:[String:AnyObject] = [:]
    
    var thumbSize:ThumbSize = .Medium
    
    var preferedSmoothing: NSStringEnumerationOptions = .ByComposedCharacterSequences

    ///Based on UTF16 count of text. All other counts should stay in sync with this.
    private(set) var length:Int
    
    //////////////////////////////////////
    
    
    ///converts the IAIntermediate to a tupple containing a JSON ready dictionary and an array of NSData for the text attachments in sequential order. We use the locations of the attachSizeVWRanges as the locations for our attachments when reconstructing
    public func convertToJSONReadyDictWithData()->([String:AnyObject],[Int:NSData]){
        var dict:[String:AnyObject] = [:]
        dict[IAStringKeys.text] = self.text
        dict[IAStringKeys.intensities] = self.intensities
        
        dict[IAStringKeys.baseAttributes] = self.baseAttributes.asRVPArray
        dict[IAStringKeys.linkRVPs] = self.links.map({$0.asArray})
        
        
        dict[IAStringKeys.renderScheme] = renderScheme?.rawValue ?? IAKitOptions.singleton.defaultScheme.rawValue
        dict[IAStringKeys.preferedSmoothing] = self.preferedSmoothing.rawValue
        dict[IAStringKeys.options] = self.renderOptions
        
        //TODO: Choosing of source of data/ conversion should occur in IATextAttachment
        var dataDict:[Int:NSData] = [:]
        for (loc,attach) in self.attachments {
            //let nsTA = attachVWR.value as! IATextAttachment
            if let data = attach.contents {
                dataDict[loc] = data
            } else if let wrapper = attach.fileWrapper where wrapper.regularFileContents != nil {
                dataDict[loc] = wrapper.regularFileContents!
            } else if let image = attach.image {
                dataDict[loc] = UIImageJPEGRepresentation(image, 0.8)!
            } else {
                print("error converting text attachment to NSData. Appending empty placeholder instead")
                dataDict[loc] = NSData()
            }
        }
        
        return (dict, dataDict)
    }
    
    ///inverse of convertToJSONReadyDictWithData with the exception of attachment data: IATextAttachments are added at the proper indexes but left empty
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
        }
        
        if let newAttachments = dict[IAStringKeys.attachments] as? [[AnyObject]]{
            for rawAttachItems in newAttachments {
                if let loc = rawAttachItems[0] as? Int, attach = rawAttachItems[1] as? IATextAttachment {
                    self.attachments[loc] = attach
                }
            }
        }
        
        //single value
        if let scheme = dict[IAStringKeys.renderScheme] as? String {
            self.renderScheme = IntensityTransformers(rawValue: scheme)
        } else {
            self.renderScheme = IAKitOptions.singleton.defaultScheme
        }
        
        if let ps = dict[IAStringKeys.preferedSmoothing] as? UInt{
            self.preferedSmoothing = NSStringEnumerationOptions(rawValue: ps)
        }
        
        if let opts = dict[IAStringKeys.options] as? [String:AnyObject]{
            self.renderOptions = opts
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
    
    ///Initializes an empty IAString with default options
    init(){
        self.text = ""
        self.length = 0
        self.baseAttributes = CollapsingArray<IABaseAttributes>()
        self.renderScheme = IAKitOptions.singleton.defaultScheme
    }
    
    
    func scanLinks(){
        invalidateLinks()
        fatalError("need to implement scan for links")
        
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
//
//
//
/////extracts NSRanges of true values from arrays of boolean values. "false" values are ignored since they can be inferred.
//private func extractTrueRanges(array:[Bool])->[NSRange]{
//    var trueRanges:[NSRange] = []
//    var currentStart:Int!
//    var currentLength:Int = 0
//    
//    for (i,val) in array.enumerate(){
//        if val {
//            if currentStart == nil {
//                currentStart = i
//                currentLength = 1
//            } else {
//                currentLength++
//            }
//        } else {
//            if currentStart != nil {
//                trueRanges.append(NSRange(location: currentStart, length: currentLength))
//                currentStart = nil
//                currentLength = 0
//            }
//        }
//    }
//    if currentStart != nil {
//        trueRanges.append(NSRange(location: currentStart, length: currentLength))
//    }
//    return trueRanges
//}
//
//
/////returns an array of ValueWithRange objects
//private func extractValueStreaks(array:[NSObject])->[ValueWithRange]{
//    var vwr:[ValueWithRange] = []
//    var currentVWR:ValueWithRange!
//    for (i,val) in array.enumerate(){
//        if i == 0 {
//            currentVWR = ValueWithRange(value: val, location: 0, length: 1)
//        } else {
//            if val == currentVWR.value as! NSObject{
//                currentVWR.length++
//            } else {
//                vwr.append(currentVWR)
//                currentVWR = ValueWithRange(value: val, location: i, length: 1)
//            }
//        }
//    }
//    vwr.append(currentVWR)
//    return vwr
//}


