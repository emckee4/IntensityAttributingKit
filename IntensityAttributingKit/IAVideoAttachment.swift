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
    private lazy var _localID:String = {return self.videoFilename ?? String.randomAlphaString(8)}()
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
            return blankPreview
        }
    }
    
    
    
    ///This needs to be properly implemented
    public override func checkResourceAvailable() -> Bool {
        return self.localVideoURL != nil
    }
    
    
    override public var description: String {
        return "<IAVideoAttachment>: id \(localID)"
    }
    
    override public var debugDescription:String {
        return "<IAVideoAttachment>: videoFilename: \(self.videoFilename ?? "nil"), remoteVideoURL:\(self.remoteVideoURL ?? "nil"), localVideoURL: \(self.localVideoURL ?? "nil"), isPlaceholder:\(self.showingPlaceholder)"
    }

}

