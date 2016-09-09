//
//  IATextAttachment.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/6/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/**
 IATextAttachment is a subclass of NSTextAttachment and is intended to be used as an abstract superclass to other IAAttachment subclasses (like IAImageAttachment). In order to use TextKit for layout management, attachments must be packaged in NSTextAttachment subclasses; merely conforming to the NSTextAttachmentContainer protocol is not enough. Using these custom subclasses let us handle more attachment types and allow for some modifications which greatly improve performance.
 Some of the biggest performance improvements come from using a preset IAThumbSize determined by the displaying view. When the NSLayoutManager of the IACompositeBased view requests the attachmentBoundsForTextContainer, the text container it passes in is an IATextContainer which will convey the desired thumbsize of the view. By using one of a few preset thumb sizes, sizing calculations are greatly sped up since the underlying attachment data needn't be accessed. Furthermore we can more easily provide placeholder thumbnails for attachments which are not yet available while also providing for easier calculation and caching of thumbnails once ready.
 The actual drawing of the text can likewise occur more quickly since imageForBounds will return nil, causing the ThinTextView layers to draw empty rects over which the IAImageLayerView will later (and possibly asynchronously) draw the image. This not only allows us to animate the opacity of the text layers without affecting the images, but it also improves drawing performance immensely compared to the conventional out of the box methods.
 
 Note NSCoding encode/decode will not attempt to encode image/video BLOBs. Either a permenant reference should be established or the file should be written to a temporary location on disk before attempting to encode/store.
*/

///Abstract base class for IATextAttachments
public class IATextAttachment:NSTextAttachment {
    
    private lazy var _localID:String = {return String.randomAlphaString(8)}()
    ///Either filename or random alpha string (if no filename exists) used for identifying attachments and images with or without filenames
    public var localID: String {
        get{return _localID}
    }
    
    var showingPlaceholder:Bool {  //TODO: Could make this be set by most recent call of imageForBounds -- whether it yields an image or a placeholder
        return true
    }
    
    public var attachmentType:IAAttachmentType{
        return .unknown
    }
    
    
    static let thumbCache = NSCache()

    override public var image:UIImage? {
        get{return nil}
        set{
            print("Set image in IAImageAttachment instead")
        }
    }
    
    override public var contents: NSData? {
        get{return nil}
        set{
        print("Set contents in IATextAttachment subclass instead")
        }
    }
    
    override public var fileType: String?{
        get{return nil}
        set{
            print("Set fileType in IATextAttachment subclass instead")
        }
    }
    
    override public var fileWrapper: NSFileWrapper? {
        get{return nil}
        set{
            print("Set file location in IATextAttachment subclass instead of using fileWrapper")
        }
    }
    
    override public func imageForBounds(imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        if let iaContainer = textContainer as? IATextContainer {
            if iaContainer.shouldPresentEmptyImageContainers == true {
                return nil
            } else {
                return imageForThumbSize(iaContainer.preferedThumbSize)
            }
        } else {
            //image is being requested by a non IATextContainer, so presumably something outside of the IAKit
            return super.imageForBounds(imageBounds, textContainer: textContainer, characterIndex: charIndex)
        }
    }
    
    func imageForThumbSize(thumbSize:IAThumbSize)->UIImage{
        return IAPlaceholder.forSize(thumbSize, attachType: .unknown)
    }
    
    
    override public func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        if let iaContainer = textContainer as? IATextContainer {
            return CGRect(origin:CGPointZero,size:iaContainer.preferedThumbSize.size)
        } else {
            return CGRect(origin:CGPointZero,size:IAThumbSize.Tiny.size)
        }
    }
    
    
    override init(data contentData: NSData?, ofType uti: String?) {
        super.init(data: nil, ofType: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        //super.init(coder: aDecoder)
        self.init()
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        //super.encodeWithCoder(aCoder)
    }

    ///The app can call this after completing the download and processing of an item to update teh item and ensure it's ready
    public func checkResourceAvailable()->Bool{
        return false
    }
    
    func thumbCatchName(forSize thumbSize:IAThumbSize)->String{
        return "\(localID)**\(thumbSize.rawValue)"
    }
    
    
    public class var contentReadyNotificationName:String {return "IntensityAttributingKit.IATextAttachment.ContentReady"}
    
    ///Posts a notification with the class specific contentReadyNotificationName to the default NSNotificationCenter
    func emitContentReadyNotification(userInfo:[String:AnyObject]?){
        var updatedInfo:[String:AnyObject] = userInfo ?? [:]
        updatedInfo["attachmentType"] = self.attachmentType.rawValue
        updatedInfo["localID"] = self.localID
        let postNotification:Void->Void = {
            let notification = NSNotification(name: self.dynamicType.contentReadyNotificationName, object: self, userInfo: updatedInfo)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
        if NSThread.isMainThread() {
            postNotification()
        } else {
            dispatch_async(dispatch_get_main_queue(), postNotification)
        }
    }
}


/*
 notifications:
    
    download needed
    itemWithID/filename is available
 
 
 for eager upload:
    insertedButNotFinalized
    canceledUnfinalized
 
 
 */




