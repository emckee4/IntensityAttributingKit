//
//  IATextAttachment.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/6/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/**
IATextAttachment is a subclass of NSTextAttachment providing thumbnails of various sizes for files which are cached in the cases of files with names (via the NSFileWrapper).
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

    
    public var thumbSize: ThumbSize = .Medium
    
    private static let thumbCache = NSCache()
    //public static let placeholderImage = UIImage(named: "imagePlaceholder", inBundle: IAKitOptions.bundle, compatibleWithTraitCollection: nil)!
    

    
    
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
        guard !isPlaceholder && thumbSize == .Medium else {return self.thumbSize.imagePlaceholder}
        var cachedThumbName:String! = nil
        if  filename != nil {
            cachedThumbName = filename! + thumbSize.rawValue
        } else {
            cachedThumbName = localID + thumbSize.rawValue
        }
        if let cachedImage = IATextAttachment.thumbCache.objectForKey(cachedThumbName) as? UIImage {
            return cachedImage
        } else if let newThumb = super.imageForBounds(imageBounds, textContainer: textContainer, characterIndex: charIndex) {
            IATextAttachment.thumbCache.setObject(newThumb, forKey: cachedThumbName)
            return newThumb
        } else {
            return nil
        }
    }
    
    override public func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        return CGRect(origin:CGPointZero,size:self.thumbSize.size)
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
    
    
    
//    public init(){
//        super.init(data: nil, ofType: nil)
//        usePlaceholderImage()
//    }
    
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


extension IATextAttachment: CustomDebugStringConvertible{
    override public var debugDescription:String {
        return "<IATextAttachment>: filename: \(self.filename ?? "nil"), remoteFileURL:\(self.remoteFileURL ?? "nil"), localFileURL: \(self.localFileURL ?? "nil"), isPlaceholder:\(self.isPlaceholder)"
    }
}




public enum ThumbSize:String {
    case Tiny = "Tiny",
    Small = "Small",
    Medium = "Medium"
    
    public var size: CGSize {
        switch self {
        case .Tiny: return CGSizeMake(32, 32)
        case .Small: return CGSizeMake(64, 64)
        case .Medium: return CGSizeMake(160, 160)
        }
    }
    
    
    
    var imagePlaceholder:UIImage!{
        guard NSThread.isMainThread() else {return nil}
        switch self {
        case .Tiny: return ThumbSize.Placeholders.ImageBoxedTiny
        case .Small: return ThumbSize.Placeholders.ImageBoxedSmall
        case .Medium: return ThumbSize.Placeholders.ImageBoxedMedium
        }
    }
    
    
    struct Placeholders {
        static let ImageBoxedTiny = {
            return UIImage(named: "imagePlaceholderBoxedTiny", inBundle: IAKitOptions.bundle, compatibleWithTraitCollection: UIScreen.mainScreen().traitCollection)!
        }()
        static let ImageBoxedSmall = {
            return UIImage(named: "imagePlaceholderBoxedSmall", inBundle: IAKitOptions.bundle, compatibleWithTraitCollection: UIScreen.mainScreen().traitCollection)!
        }()
        static let ImageBoxedMedium = {
            return UIImage(named: "imagePlaceholderBoxedMedium", inBundle: IAKitOptions.bundle, compatibleWithTraitCollection: UIScreen.mainScreen().traitCollection)!
        }()
    }

    
}





