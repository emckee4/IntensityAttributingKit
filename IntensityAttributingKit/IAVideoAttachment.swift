//
//  IAVideoAttachment.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/26/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation
import AVFoundation


/** Concrete subclass of IATextAttachment for handling video attachments. See discussion in comments of IATextAttachment for more info on why this is constructed this way.
 */
public class IAVideoAttachment:IATextAttachment {
  
    ///Either filename or random alpha string (if no filename exists) used for identifying attachments and images with or without filenames
    private lazy var _localID:String = {return self.videoFilename ?? self.temporaryVideoURL?.lastPathComponent ?? String.randomAlphaString(8)}()
    override public var localID:String {
        get {return _localID}
        set {_localID = newValue}
    }
    
    override public var attachmentType:IAAttachmentType {
        return .video
    }
    
    override public var showingPlaceholder:Bool {
        return self.previewImage == nil
    }
    
    
    public var videoFilename:String?
    ///We retain the reference to the remote location but leave management of the download to the app adopting the framework
    public var remoteVideoURL:NSURL?
    ///It's expected that the localFileURL will be fully determined by the filename, i.e. the url will be <some constant path> + <filename>. The localFileURL does not need to be valid yet, but it should point to the eventual location of the downloaded file
    public var localVideoURL:NSURL?
    public var temporaryVideoURL:NSURL?
    
    public var previewFilename:String?
    public var remotePreviewURL:NSURL?
    public var localPreviewURL:NSURL?
    
    public var temporaryPreviewURL:NSURL?
    
    private(set) public var previewImage:UIImage?
    ///saves the value so it doesn't need to be repeatedly recalculated
    private(set) public var storedContentSize:CGSize?
    
    ///When true this object is waiting for content to be downloaded and is observing the notifications for video content
    private(set) public var waitingForDownload:Bool = false
    
    init!(withTemporaryFileLocation loc: NSURL){
        self.temporaryVideoURL = loc
        super.init(data: nil, ofType: nil)
        self.previewImage = generatePreview(temporaryVideoURL!)
    }
    
    public init(videoFilename:String,remoteVideoURL:NSURL,localVideoURL:NSURL?,previewFilename:String,remotePreviewURL:NSURL,localPreviewURL:NSURL?){
        super.init(data: nil, ofType: nil)
        self.videoFilename = videoFilename
        self.remoteVideoURL = remoteVideoURL
        self.localVideoURL = localVideoURL
        self.previewFilename = previewFilename
        self.remotePreviewURL = remotePreviewURL
        self.localPreviewURL = localPreviewURL
        
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        if let localID = aDecoder.decodeObjectForKey("localID") as? String {
            self.localID = localID
        }
        
        if let height = aDecoder.decodeObjectForKey("storedHeight") as? Float, width = aDecoder.decodeObjectForKey("storedWidth") as? Float{
            self.storedContentSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        if let vfn = aDecoder.decodeObjectForKey("videoFilename") as? String {self.videoFilename = vfn}
        if let localVidURL = aDecoder.decodeObjectForKey("localVideoURL") as? NSURL {self.localVideoURL = localVidURL}
        if let remoteVidURL = aDecoder.decodeObjectForKey("remoteVideoURL") as? NSURL {self.remoteVideoURL = remoteVidURL}
        
        if let previewfn = aDecoder.decodeObjectForKey("previewFilename") as? String {self.previewFilename = previewfn}
        if let localPreviewURL = aDecoder.decodeObjectForKey("localPreviewURL") as? NSURL {self.localPreviewURL = localPreviewURL}
        if let remotePreviewURL = aDecoder.decodeObjectForKey("remotePreviewURL") as? NSURL {self.remotePreviewURL = remotePreviewURL}
        
        if localVideoURL == nil, let tempVideoURL = aDecoder.decodeObjectForKey("temporaryVideoURL") as? NSURL {self.temporaryVideoURL = tempVideoURL}
        if localPreviewURL == nil, let tempPreviewURL = aDecoder.decodeObjectForKey("temporaryPreviewURL") as? NSURL {self.temporaryPreviewURL = tempPreviewURL}
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(localID, forKey: "localID")
        if let siSize = self.storedContentSize {
            aCoder.encodeFloat(Float(siSize.height), forKey: "storedHeight")
            aCoder.encodeFloat(Float(siSize.width), forKey: "storedWidth")
        }
        aCoder.encodeObject(self.videoFilename, forKey: "videoFilename")
        aCoder.encodeObject(self.remoteVideoURL, forKey: "remoteVideoURL")
        aCoder.encodeObject(self.localVideoURL, forKey: "localVideoURL")
        
        aCoder.encodeObject(self.previewFilename, forKey: "previewFilename")
        aCoder.encodeObject(self.remotePreviewURL, forKey: "remotePreviewURL")
        aCoder.encodeObject(self.localPreviewURL, forKey: "localPreviewURL")
        
        if self.localVideoURL == nil {
            aCoder.encodeObject(self.temporaryVideoURL, forKey: "temporaryVideoURL")
        }
        if self.localPreviewURL == nil {
            aCoder.encodeObject(self.temporaryPreviewURL, forKey: "temporaryPreviewURL")
        }
    }
    
    override func imageForThumbSize(thumbSize:IAThumbSize)->UIImage{
        let cachingName = thumbCatchName(forSize: thumbSize)
        if let thumb = IATextAttachment.thumbCache.objectForKey(cachingName) as? UIImage {
            return thumb
        } else if previewImage != nil {
            //let thumb = previewImage!.resizeImageToFit(maxSize: thumbSize.size)
            let thumb = previewImage!.resizeImageWithScaleAspectFit(thumbSize.size,backgroundColor: UIColor.blackColor())
            IATextAttachment.thumbCache.setObject(thumb, forKey: cachingName)
            return thumb
        } else {
            return IAPlaceholder.forSize(thumbSize, attachType: .video)
        }
    }
    

    ///Generates a screen shot from the start of the video. This should also set the storedContentSize with the appropriate transform applied.
    func generatePreview(videoURL:NSURL)->UIImage{
        let asset = AVAsset(URL: videoURL)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.appliesPreferredTrackTransform = true
        
        if let preview = try? assetGenerator.copyCGImageAtTime(CMTimeMake(1, 4), actualTime: nil){
            let uiPreview = UIImage(CGImage: preview)
            storedContentSize = CGSizeMake(uiPreview.size.width * uiPreview.scale, uiPreview.size.height * uiPreview.scale)
            return uiPreview
        } else {
            storedContentSize = asset.tracks.first?.naturalSize ?? CGSizeMake(320, 320)
            UIGraphicsBeginImageContextWithOptions(storedContentSize!, true, 1.0)
            let blankPreview = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            return blankPreview!
        }
    }
    
    
    
    ///This only checks/attempts to load the preview.
    public override func attemptToLoadResource() -> Bool {
        if self.previewImage != nil {
            return true
        } else if let path = localPreviewURL?.path {
            if let newImage = UIImage(contentsOfFile: path) {
                self.previewImage = newImage
                emitContentReadyNotification(nil)
                return true
            }
        }
        if self.previewFilename != nil {
            setWaitForDownload()
            _ = try? IAKitPreferences.contentDownloadDelegate?.downloadContentsOf(attachment: self)
        }
        
        return false
    }
    
    
    override public var description: String {
        return "<IAVideoAttachment>: id \(localID)"
    }
    
    override public var debugDescription:String {
        return "<IAVideoAttachment>: videoFilename: \(self.videoFilename ?? "nil"), remoteVideoURL:\(self.remoteVideoURL ?? "nil"), localVideoURL: \(self.localVideoURL ?? "nil"), isPlaceholder:\(self.showingPlaceholder)"
    }

    
    ///Sent by the app's download manager to the IAVideoAttachments to indicate that preview content has been downloaded. The user info will provide identifying information including resourceName.
    public static let videoPreviewDownloadedNotificationName:String = "IntensityAttributingKit.IAVideoAttachment.PreviewReady"
    
    ///Used by the download manager of the app to indicate that the resource is available or that the download has failed.
    public static func emitContentDownloadedNotification(videoPreviewFilename:String, localFileLocation:NSURL!, previewImage:UIImage?, downloadError:NSError?){
        var userInfo:[String:AnyObject] = ["videoPreviewFilename":videoPreviewFilename]
        if previewImage != nil {
            userInfo["previewImage"] = previewImage!
        }
        if localFileLocation != nil {
            userInfo["localFileLocation"] = localFileLocation
        }
        if downloadError != nil {
            userInfo["downloadError"] = downloadError!
        }
        NSNotificationCenter.defaultCenter().postNotificationName(videoPreviewDownloadedNotificationName, object: nil, userInfo: userInfo)
    }
    
    func handlePreviewDownloadedNotification(notification:NSNotification!){
        guard let filename = notification.userInfo?["videoPreviewFilename"] as? String where self.previewFilename != nil && filename == self.previewFilename! else {return}
        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: IAVideoAttachment.videoPreviewDownloadedNotificationName)
        waitingForDownload = false
        
        guard notification.userInfo?["downloadError"] == nil else {return}
        
        if self.localPreviewURL == nil {
            self.localPreviewURL = notification.userInfo?["localFileLocation"] as? NSURL
        }
        if let image = notification.userInfo?["previewImage"] as? UIImage {
            previewImage = image
            self.emitContentReadyNotification(nil)
        } else if let path = self.localPreviewURL?.path {
            if let image = UIImage(contentsOfFile: path){
                previewImage = image
                self.emitContentReadyNotification(nil)
            }
        }
        
    }
    
    ///Can be set by the download manager to cause the attachment to begin observing for download completion. This will prevent the attachment from requesting downloads. Filename must not be nil or this will have no effect.
    public func setWaitForDownload(){
        guard self.previewFilename != nil else {return}
        if !waitingForDownload {
            waitingForDownload = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAVideoAttachment.handlePreviewDownloadedNotification(_:)), name: IAVideoAttachment.videoPreviewDownloadedNotificationName, object: nil)
        }
    }
    
    deinit{if waitingForDownload {NSNotificationCenter.defaultCenter().removeObserver(self)}}
    
}

