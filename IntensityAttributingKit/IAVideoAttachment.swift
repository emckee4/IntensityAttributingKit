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
open class IAVideoAttachment:IATextAttachment {
  
    ///Either filename or random alpha string (if no filename exists) used for identifying attachments and images with or without filenames
    fileprivate lazy var _localID:String = {return self.videoFilename ?? self.temporaryVideoURL?.lastPathComponent ?? String.randomAlphaString(8)}()
    override open var localID:String {
        get {return _localID}
        set {_localID = newValue}
    }
    
    override open var attachmentType:IAAttachmentType {
        return .video
    }
    
    override open var showingPlaceholder:Bool {
        return self.previewImage == nil
    }
    
    
    open var videoFilename:String?
    ///We retain the reference to the remote location but leave management of the download to the app adopting the framework
    open var remoteVideoURL:URL?
    ///It's expected that the localFileURL will be fully determined by the filename, i.e. the url will be <some constant path> + <filename>. The localFileURL does not need to be valid yet, but it should point to the eventual location of the downloaded file
    open var localVideoURL:URL?
    open var temporaryVideoURL:URL?
    
    open var previewFilename:String?
    open var remotePreviewURL:URL?
    open var localPreviewURL:URL?
    
    open var temporaryPreviewURL:URL?
    
    fileprivate(set) open var previewImage:UIImage?
    ///saves the value so it doesn't need to be repeatedly recalculated
    fileprivate(set) open var storedContentSize:CGSize?
    
    ///When true this object is waiting for content to be downloaded and is observing the notifications for video content
    fileprivate(set) open var waitingForDownload:Bool = false
    
    init!(withTemporaryFileLocation loc: URL){
        self.temporaryVideoURL = loc
        super.init(data: nil, ofType: nil)
        self.previewImage = generatePreview(temporaryVideoURL!)
    }
    
    public init(videoFilename:String,remoteVideoURL:URL,localVideoURL:URL?,previewFilename:String,remotePreviewURL:URL,localPreviewURL:URL?){
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
        if let localID = aDecoder.decodeObject(forKey: "localID") as? String {
            self.localID = localID
        }
        
        if let height = aDecoder.decodeObject(forKey: "storedHeight") as? Float, let width = aDecoder.decodeObject(forKey: "storedWidth") as? Float{
            self.storedContentSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        if let vfn = aDecoder.decodeObject(forKey: "videoFilename") as? String {self.videoFilename = vfn}
        if let localVidURL = aDecoder.decodeObject(forKey: "localVideoURL") as? URL {self.localVideoURL = localVidURL}
        if let remoteVidURL = aDecoder.decodeObject(forKey: "remoteVideoURL") as? URL {self.remoteVideoURL = remoteVidURL}
        
        if let previewfn = aDecoder.decodeObject(forKey: "previewFilename") as? String {self.previewFilename = previewfn}
        if let localPreviewURL = aDecoder.decodeObject(forKey: "localPreviewURL") as? URL {self.localPreviewURL = localPreviewURL}
        if let remotePreviewURL = aDecoder.decodeObject(forKey: "remotePreviewURL") as? URL {self.remotePreviewURL = remotePreviewURL}
        
        if localVideoURL == nil, let tempVideoURL = aDecoder.decodeObject(forKey: "temporaryVideoURL") as? URL {self.temporaryVideoURL = tempVideoURL}
        if localPreviewURL == nil, let tempPreviewURL = aDecoder.decodeObject(forKey: "temporaryPreviewURL") as? URL {self.temporaryPreviewURL = tempPreviewURL}
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(localID, forKey: "localID")
        if let siSize = self.storedContentSize {
            aCoder.encode(Float(siSize.height), forKey: "storedHeight")
            aCoder.encode(Float(siSize.width), forKey: "storedWidth")
        }
        aCoder.encode(self.videoFilename, forKey: "videoFilename")
        aCoder.encode(self.remoteVideoURL, forKey: "remoteVideoURL")
        aCoder.encode(self.localVideoURL, forKey: "localVideoURL")
        
        aCoder.encode(self.previewFilename, forKey: "previewFilename")
        aCoder.encode(self.remotePreviewURL, forKey: "remotePreviewURL")
        aCoder.encode(self.localPreviewURL, forKey: "localPreviewURL")
        
        if self.localVideoURL == nil {
            aCoder.encode(self.temporaryVideoURL, forKey: "temporaryVideoURL")
        }
        if self.localPreviewURL == nil {
            aCoder.encode(self.temporaryPreviewURL, forKey: "temporaryPreviewURL")
        }
    }
    
    override func imageForThumbSize(_ thumbSize:IAThumbSize)->UIImage?{
        let cachingName = thumbCatchName(forSize: thumbSize)
        if let thumb = IATextAttachment.thumbCache.object(forKey: cachingName as AnyObject) as? UIImage {
            return thumb
        } else if previewImage != nil {
            //let thumb = previewImage!.resizeImageToFit(maxSize: thumbSize.size)
            let thumb = previewImage!.resizeImageWithScaleAspectFit(thumbSize.size,backgroundColor: UIColor.black)
            IATextAttachment.thumbCache.setObject(thumb, forKey: cachingName as AnyObject)
            return thumb
        }
        return nil
    }
    

    ///Generates a screen shot from the start of the video. This should also set the storedContentSize with the appropriate transform applied.
    func generatePreview(_ videoURL:URL)->UIImage{
        let asset = AVAsset(url: videoURL)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.appliesPreferredTrackTransform = true
        
        if let preview = try? assetGenerator.copyCGImage(at: CMTimeMake(1, 4), actualTime: nil){
            let uiPreview = UIImage(cgImage: preview)
            storedContentSize = CGSize(width: uiPreview.size.width * uiPreview.scale, height: uiPreview.size.height * uiPreview.scale)
            return uiPreview
        } else {
            storedContentSize = asset.tracks.first?.naturalSize ?? CGSize(width: 320, height: 320)
            UIGraphicsBeginImageContextWithOptions(storedContentSize!, true, 1.0)
            let blankPreview = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            return blankPreview!
        }
    }
    
    
    
    ///This only checks/attempts to load the preview.
    open override func attemptToLoadResource() -> Bool {
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
    
    
    override open var description: String {
        return "<IAVideoAttachment>: id \(localID)"
    }
    
    override open var debugDescription:String {
        return "<IAVideoAttachment>: videoFilename: \(self.videoFilename ?? "nil"), remoteVideoURL:\(self.remoteVideoURL?.absoluteString ?? "nil"), localVideoURL: \(self.localVideoURL?.absoluteString ?? "nil"), isPlaceholder:\(self.showingPlaceholder)"
    }

    
    ///Sent by the app's download manager to the IAVideoAttachments to indicate that preview content has been downloaded. The user info will provide identifying information including resourceName.
    open static let videoPreviewDownloadedNotificationName:String = "IntensityAttributingKit.IAVideoAttachment.PreviewReady"
    
    ///Used by the download manager of the app to indicate that the resource is available or that the download has failed.
    open static func emitContentDownloadedNotification(_ videoPreviewFilename:String, localFileLocation:URL!, previewImage:UIImage?, downloadError:NSError?){
        var userInfo:[String:AnyObject] = ["videoPreviewFilename":videoPreviewFilename as AnyObject]
        if previewImage != nil {
            userInfo["previewImage"] = previewImage!
        }
        if localFileLocation != nil {
            userInfo["localFileLocation"] = localFileLocation as AnyObject?
        }
        if downloadError != nil {
            userInfo["downloadError"] = downloadError!
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: videoPreviewDownloadedNotificationName), object: nil, userInfo: userInfo)
    }
    
    func handlePreviewDownloadedNotification(_ notification:Notification!){
        guard let filename = notification.userInfo?["videoPreviewFilename"] as? String, self.previewFilename != nil && filename == self.previewFilename! else {return}
        NotificationCenter.default.removeObserver(self, forKeyPath: IAVideoAttachment.videoPreviewDownloadedNotificationName)
        waitingForDownload = false
        
        guard notification.userInfo?["downloadError"] == nil else {return}
        
        if self.localPreviewURL == nil {
            self.localPreviewURL = notification.userInfo?["localFileLocation"] as? URL
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
    open func setWaitForDownload(){
        guard self.previewFilename != nil else {return}
        if !waitingForDownload {
            waitingForDownload = true
            NotificationCenter.default.addObserver(self, selector: #selector(IAVideoAttachment.handlePreviewDownloadedNotification(_:)), name: NSNotification.Name(rawValue: IAVideoAttachment.videoPreviewDownloadedNotificationName), object: nil)
        }
    }
    
    deinit{if waitingForDownload {NotificationCenter.default.removeObserver(self)}}
    
}

