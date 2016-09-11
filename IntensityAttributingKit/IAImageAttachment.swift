//
//  IAImageAttachment.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/26/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation



/** Concrete subclass of IATextAttachment for handling image attachments. See discussion in comments of IATextAttachment for more info on why this is constructed this way.
 */
public class IAImageAttachment:IATextAttachment {
    
    ///Either filename or random alpha string (if no filename exists) used for identifying attachments and images with or without filenames
    private lazy var _localID:String = {return self.filename ?? String.randomAlphaString(8)}()
    override public var localID:String {
        get {return _localID}
        set {_localID = newValue}
    }
    
    override public var attachmentType:IAAttachmentType {
        return .image
    }
    
    override public var showingPlaceholder:Bool {
        return self._image == nil
    }
    
    
    public var filename:String?
    ///We retain the reference to the remote location but leave management of the download to the app adopting the framework
    public var remoteFileURL:NSURL?
    ///It's expected that the localFileURL will be fully determined by the filename, i.e. the url will be <some constant path> + <filename>. The localFileURL does not need to be valid yet, but it should point to the eventual location of the downloaded file
    public var localFileURL:NSURL?
    public var temporaryFileURL:NSURL?
    
    ///When true this object is waiting for content to be downloaded and is observing the notifications for image content
    private var waitingForDownload:Bool = false
    
    public init(filename:String,remoteURL:NSURL,localURL:NSURL?){
        super.init(data: nil, ofType: nil)
        self.filename = filename
        self.remoteFileURL = remoteURL
        self.localFileURL = localURL
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        if let localID = aDecoder.decodeObjectForKey("localID") as? String {
            self.localID = localID
        }
        
        if let height = aDecoder.decodeObjectForKey("storedHeight") as? Float, width = aDecoder.decodeObjectForKey("storedWidth") as? Float{
            self._storedContentSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        if let fn = aDecoder.decodeObjectForKey("filename") as? String {self.filename = fn}
        if let localURL = aDecoder.decodeObjectForKey("localURL") as? NSURL {self.localFileURL = localURL}
        if let remoteURL = aDecoder.decodeObjectForKey("remoteURL") as? NSURL {self.remoteFileURL = remoteURL}
        
    }
    
    ///Does not attempt to store image blob. 
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(localID, forKey: "localID")
        if let siSize = self._storedContentSize {
            
            aCoder.encodeFloat(Float(siSize.height), forKey: "storedHeight")
            aCoder.encodeFloat(Float(siSize.width), forKey: "storedWidth")
        }
        aCoder.encodeObject(self.filename, forKey: "filename")
        aCoder.encodeObject(self.remoteFileURL, forKey: "remoteURL")
        aCoder.encodeObject(self.localFileURL, forKey: "localFileURL")
        
        
    }
    
    private var _image:UIImage?
    public override var image:UIImage? {
        get{
            if _image != nil {
                return _image
            } else if let localpath = localFileURL?.path{
                _image = UIImage(contentsOfFile: localpath)
                _storedContentSize = _image?.size
                return _image
            }
            return nil
        }
        set{
            _image = newValue
            _storedContentSize = _image?.size
        }
    }
    
    ///saves the value so it doesn't need to be repeatedly recalculated
    private var _storedContentSize:CGSize?
    public var storedContentSize:CGSize? {
        if let existing = _storedContentSize {
            return existing
        } else if let size = self._image?.size {
            _storedContentSize = size
            return size
        }
        return nil
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
            return IAPlaceholder.forSize(thumbSize, attachType: .image)
        }
    }
    
    
    init(withImage image: UIImage){
        super.init(data: nil, ofType: nil)
        self.image = image
    }
    
    init!(withTemporaryFileLocation loc: NSURL){
        guard let localPath = loc.path else {return nil}
        guard let rawImage = UIImage(contentsOfFile: localPath) else {return nil}
        self.temporaryFileURL = loc
        super.init(data: nil, ofType: nil)
        self.image = rawImage
    }
    
    public override func attemptToLoadResource() -> Bool {
        if self._image != nil {
            return true
        } else if let path = localFileURL?.path {
            if let newImage = UIImage(contentsOfFile: path) {
                self._image = newImage
                emitContentReadyNotification(nil)
                return true
            }
        }
        if self.filename != nil {
            setWaitForDownload()
            _ = try? IAKitPreferences.contentDownloadDelegate?.downloadContentsOf(attachment: self)
        }
        return false
    }
    
    override public var description: String {
        return "<IAImageAttachment>: id \(localID), imageLoaded? \(_image != nil)"
    }
    
    override public var debugDescription:String {
        return "<IAImageAttachment>: filename: \(self.filename ?? "nil"), remoteFileURL:\(self.remoteFileURL ?? "nil"), localFileURL: \(self.localFileURL ?? "nil"), isPlaceholder:\(self.showingPlaceholder)"
    }
    
    ///Sent by the app's download manager to the IImageAttachments to indicate that image content has been downloaded. The user info will provide identifying information including resourceName.
    public static let imageDownloadedNotificationName:String = "IntensityAttributingKit.IAImageAttachment.ImageReady"
    
    ///Used by the download manager of the app to indicate that the resource is available or that the download has failed. We use NSNotificationCenter since one filename could correspond to multiple instances of an attachment.
    public static func emitContentDownloadedNotification(imageFilename:String, localFileLocation:NSURL!, image:UIImage?, downloadError:NSError?){
        var userInfo:[String:AnyObject] = ["imageFilename":imageFilename]
        if image != nil {
            userInfo["image"] = image!
        }
        if localFileLocation != nil {
            userInfo["localFileLocation"] = localFileLocation
        }
        if downloadError != nil {
            userInfo["downloadError"] = downloadError!
        }
        NSNotificationCenter.defaultCenter().postNotificationName(imageDownloadedNotificationName, object: nil, userInfo: userInfo)
    }
    
    func handlePreviewDownloadedNotification(notification:NSNotification!){
        guard let dlFilename = notification.userInfo?["imageFilename"] as? String where self.filename != nil && self.filename! == dlFilename else {return}
        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: IAImageAttachment.imageDownloadedNotificationName)
        waitingForDownload = false
        
        guard notification.userInfo?["downloadError"] == nil else {return}
        
        if self.localFileURL == nil {
            self.localFileURL = notification.userInfo?["localFileLocation"] as? NSURL
        }
        if let dlImage = notification.userInfo?["image"] as? UIImage {
            self._image = dlImage
            self.emitContentReadyNotification(nil)
        } else if let path = self.localFileURL?.path {
            if let dlImage = UIImage(contentsOfFile: path){
                self._image = dlImage
                self.emitContentReadyNotification(nil)
            }
        }
        
    }
    
    ///Can be set by the download manager to cause the attachment to begin observing for download completion. This will prevent the attachment from requesting downloads. Filename must not be nil or this will have no effect.
    func setWaitForDownload(){
        guard self.filename != nil else {return}
        if !waitingForDownload {
            waitingForDownload = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAImageAttachment.handlePreviewDownloadedNotification(_:)), name: IAImageAttachment.imageDownloadedNotificationName, object: nil)
        }
    }
    
    deinit{if waitingForDownload {NSNotificationCenter.defaultCenter().removeObserver(self)}}
    
}
