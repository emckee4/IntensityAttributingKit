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
    
    private static let thumbCache = NSCache()
    public static let placeholderImage = UIImage(named: "imagePlaceholder", inBundle: IAKitOptions.bundle, compatibleWithTraitCollection: nil)!
    
    public private(set) var isPlaceholder = false
    
    var filewrapper:NSFileWrapper? {
        didSet{
            ///could load image in background and generate thumbs
            _storedImageSize = nil
        }
    }
    
    public var thumbSize: ThumbSize = .Medium
    
    
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
            if super.image != nil {
                isPlaceholder = false
            }
            _storedImageSize = super.image?.size
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
    private var _storedImageSize:CGSize?
    var storedImageSize:CGSize? {
        if let existing = _storedImageSize {
            return existing
        } else if let size = self.image?.size {
            _storedImageSize = size
            return size
        }
        return nil
    }
    
    public func usePlaceholderImage() {
        isPlaceholder = true
    }
    
    override public func imageForBounds(imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        guard !isPlaceholder else {return IATextAttachment.placeholderImage}
        guard let newSize = storedImageSize?.sizeThatFitsMaintainingAspect(containerSize:imageBounds.size ) else {return nil}
        var cachedThumbName:String? = nil
        if  wrappedFileName != nil {
            cachedThumbName = wrappedFileName! + thumbSize.rawValue
        }
        if cachedThumbName != nil {
            if let cachedThumb = IATextAttachment.thumbCache.objectForKey(cachedThumbName!) as? UIImage{
                return cachedThumb
            }
        }
        
        if let newThumb = self.image?.resizeImageToFit(maxSize: newSize) {
            if cachedThumbName != nil {
                IATextAttachment.thumbCache.setObject(newThumb, forKey: cachedThumbName!)
            }
            return newThumb
        }
        return super.imageForBounds(imageBounds, textContainer: textContainer, characterIndex: charIndex)
    }
    
    override public func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
//        return CGRectMake(0, 0, 150, 150)
        //let maxThumbSize = IAKitOptions.singleton.maxThumbnailSize
        let maxThumbSize = self.thumbSize.size
        
        let thumbSize = storedImageSize?.sizeThatFitsMaintainingAspect(containerSize: maxThumbSize)
        if let thumbSize = thumbSize {return CGRect(origin: CGPointZero, size: thumbSize)}
//        if let newSize = thumbSize?.sizeThatFitsMaintainingAspect(containerSize: lineFrag.size) {
//            return CGRect(origin: CGPointZero, size: newSize)
//        }
        return super.attachmentBoundsForTextContainer(textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
    }
    
}

public enum ThumbSize:String {
    case Tiny = "Tiny",
    Small = "Small",
    Medium = "Medium"
    
    var size: CGSize {
        switch self {
        case .Tiny: return CGSizeMake(30, 30)
        case .Small: return CGSizeMake(70, 70)
        case .Medium: return CGSizeMake(150, 150)
        }
    }
    
}

