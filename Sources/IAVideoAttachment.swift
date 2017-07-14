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
    fileprivate lazy var _localID:String = {
        if let fn = self.videoFilename as NSString?{
            if (fn.pathExtension as NSString).length < 5 {
                return fn.deletingPathExtension as String
            } else {
                return self.videoFilename!
            }
        } else if let fn = self.temporaryVideoURL?.deletingPathExtension().lastPathComponent {
            return fn
        } else {
            return String.randomAlphaString(8)
        }
    }()
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
    open var localVideoURL:URL? {
        guard let fn = videoFilename else {return nil}
        return IAKitPreferences.videoDirectory?.appendingPathComponent(fn)
    }
    open var temporaryVideoURL:URL?
    
    open var previewFilename:String?
    open var remotePreviewURL:URL?
    open var localPreviewURL:URL? {
        guard let fn = previewFilename else {return nil}
        return IAKitPreferences.videoPreviewDirectory?.appendingPathComponent(fn)
    }
    
    open var temporaryPreviewURL:URL?
    
    public var bestURLForWatchingVideo:URL? {
        if let localURL = self.localVideoURL, (try? localURL.checkResourceIsReachable()) ?? false {
            return localURL
        } else if let localTempURL = self.temporaryVideoURL, (try? localTempURL.checkResourceIsReachable()) ?? false {
            return localTempURL
        } else if let remoteURL = self.remoteVideoURL {
            return remoteURL
        }
        return nil
    }
    
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
    
    public init(videoFilename:String,remoteVideoURL:URL,previewFilename:String,remotePreviewURL:URL){
        super.init(data: nil, ofType: nil)
        self.videoFilename = videoFilename
        self.remoteVideoURL = remoteVideoURL
        self.previewFilename = previewFilename
        self.remotePreviewURL = remotePreviewURL
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
        if let remoteVidURL = aDecoder.decodeObject(forKey: "remoteVideoURL") as? URL {self.remoteVideoURL = remoteVidURL}
        
        if let previewfn = aDecoder.decodeObject(forKey: "previewFilename") as? String {self.previewFilename = previewfn}
        if let remotePreviewURL = aDecoder.decodeObject(forKey: "remotePreviewURL") as? URL {self.remotePreviewURL = remotePreviewURL}
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
        
        aCoder.encode(self.previewFilename, forKey: "previewFilename")
        aCoder.encode(self.remotePreviewURL, forKey: "remotePreviewURL")
        
    }
    
    override func imageForThumbSize(_ thumbSize:IAThumbSize)->UIImage?{
        let cachingName = thumbCatchName(forSize: thumbSize) as NSString
        if let thumb = IATextAttachment.thumbCache.object(forKey: cachingName) as? UIImage {
            return thumb
        } else if previewImage != nil {
            //let thumb = previewImage!.resizeImageToFit(maxSize: thumbSize.size)
            let thumb = previewImage!.resizeImageWithScaleAspectFit(thumbSize.size,backgroundColor: UIColor.black)
            IATextAttachment.thumbCache.setObject(thumb, forKey: cachingName)
            return thumb
        } else if localPreviewURL != nil, let image = UIImage(contentsOfFile: localPreviewURL!.path) {
            previewImage = image
            let thumb = previewImage!.resizeImageWithScaleAspectFit(thumbSize.size,backgroundColor: UIColor.black)
            IATextAttachment.thumbCache.setObject(thumb, forKey: cachingName)
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
    open static let videoPreviewDownloadedNotificationName:NSNotification.Name = NSNotification.Name(rawValue:"IntensityAttributingKit.IAVideoAttachment.PreviewReady")
    
    ///Used by the download manager of the app to indicate that the resource is available or that the download has failed.
    open static func emitContentDownloadedNotification(_ videoPreviewFilename:String, previewImage:UIImage?, downloadError:NSError?){
        var userInfo:[String:Any] = ["videoPreviewFilename":videoPreviewFilename]
        if previewImage != nil {
            userInfo["previewImage"] = previewImage!
        }
        if downloadError != nil {
            userInfo["downloadError"] = downloadError!
        }
        NotificationCenter.default.post(name: videoPreviewDownloadedNotificationName, object: nil, userInfo: userInfo)
    }
    
    func handlePreviewDownloadedNotification(_ notification:Notification!){
        guard let filename = notification.userInfo?["videoPreviewFilename"] as? String, self.previewFilename != nil && filename == self.previewFilename! else {return}
        guard notification.userInfo?["downloadError"] == nil else {return}
        
        if let image = notification.userInfo?["previewImage"] as? UIImage {
            previewImage = image
            self.emitContentReadyNotification(nil)
            NotificationCenter.default.removeObserver(self, name: IAVideoAttachment.videoPreviewDownloadedNotificationName, object: nil)
            waitingForDownload = false
        } else if let path = self.localPreviewURL?.path {
            if let image = UIImage(contentsOfFile: path){
                previewImage = image
                self.emitContentReadyNotification(nil)
                NotificationCenter.default.removeObserver(self, name: IAVideoAttachment.videoPreviewDownloadedNotificationName, object: nil)
                waitingForDownload = false
            }
        }
        
    }
    
    ///Can be set by the download manager to cause the attachment to begin observing for download completion. This will prevent the attachment from requesting downloads. Filename must not be nil or this will have no effect.
    open func setWaitForDownload(){
        guard self.previewFilename != nil else {return}
        if !waitingForDownload {
            waitingForDownload = true
            NotificationCenter.default.addObserver(self, selector: #selector(IAVideoAttachment.handlePreviewDownloadedNotification(_:)), name: IAVideoAttachment.videoPreviewDownloadedNotificationName, object: nil)
        }
    }
    
    deinit{if waitingForDownload {NotificationCenter.default.removeObserver(self)}}
    
}

