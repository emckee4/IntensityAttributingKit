//
//  IATextEditorPhotoPicking.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/1/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreLocation


///Image picker extension. This handles the presentation and aftermath of a UIImagePickerController.
extension IACompositeTextEditor:UIImagePickerControllerDelegate, UINavigationControllerDelegate, IALocationPickerDelegate {
    
    
    ///If the IATextEditorDelegate returns true then this function will launch the image picker vc on the root view controller of the window holding the text editor. This may be more of a divergence from the MVC pattern than usual but it allows this Framework to be a little more self contained and easy to implement in other projects. The simplest alternative is to instantiate the picker VC and pass it to the delegate to be presented or discarded, but this method works and keeps things easy for now.
    func launchPhotoPicker(){
        guard self.delegate?.iaTextEditorRequestsPresentationOfContentPicker?(self) == true else {return}
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            let alert = UIAlertController(title: "Insert Photo", message: "Choose source", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) -> Void in
                guard  Thread.isMainThread else {fatalError()}
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                self.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
                guard  Thread.isMainThread else {fatalError()}
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                self.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            guard  Thread.isMainThread else {fatalError()}
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func launchVideoPicker(){
        guard self.delegate?.iaTextEditorRequestsPresentationOfContentPicker?(self) == true else {return}
        let picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.videoQuality = IAKitPreferences.videoAttachmentQuality
        picker.videoMaximumDuration = IAKitPreferences.videoAttachmentMaxDuration
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            let alert = UIAlertController(title: "Insert Video", message: "Choose source", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Video Library", style: .default, handler: { (action) -> Void in
                guard  Thread.isMainThread else {fatalError()}
                picker.allowsEditing = true
                picker.delegate = self
                picker.sourceType = .photoLibrary
                self.window?.rootViewController?.present(picker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
                guard  Thread.isMainThread else {fatalError()}
                picker.allowsEditing = true
                picker.delegate = self
                picker.sourceType = .camera
                self.window?.rootViewController?.present(picker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            guard  Thread.isMainThread else {fatalError()}
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.window?.rootViewController?.present(picker, animated: true, completion: nil)
        }
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let mediaType = info[UIImagePickerControllerMediaType] as? String, mediaType == kUTTypeMovie as String, let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
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
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        _ = self.becomeFirstResponder()
    }
    

    
    func imageChosen(_ image:UIImage!){
        guard image != nil && selectedRange != nil else {_ = self.becomeFirstResponder();return}
        let ta = IAImageAttachment(withImage: image.resizeImageToFit(maxSize: IAKitPreferences.maxSavedImageDimensions))
        let newIA = IAString(withAttachment: ta, intensity: self.currentIntensity, baseAtts: baseAttributes, baseOptions: self.iaString.baseOptions)
        replaceIAStringRange(newIA!, range: selectedRange!)
        _ = self.becomeFirstResponder()
    }
    

    func videoChosen(_ videoURL:URL!){
        guard videoURL != nil && selectedRange != nil else {_ = self.becomeFirstResponder();return}
        let ta = IAVideoAttachment(withTemporaryFileLocation: videoURL)!
        let newIA = IAString(withAttachment: ta, intensity: self.currentIntensity, baseAtts: baseAttributes, baseOptions: self.iaString.baseOptions)!
        replaceIAStringRange(newIA, range: selectedRange!)
        _ = self.becomeFirstResponder()
    }
    
    
    func launchLocationPicker(){
        guard self.delegate?.iaTextEditorRequestsPresentationOfContentPicker?(self) == true else {return}
        
        let lp = IALocationPickerVC()
        lp.delegate = self
        self.window?.rootViewController?.present(lp, animated: true, completion: nil)
    }
    
    func locationPickerController(_ picker: IALocationPickerVC, location: IAPlacemark, mapViewDeltaMeters:CLLocationDistance) {
        let ta = IALocationAttachment(placemark: location, mapViewDeltaMeters: mapViewDeltaMeters)
        ta?.generateImage()
        picker.dismiss(animated: true, completion: nil)
        let newIA = IAString(withAttachment: ta!, intensity: self.currentIntensity, baseAtts: baseAttributes, baseOptions: self.iaString.baseOptions)!
        replaceIAStringRange(newIA, range: selectedRange!)
    }
    
    func locationPickerControllerDidCancel(_ picker: IALocationPickerVC) {
        picker.dismiss(animated: true, completion: nil)
        _ = self.becomeFirstResponder()
    }
    
}



