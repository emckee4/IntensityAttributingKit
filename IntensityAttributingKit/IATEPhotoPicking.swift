//
//  IATextEditorPhotoPicking.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/1/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit
import MobileCoreServices


///Image picker extension. This handles the presentation and aftermath of a UIImagePickerController.
extension IACompositeTextEditor:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        if let mediaType = info[UIImagePickerControllerMediaType] as? String where mediaType == kUTTypeMovie as String, let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL {
            videoChosen(videoURL)
            return
        }
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.imageChosen(image)
            return
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageChosen(image)
            return
        }
        self.imageChosen(nil) //called so that first responder is restored on dismissal
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.becomeFirstResponder()
    }
    
    ///If the IATextEditorDelegate returns true then this function will launch the image picker vc on the root view controller of the window holding the text editor. This may be more of a divergence from the MVC pattern than usual but it allows this Framework to be a little more self contained and easy to implement in other projects. The simplest alternative is to instantiate the picker VC and pass it to the delegate to be presented or discarded, but this method works and keeps things easy for now.
    func launchPhotoPicker(){
        guard self.delegate?.iaTextEditorRequestsPresentationOfContentPicker?(self) == true else {return}
        if UIImagePickerController.isCameraDeviceAvailable(.Rear) {
            let alert = UIAlertController(title: "Insert Photo", message: "Choose source", preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action) -> Void in
                guard  NSThread.isMainThread() else {fatalError()}
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = .SavedPhotosAlbum
                self.window?.rootViewController?.presentViewController(imagePicker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
                guard  NSThread.isMainThread() else {fatalError()}
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
                self.window?.rootViewController?.presentViewController(imagePicker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        } else {
            guard  NSThread.isMainThread() else {fatalError()}
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.sourceType = .SavedPhotosAlbum
            self.window?.rootViewController?.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func launchVideoPicker(){
        guard self.delegate?.iaTextEditorRequestsPresentationOfContentPicker?(self) == true else {return}
        let picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.videoQuality = IAKitPreferences.videoAttachmentQuality
        picker.videoMaximumDuration = IAKitPreferences.videoAttachmentMaxDuration
        if UIImagePickerController.isCameraDeviceAvailable(.Rear) {
            let alert = UIAlertController(title: "Insert Video", message: "Choose source", preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Video Library", style: .Default, handler: { (action) -> Void in
                guard  NSThread.isMainThread() else {fatalError()}
                picker.allowsEditing = true
                picker.delegate = self
                picker.sourceType = .SavedPhotosAlbum
                self.window?.rootViewController?.presentViewController(picker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
                guard  NSThread.isMainThread() else {fatalError()}
                picker.allowsEditing = true
                picker.delegate = self
                picker.sourceType = .Camera
                self.window?.rootViewController?.presentViewController(picker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        } else {
            guard  NSThread.isMainThread() else {fatalError()}
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .SavedPhotosAlbum
            self.window?.rootViewController?.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imageChosen(image:UIImage!){
        guard image != nil && selectedRange != nil else {self.becomeFirstResponder();return}
        let ta = IAImageAttachment(withImage: image.resizeImageToFit(maxSize: IAKitPreferences.maxSavedImageDimensions))
        //let insertionLoc = self.selectedRange.location
        let newIA = self.iaString!.emptyCopy()
        newIA.insertAttachmentAtPosition(ta, position: 0, intensity: self.currentIntensity, attributes: baseAttributes)
        replaceIAStringRange(newIA, range: selectedRange!)
        self.becomeFirstResponder()
    }
    

    func videoChosen(videoURL:NSURL!){
        guard videoURL != nil && selectedRange != nil else {self.becomeFirstResponder();return}
        
        print(videoURL)
        //let ta = IATextAttachment()
            //TODO:assign url instead of image
            //ta.image = image.resizeImageToFit(maxSize: IAKitPreferences.maxSavedImageDimensions)

        //let newIA = self.iaString!.emptyCopy()
        //newIA.insertAttachmentAtPosition(ta, position: 0, intensity: self.currentIntensity, attributes: baseAttributes)
        //replaceIAStringRange(newIA, range: selectedRange!)
        
        self.becomeFirstResponder()
    }
    
}





