//
//  IATEPhotoPicking.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/1/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


///Image picker extension
extension IATE:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.imageChosen(image)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageChosen(image)
        } else {
            self.imageChosen(nil)
        }
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.imageChosen(nil)
    }
    
    func launchPicker(){

        if UIImagePickerController.isCameraDeviceAvailable(.Rear) {
            let alert = UIAlertController(title: "Insert Photo", message: "Choose source", preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action) -> Void in
                let threadisMain = NSThread.isMainThread()
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = .SavedPhotosAlbum
                self.editorDelegate?.iaTextEditorRequestsPresentation(self, shouldPresentVC: imagePicker)
            }))
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
                let threadisMain = NSThread.isMainThread()
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
                self.editorDelegate?.iaTextEditorRequestsPresentation(self, shouldPresentVC: imagePicker)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            //self.delegate?.presentingVC?.presentViewController(alert, animated: true, completion: nil)
            self.editorDelegate?.iaTextEditorRequestsPresentation(self, shouldPresentVC: alert)
        } else {
            let threadisMain = NSThread.isMainThread()
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.sourceType = .SavedPhotosAlbum
            imagePicker.sourceType = .SavedPhotosAlbum
            self.editorDelegate?.iaTextEditorRequestsPresentation(self, shouldPresentVC: imagePicker)
        }
    }
    
    func imageChosen(image:UIImage!){
        guard let image = image else {return}
        //        if let image = image {
        //            let attString = NSMutableAttributedString( attributedString: NSAttributedString(image: image, intensityAttributes: currentAttributes, thumbSize:thumbSizesForAttachments, scaleToMaxSize: IAKitOptions.singleton.maxSavedImageDimensions) )
        //            //attString.applyStoredImageConstraints(maxDisplayedSize: preferedImageDisplaySize)
        //            insertAttributedStringAtCursor(attString.transformWithRenderScheme(currentAttributes!.currentScheme))
        //        }
        let ta = IATextAttachment()
        ta.image = image
        let insertionLoc = self.selectedRange.location
        if self.selectedRange.length > 0 {
            self.iaString!.removeRange(self.selectedRange.intRange)
        }
        self.iaString!.insertAttachmentAtPosition(ta, position: insertionLoc, intensity:defaultIntensity , attributes: baseAttributes)
        self.renderIAString()
        self.selectedRange = NSMakeRange(insertionLoc + 1, 0)
        self.becomeFirstResponder()
    }
    
}





