//
//  IATextEditorPhotoPicking.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/1/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


///Image picker extension
extension IACompositeTextEditor:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
                guard  NSThread.isMainThread() else {fatalError()}
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = .SavedPhotosAlbum
                self.editorDelegate?.iaTextEditorRequestsPresentation(self, shouldPresentVC: imagePicker)
            }))
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
                guard  NSThread.isMainThread() else {fatalError()}
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
            guard  NSThread.isMainThread() else {fatalError()}
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
        guard let selectedRange = selectedRange else {return}
        let ta = IATextAttachment()
        ta.image = image.resizeImageToFit(maxSize: IAKitPreferences.maxSavedImageDimensions)
        //let insertionLoc = self.selectedRange.location
        let newIA = self.iaString!.emptyCopy()
        newIA.insertAttachmentAtPosition(ta, position: 0, intensity: self.currentIntensity, attributes: baseAttributes)
        replaceIAStringRange(newIA, range: selectedRange)
        self.becomeFirstResponder()
    }
    
}





