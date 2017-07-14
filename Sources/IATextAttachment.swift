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
open class IATextAttachment:NSTextAttachment {
    
    fileprivate lazy var _localID:String = {return String.randomAlphaString(8)}()
    ///Either filename or random alpha string (if no filename exists) used for identifying attachments and images with or without filenames
    open var localID: String {
        get{return _localID}
    }
    
    var showingPlaceholder:Bool {  //TODO: Could make this be set by most recent call of imageForBounds -- whether it yields an image or a placeholder
        return true
    }
    
    open var attachmentType:IAAttachmentType{
        return .unknown
    }
    
    
    static let thumbCache = NSCache<AnyObject, AnyObject>()

    override open var image:UIImage? {
        get{return nil}
        set{
            print("Set image in IAImageAttachment instead")
        }
    }
    
    override open var contents: Data? {
        get{return nil}
        set{
        print("Set contents in IATextAttachment subclass instead")
        }
    }
    
    override open var fileType: String?{
        get{return nil}
        set{
            print("Set fileType in IATextAttachment subclass instead")
        }
    }
    
    override open var fileWrapper: FileWrapper? {
        get{return nil}
        set{
            print("Set file location in IATextAttachment subclass instead of using fileWrapper")
        }
    }
    
    override open func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        if let iaContainer = textContainer as? IATextContainer {
            if iaContainer.shouldPresentEmptyImageContainers == true {
                return nil
            } else {
                return imageForThumbSize(iaContainer.preferedThumbSize)
            }
        } else {
            //image is being requested by a non IATextContainer, so presumably something outside of the IAKit
            return super.image(forBounds: imageBounds, textContainer: textContainer, characterIndex: charIndex)
        }
    }
    
    func imageForThumbSize(_ thumbSize:IAThumbSize)->UIImage?{
        return IAPlaceholder.forSize(thumbSize, attachType: .unknown)
    }
    
    
    override open func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        if let iaContainer = textContainer as? IATextContainer {
            return CGRect(origin:CGPoint.zero,size:iaContainer.preferedThumbSize.size)
        } else {
            return CGRect(origin:CGPoint.zero,size:IAThumbSize.Tiny.size)
        }
    }
    
    
    override init(data contentData: Data?, ofType uti: String?) {
        super.init(data: nil, ofType: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(data: nil, ofType: nil)  
    }
    
    open override func encode(with aCoder: NSCoder) {
        //super.encodeWithCoder(aCoder)
    }

    ///The app can call this after completing the download and processing of an item to update teh item and ensure it's ready. Returns true if the resource is/can be loaded
    open func attemptToLoadResource()->Bool{
        return false
    }
    
    func thumbCatchName(forSize thumbSize:IAThumbSize)->String{
        return "\(localID)**\(thumbSize.rawValue)"
    }
    
    ///This is used by an IATextAttachment subclass to indicate that it has or can immediately generate a new thumb for the content. IACompositeBase based classes will listen for this and refresh appropriate thumbnails when they receive this.
    open static let contentReadyNotificationName:String = "IntensityAttributingKit.IATextAttachment.ContentReady"
    
    ///Posts a notification with the class specific contentReadyNotificationName to the default NSNotificationCenter. This is used to indicate to the displaying views that the textattachment subclass has or can immediately generate a new thumb for the content.
    func emitContentReadyNotification(_ userInfo:[String:Any]?){
        var updatedInfo:[String:Any] = userInfo ?? [:]
        updatedInfo["attachmentType"] = self.attachmentType.rawValue as Any?
        updatedInfo["localID"] = self.localID as Any?
        let postNotification:(Void)->Void = {
            let notification = Notification(name: Notification.Name(rawValue: type(of: self).contentReadyNotificationName), object: self, userInfo: updatedInfo)
            NotificationCenter.default.post(notification)
        }
        if Thread.isMainThread {
            postNotification()
        } else {
            DispatchQueue.main.async(execute: postNotification)
        }
    }
    
}

///Used by attachments to request download if needed.
public protocol IAAttachmentDownloadDelegate {
    ///Initiates/requests download of the content for the selected attachment.
    func downloadContentsOf(attachment:IATextAttachment) throws
    
}


/*
 notifications:
    
    download needed
    itemWithID/filename is available
 
 
 for eager upload:
    insertedButNotFinalized
    canceledUnfinalized
 
 
 */




