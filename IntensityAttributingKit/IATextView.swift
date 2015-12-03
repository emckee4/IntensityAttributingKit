//
//  IATextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

public class IATextView: UITextView {
    
    
    var currentTransformer:IntensityTransformers!
    
    ///display max size for images displayed in text
    var preferedImageDisplaySize:CGSize {
        //checking against these minimum bounds sizes is a workable proxy to determine if the view has been setup properly in the view hierarchy
        if self.bounds.width > 20.0 && self.bounds.height > 10.0 {
            let sideDimension = max(self.bounds.width,self.bounds.height) / 2.0
            return CGSizeMake(sideDimension, sideDimension)
        } else {
            return CGSizeMake(150.0, 150.0)
        }
    }

    
    
    //MARK:-inits and setup
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPressureTextView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPressureTextView()
    }
    
    
    func setupPressureTextView(){
        self.editable = false
        self.layer.cornerRadius = 10.0
        self.textContainerInset = UIEdgeInsetsMake(7.0, 2.0, 7.0, 2.0)
    }
    
    
    ///Prefered method for setting stored IAText for display. By default this assumes text has been prerendered and only needs bounds set on its images. If needsRendering is set as true then this will render according to whatever its included schemeName is.
    public func setIAText(iaText:NSAttributedString, needsRendering:Bool = false){
        //get default rendering from iaText and set that for this instance
        guard let textTransformer = IntensityTransformers(rawValue: ((iaText.attribute(IATags.IAKeys, atIndex: 0, effectiveRange: nil) as? [String:AnyObject])?[IATags.IACurrentRendering] as? String) ?? "") else {return}
        self.currentTransformer = textTransformer
        //render if necessary
        let renderedIAText = needsRendering ? iaText.transformWithRenderScheme(currentTransformer) : iaText
        //if attachments then size them for display
        renderedIAText.setMaxSizeForAllAttachments(preferedImageDisplaySize)
        self.attributedText = renderedIAText
    }
    
    
    //MARK:- Copy
    
    override public func copy(sender: AnyObject?){
        super.copy()
        let pb = UIPasteboard.generalPasteboard()
        let pbDict = pb.items.first as! NSMutableDictionary
        
        let copiedText = attributedText.attributedSubstringFromRange(selectedRange)
        let archive = NSKeyedArchiver.archivedDataWithRootObject(copiedText)
        pbDict.setValue(archive, forKey: UTITypes.IntensityArchive)
        pb.items[0] = pbDict
    }

     

    struct UTITypes {
        static let PlainText = "public.utf8-plain-text"
        static let RTFD = "com.apple.flat-rtfd"
        static let IntensityArchive = "com.mckeemaker.IntensityAttributedTextArchive"
    }
    
}






