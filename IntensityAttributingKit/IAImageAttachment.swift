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
open class IAImageAttachment:IATextAttachment {
    
    ///Either filename or random alpha string (if no filename exists) used for identifying attachments and images with or without filenames
    fileprivate lazy var _localID:String = {return self.filename ?? String.randomAlphaString(8)}()
    override open var localID:String {
        get {return _localID}
        set {_localID = newValue}
    }
    
    override open var attachmentType:IAAttachmentType {
        return .image
    }
    
    override open var showingPlaceholder:Bool {
        return self._image == nil
    }
    
    
    open var filename:String?
    ///We retain the reference to the remote location but leave management of the download to the app adopting the framework
    open var remoteFileURL:URL?
    ///It's expected that the localFileURL will be fully determined by the filename, i.e. the url will be <some constant path> + <filename>. The localFileURL does not need to be valid yet, but it should point to the eventual location of the downloaded file
    open var localFileURL:URL?
    open var temporaryFileURL:URL?
    
    ///When true this object is waiting for content to be downloaded and is observing the notifications for image content
    fileprivate(set) open var waitingForDownload:Bool = false
    
    public init(filename:String,remoteURL:URL,localURL:URL?){
        super.init(data: nil, ofType: nil)
        self.filename = filename
        self.remoteFileURL = remoteURL
        self.localFileURL = localURL
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        if let localID = aDecoder.decodeObject(forKey: "localID") as? String {
            self.localID = localID
        }
        
        if let height = aDecoder.decodeObject(forKey: "storedHeight") as? Float, let width = aDecoder.decodeObject(forKey: "storedWidth") as? Float{
            self._storedContentSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        if let fn = aDecoder.decodeObject(forKey: "filename") as? String {self.filename = fn}
        if let localURL = aDecoder.decodeObject(forKey: "localURL") as? URL {self.localFileURL = localURL}
        if let remoteURL = aDecoder.decodeObject(forKey: "remoteURL") as? URL {self.remoteFileURL = remoteURL}
        
    }
    
    ///Does not attempt to store image blob. 
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(localID, forKey: "localID")
        if let siSize = self._storedContentSize {
            
            aCoder.encode(Float(siSize.height), forKey: "storedHeight")
            aCoder.encode(Float(siSize.width), forKey: "storedWidth")
        }
        aCoder.encode(self.filename, forKey: "filename")
        aCoder.encode(self.remoteFileURL, forKey: "remoteURL")
        aCoder.encode(self.localFileURL, forKey: "localFileURL")
        
        
    }
    
    fileprivate var _image:UIImage?
    open override var image:UIImage? {
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
    fileprivate var _storedContentSize:CGSize?
    open var storedContentSize:CGSize? {
        if let existing = _storedContentSize {
            return existing
        } else if let size = self._image?.size {
            _storedContentSize = size
            return size
        }
        return nil
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
            return IAPlaceholder.forSize(thumbSize, attachType: .image)
        }
    }
    
    
    init(withImage image: UIImage){
        super.init(data: nil, ofType: nil)
        self.image = image
    }
    
    init!(withTemporaryFileLocation loc: URL!){
        guard let localPath = loc?.path else {return nil}
        guard let rawImage = UIImage(contentsOfFile: localPath) else {return nil}
        self.temporaryFileURL = loc
        super.init(data: nil, ofType: nil)
        self.image = rawImage
    }
    
    open override func attemptToLoadResource() -> Bool {
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
    
    override open var description: String {
        return "<IAImageAttachment>: id \(localID), imageLoaded? \(_image != nil)"
    }
    
    override open var debugDescription:String {
        return "<IAImageAttachment>: filename: \(self.filename ?? "nil"), remoteFileURL:\(self.remoteFileURL?.absoluteString ?? "nil"), localFileURL: \(self.localFileURL?.absoluteString ?? "nil"), isPlaceholder:\(self.showingPlaceholder)"
    }
    
    ///Sent by the app's download manager to the IImageAttachments to indicate that image content has been downloaded. The user info will provide identifying information including resourceName.
    open static let imageDownloadedNotificationName:String = "IntensityAttributingKit.IAImageAttachment.ImageReady"
    
    ///Used by the download manager of the app to indicate that the resource is available or that the download has failed. We use NSNotificationCenter since one filename could correspond to multiple instances of an attachment.
    open static func emitContentDownloadedNotification(_ imageFilename:String, localFileLocation:URL!, image:UIImage?, downloadError:NSError?){
        var userInfo:[String:AnyObject] = ["imageFilename":imageFilename as AnyObject]
        if image != nil {
            userInfo["image"] = image!
        }
        if localFileLocation != nil {
            userInfo["localFileLocation"] = localFileLocation as AnyObject?
        }
        if downloadError != nil {
            userInfo["downloadError"] = downloadError!
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: imageDownloadedNotificationName), object: nil, userInfo: userInfo)
    }
    
    func handlePreviewDownloadedNotification(_ notification:Notification!){
        guard let dlFilename = notification.userInfo?["imageFilename"] as? String, self.filename != nil && self.filename! == dlFilename else {return}
        NotificationCenter.default.removeObserver(self, forKeyPath: IAImageAttachment.imageDownloadedNotificationName)
        waitingForDownload = false
        
        guard notification.userInfo?["downloadError"] == nil else {return}
        
        if self.localFileURL == nil {
            self.localFileURL = notification.userInfo?["localFileLocation"] as? URL
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
    open func setWaitForDownload(){
        guard self.filename != nil else {return}
        if !waitingForDownload {
            waitingForDownload = true
            NotificationCenter.default.addObserver(self, selector: #selector(IAImageAttachment.handlePreviewDownloadedNotification(_:)), name: NSNotification.Name(rawValue: IAImageAttachment.imageDownloadedNotificationName), object: nil)
        }
    }
    
    deinit{if waitingForDownload {NotificationCenter.default.removeObserver(self)}}
    
}
