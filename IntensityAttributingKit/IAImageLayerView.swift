//
//  IAImageLayerView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 5/22/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

class IAImageLayerView: UIView {

    var imageViewForId:[String:UIImageView] = [:]
    
    var useThumbSize:ThumbSize = .Medium

    
    ///Called after the layout manager has processed changes, this will check the iaString for undisplayed images and update as needed.
    func imagesWereChanged(inIAString iaString:IAString, layoutManager:NSLayoutManager){
        let oldImageIDs = Set<String>(imageViewForId.keys)
        let newImageIDs = Set<String>(iaString.attachments.map({$0.attach.localID}))

        //need to remove unused imageViews
        let ntr = oldImageIDs.subtract(newImageIDs)
        for name in ntr {
            self.removeImage(name)
        }
            
        let nta = newImageIDs.subtract(oldImageIDs)
        for name in nta {
            var index:Int!
            for (loc,attach) in iaString.attachments{
                if attach.localID == name {
                    index = loc
                    break
                }
            }
            self.addImage( index, iaString: iaString, layoutManager: layoutManager)
        }
        

        if nta.isEmpty && ntr.isEmpty {
            repositionImageViews(iaString, layoutManager: layoutManager)
            return
        }
    }
    
    func redrawImage(imageCharIndex:Int, iaString:IAString, layoutManager:NSLayoutManager){
        //relate the index to a localID,
        guard let attachment = iaString.attachments[imageCharIndex] else {print("IAImageLayerView. redrawImage: couldnt find attachment at charIndex \(imageCharIndex)");return}
        guard let iv = imageViewForId[attachment.localID] else {print("IAImageLayerView. redrawImage: couldnt find iv for localID \(attachment.localID)");return}
        iv.image = attachment.imageForThumbSize(self.useThumbSize)
        let gr = layoutManager.glyphRangeForCharacterRange(NSMakeRange(imageCharIndex, 1), actualCharacterRange: nil)
        iv.frame = layoutManager.boundingRectForGlyphRange(gr, inTextContainer: layoutManager.textContainers.first!)
    }
    
    
    func repositionImageViews(iaString:IAString, layoutManager:NSLayoutManager){
        for (charIndex,attachment) in iaString.attachments {
            if let iv = imageViewForId[attachment.localID] {
                let gr = layoutManager.glyphRangeForCharacterRange(NSMakeRange(charIndex, 1), actualCharacterRange: nil)
                iv.frame = layoutManager.boundingRectForGlyphRange(gr, inTextContainer: layoutManager.textContainers.first!)
            }
        }
    }
    
    
    private func addImage(atIAStringIndex:Int, iaString:IAString, layoutManager:NSLayoutManager){
        guard let attachment = iaString.attachments[atIAStringIndex] else {print("IAImageLayerView. addImage: couldnt find attachment at charIndex \(atIAStringIndex)");return}
        let gr = layoutManager.glyphRangeForCharacterRange(NSMakeRange(atIAStringIndex, 1), actualCharacterRange: nil)

        let iv = UIImageView(frame: layoutManager.boundingRectForGlyphRange(gr, inTextContainer: layoutManager.textContainers.first!))
        iv.image = attachment.imageForThumbSize(self.useThumbSize)
        imageViewForId[attachment.localID] = iv
        self.addSubview(iv)
        
    }
    
    
    private func removeImage(imageLocalID:String){
        guard let iv = imageViewForId.removeValueForKey(imageLocalID) else {print("IAImageLayerView. removeImage: couldnt find iv for localID \(imageLocalID)");return}
//        iv.hidden = true
//        iv.image = nil
        iv.removeFromSuperview()
        
    }

    
    
    
}



/*
     func refreshImageLayer(){
        guard iaString.attachmentCount > 0 else {imageLayer.hidden = true; return}
        if imageLayer.hidden {imageLayer.hidden = false}
        if imageLayerImageViews.count < iaString.attachmentCount {
            for _ in 0..<(iaString.attachmentCount - imageLayerImageViews.count){
                let newImageView = UIImageView(frame: CGRectZero)
                newImageView.translatesAutoresizingMaskIntoConstraints = false
                imageLayerImageViews.append(newImageView)
                imageLayer.addSubview(newImageView)
            }
        }
        for (i ,locAttach) in iaString.attachments.enumerate() {
            imageLayerImageViews[i].hidden = false
            let (location, attachment) = locAttach
            let attachRect = topTV.layoutManager.boundingRectForGlyphRange(NSMakeRange(location, 1), inTextContainer: topTV.textContainer)
            imageLayerImageViews[i].frame = attachRect
            imageLayerImageViews[i].image = ThumbSize.Medium.imagePlaceholder//attachment.imageForThumbSize(self.thumbSizesForAttachments)
        }
        if iaString.attachmentCount < imageLayerImageViews.count {
            for i in (iaString.attachmentCount)..<(imageLayerImageViews.count){
                imageLayerImageViews[i].image = nil
                imageLayerImageViews[i].hidden = true
            }
        }
    }
    
    ///If bounds change but images do not need to be reloaded then this can be called as a more efficient alternative to refreshImageLayer.
    func repositionImageViews(){
        guard imageLayerImageViews.count >= iaString.attachmentCount else {refreshImageLayer();return}
        for (i ,locAttach) in iaString.attachments.enumerate() {
            let (location, _) = locAttach
            let attachRect = topTV.layoutManager.boundingRectForGlyphRange(NSMakeRange(location, 1), inTextContainer: topTV.textContainer)
            imageLayerImageViews[i].frame = attachRect
        }
    }
 
 */