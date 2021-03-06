//
//  IAImageLayerView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 5/22/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit
/**
 IAImageLayerView sits within the IACompositeBase derived view above the text layers but beneath the selection layer. It provides the actual display of images as layed out by the topTV layoutManager with which it interacts under the direction of the IACompositeBase derived view. This arrangement allows some flexibility in the rendering process and minimizes the number of times that the image data needs to be accessed or drawn (in the stages performed by the CPU at least), at the cost of further compositing work for the GPU. Separating the images from the text layers also allows us to vary the text layer opacity for the purposes of animation without affecting the images.
 */

class IAImageLayerView: UIView {

    var imageViewForId:[String:UIImageView] = [:]
    
    ///The IAImageLayerView will use one size (determined here using the IAThumbSize enum) for drawing all attachments and their placeholders in the IA view. This greatly simplifies the sizing calculations for the view while also simplifying caching.
    var useThumbSize:IAThumbSize = .Medium

    
    ///Called after the layout manager has processed changes, this will check the iaString for changes in the number, position, or id of attachments associated with the IAString, adding, removing, and repositioning them as necessary.
    func imagesWereChanged(inIAString iaString:IAString, layoutManager:NSLayoutManager){
        let oldImageIDs = Set<String>(imageViewForId.keys)
        let newImageIDs = Set<String>(iaString.attachments.map({$0.attach.localID}))

        //need to remove unused imageViews
        let ntr = oldImageIDs.subtracting(newImageIDs)
        for name in ntr {
            self.removeImage(name)
        }
            
        let nta = newImageIDs.subtracting(oldImageIDs)
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
        

        if newImageIDs.subtracting(nta).isEmpty == false{
            repositionImageViews(iaString, layoutManager: layoutManager)
            return
        }
    }
    
    ///Redraws the thumbnail for the attachment if it has already been layed out. If an image view hasn't yet been created for the attachment then the ordinary layout process should use the newest image data when it draws its content.
    func redrawImage(inAttachment attachment:IATextAttachment){
        if imageViewForId.keys.contains(attachment.localID) {
            imageViewForId[attachment.localID]?.image = attachment.imageForThumbSize(self.useThumbSize) ?? IAPlaceholder.forSize(self.useThumbSize, attachType: attachment.attachmentType)
        }
    }
    
    ///Called to redraw a specfic attachment at a specific character index in the IAString. This would typically be called when new data becomes available (e.g. an image download has completed) that should replace the prior content of that attachment view (possibly a placeholder).
    func redrawImage(_ imageCharIndex:Int, iaString:IAString, layoutManager:NSLayoutManager){
        //relate the index to a localID,
        guard let attachment = iaString.attachments[imageCharIndex] else {print("IAImageLayerView. redrawImage: couldnt find attachment at charIndex \(imageCharIndex)");return}
        guard let iv = imageViewForId[attachment.localID] else {print("IAImageLayerView. redrawImage: couldnt find iv for localID \(attachment.localID)");return}
        iv.image = attachment.imageForThumbSize(self.useThumbSize) ?? IAPlaceholder.forSize(self.useThumbSize, attachType: attachment.attachmentType)
        let gr = layoutManager.glyphRange(forCharacterRange: NSMakeRange(imageCharIndex, 1), actualCharacterRange: nil)
        iv.frame = layoutManager.boundingRect(forGlyphRange: gr, in: layoutManager.textContainers.first!)
    }
    
    ///Called when the layout of images may have changed but the number and content haven't. This will move their frames around as needed.
    func repositionImageViews(_ iaString:IAString, layoutManager:NSLayoutManager){
        for (charIndex,attachment) in iaString.attachments {
            if let iv = imageViewForId[attachment.localID] {
                let gr = layoutManager.glyphRange(forCharacterRange: NSMakeRange(charIndex, 1), actualCharacterRange: nil)
                iv.frame = layoutManager.boundingRect(forGlyphRange: gr, in: layoutManager.textContainers.first!)
            }
        }
    }
    
    
    fileprivate func addImage(_ atIAStringIndex:Int, iaString:IAString, layoutManager:NSLayoutManager){
        guard let attachment = iaString.attachments[atIAStringIndex] else {print("IAImageLayerView. addImage: couldnt find attachment at charIndex \(atIAStringIndex)");return}
        let gr = layoutManager.glyphRange(forCharacterRange: NSMakeRange(atIAStringIndex, 1), actualCharacterRange: nil)

        let iv = UIImageView(frame: layoutManager.boundingRect(forGlyphRange: gr, in: layoutManager.textContainers.first!))
        if let thumb = attachment.imageForThumbSize(self.useThumbSize) {
            iv.image = thumb
        } else {
            iv.image = IAPlaceholder.forSize(self.useThumbSize, attachType: attachment.attachmentType)
            _ = attachment.attemptToLoadResource()
        }
        imageViewForId[attachment.localID] = iv
        self.addSubview(iv)
        
    }
    
    
    fileprivate func removeImage(_ imageLocalID:String){
        guard let iv = imageViewForId.removeValue(forKey: imageLocalID) else {print("IAImageLayerView. removeImage: couldnt find iv for localID \(imageLocalID)");return}
        iv.removeFromSuperview()
        
    }
    
}

