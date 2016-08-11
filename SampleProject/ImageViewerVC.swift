//
//  ImageViewerVC.swift
//  IntensityMessaging
//
//  Created by Evan Mckee on 12/21/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

class ImageViewerVC: UIViewController {

    var imageView:UIImageView!
    var image:UIImage!
    var tapRecogniser:UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: image)
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        imageView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        imageView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        imageView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        imageView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        imageView.userInteractionEnabled = true
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        
        tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(ImageViewerVC.imageTapped(_:)))
        imageView.addGestureRecognizer(tapRecogniser)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imageTapped(recognizer:UITapGestureRecognizer!){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let copyAction = UIAlertAction(title: "Copy image", style: .Default) { (action) -> Void in
            let pb = UIPasteboard.generalPasteboard()
            pb.image = self.image
        }
        alert.addAction(copyAction)
        let saveAction = UIAlertAction(title: "Save to Photoroll", style: .Default) { (action) -> Void in
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil)
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
