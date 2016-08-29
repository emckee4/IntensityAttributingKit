//
//  IALocationAttachment.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/26/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation



/** Concrete subclass of IATextAttachment for handling location attachments. See discussion in comments of IATextAttachment for more info on why this is constructed this way.
 */
public class IALocationAttachment:IATextAttachment {} /*
    
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
    
    
    public override func imageForBounds(imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
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
    
    
    override public func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        if let iaContainer = textContainer as? IATextContainer {
            return CGRect(origin:CGPointZero,size:iaContainer.preferedThumbSize.size)
        } else {
            return CGRect(origin:CGPointZero,size:IAThumbSize.Tiny.size)
        }
    }
    
    public override func checkResourceAvailable() -> Bool {
        return self.image != nil
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
    
    override public var description: String {
        return "<IAImageAttachment>: id \(localID), imageLoaded? \(_image != nil)"
    }
    
    override public var debugDescription:String {
        return "<IAImageAttachment>: filename: \(self.filename ?? "nil"), remoteFileURL:\(self.remoteFileURL ?? "nil"), localFileURL: \(self.localFileURL ?? "nil"), isPlaceholder:\(self.showingPlaceholder)"
    }
    
}
 */