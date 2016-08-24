//
//  IATextAttachment.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/6/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/**
IATextAttachment is a subclass of NSTextAttachment providing thumbnails of various sizes for files which are cached in the cases of files with names (via the NSFileWrapper). The IATextAttachment uses the preferedThumbSize property of the IATextContainer passed in via its NSTextAttachmentContainer functions in order to provide one of a few fixed sizes and placeholders. By forcing fixed sizes predetermined by the IACompositeBase derived class (and passed through the IATextContainer), the layout can be calculated (using attachmentBoundsForTextContainer) without needing access to the image data which may be either slow or not present. The actual drawing of the text can likewise occur more quickly since imageForBounds will return nil, causing the ThinTextView layers to draw empty rects over which the IAImageLayerView will later (and possibly asynchrounously) draw the image. This not only allows us to animate the opacity of the text layers without affecting the images, but it also improves drawing performance immensely compared to the conventional out of the box methods.
*/
public class IATextAttachment:NSTextAttachment {
    

    ///Either filename or random alpha string (if no filename exists) used for identifying attachments and images with or without filenames
    public lazy var localID:String = {return self.filename ?? String.randomAlphaString(8)}()
    
    public var isPlaceholder:Bool {
        return self.fileWrapper == nil && self.contents == nil && self.image == nil
    }
    
    
    public var filename:String?
    public var remoteFileURL:NSURL?
    public var localFileURL:NSURL?

    private static let thumbCache = NSCache()
    //public static let placeholderImage = UIImage(named: "imagePlaceholder", inBundle: IAKitPreferences.bundle, compatibleWithTraitCollection: nil)!
    

    
    
    private var wrappedFileName:String? {return self.fileWrapper?.preferredFilename}
    
    override public var image:UIImage? {
        get{
            if let supImage = super.image {
                return supImage
            } else {
                return wrappedImage
            }
        }
        set{
            super.image = newValue
            _storedContentSize = super.image?.size
        }
    }
    
    private var wrappedImage:UIImage? {
        let wrappedName:String? = wrappedFileName != nil ? wrappedFileName! + "-full" : nil
        if wrappedName != nil {
            if let cached = IATextAttachment.thumbCache.objectForKey(wrappedName!) as? UIImage{
                return cached
            }
        }
        if let wrappedData = self.fileWrapper?.regularFileContents {
            if let newImage = UIImage(data: wrappedData) {
                if wrappedName != nil {
                    IATextAttachment.thumbCache.setObject(newImage, forKey: wrappedName!)
                }
                return newImage
            }
        }
        return nil
    }
    
    ///saves the value so it doesn't need to be repeatedly recalculated
    private var _storedContentSize:CGSize?
    var storedContentSize:CGSize? {
        if let existing = _storedContentSize {
            return existing
        } else if let size = wrappedImage?.size {
            _storedContentSize = size
            return size
        } else if let size = self.image?.size {
            _storedContentSize = size
            return size
        }
        return nil
    }
    
    ///Yields the attachment data by trying first the filewrapper, then the contents, and finally the image property
    public var underlyingData:NSData? {
        if let wrappedData = self.fileWrapper?.regularFileContents {
            return wrappedData
        } else if let imageData = self.contents {
            return imageData
        } else if image != nil {
            return UIImageJPEGRepresentation(image!, 1.0)
        }
        return nil
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
        return image?.resizeImageToFit(maxSize: thumbSize.size) ?? IAPlaceholder.forSize(thumbSize, attachType: .image)
    }
    
    
    override public func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        let sug = super.attachmentBoundsForTextContainer(textContainer!, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
        if let iaContainer = textContainer as? IATextContainer {
            return CGRect(origin:CGPointZero,size:iaContainer.preferedThumbSize.size)
        } else {
            return CGRect(origin:CGPointZero,size:IAThumbSize.Tiny.size)
        }
        //return CGRect(origin:CGPointZero,size:self.thumbSize.size)
    }
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let localID = aDecoder.decodeObjectForKey("localID") as? String {
            self.localID = localID
        }

        if let height = aDecoder.decodeObjectForKey("storedHeight") as? Float, width = aDecoder.decodeObjectForKey("storedWidth") as? Float{
            self._storedContentSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        if let fn = aDecoder.decodeObjectForKey("filename") as? String {self.filename = fn}
        if let localURL = aDecoder.decodeObjectForKey("localURL") as? NSURL {self.localFileURL = localURL}
        if let remoteURL = aDecoder.decodeObjectForKey("remoteURL") as? NSURL {self.remoteFileURL = remoteURL}
        
        
        if self.isPlaceholder {
            self.attemptToRealizeFileWrapper()
        }
        
    }
   
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)

        aCoder.encodeObject(localID, forKey: "localID")
        aCoder.encodeBool(self.isPlaceholder, forKey: "isPlaceholder")
        if let siSize = self._storedContentSize {
            
            aCoder.encodeFloat(Float(siSize.height), forKey: "storedHeight")
            aCoder.encodeFloat(Float(siSize.width), forKey: "storedWidth")
        }
        aCoder.encodeObject(self.filename, forKey: "filename")
        aCoder.encodeObject(self.remoteFileURL, forKey: "remoteURL")
        aCoder.encodeObject(self.localFileURL, forKey: "localFileURL")
        
    }
    
    
    override init(data contentData: NSData?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
        
    }
    
    
    ///Attempts to load filewrapper contents
    public func attemptToRealizeFileWrapper()->Bool{
//        if let localURL = self.localFileURL {
//            if let wrapper = try? NSFileWrapper(URL: localURL, options: []) {
//                self.fileWrapper = wrapper
//                return true
//            }
//        }
        return false
    }
    
    public init(filename:String,remoteURL:NSURL,localURL:NSURL?){
        super.init(data: nil, ofType: nil)
        self.filename = filename
        self.remoteFileURL = remoteURL
        self.localFileURL = localURL
        attemptToRealizeFileWrapper()
    }
        
}


extension IATextAttachment {
    override public var debugDescription:String {
        return "<IATextAttachment>: filename: \(self.filename ?? "nil"), remoteFileURL:\(self.remoteFileURL ?? "nil"), localFileURL: \(self.localFileURL ?? "nil"), isPlaceholder:\(self.isPlaceholder)"
    }
}

public enum IAAttachmentType:String {
    case image = "image",
    video = "video",
    location = "location",
    unknown = "unknown"
    
}




