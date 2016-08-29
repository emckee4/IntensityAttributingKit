//
//  IAImageViewerVC.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/28/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation
import UIKit

/**
 IAImageViewerVC provides a convenient prebuilt method for viewing IAImageAttachments.
 */
public class IAImageViewerVC: UIViewController {
    
    public var imageView:UIImageView!
    public var attachment:IAImageAttachment!
    public var tapRecogniser:UITapGestureRecognizer!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        imageView = UIImageView(image: attachment.image)
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        imageView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        imageView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        imageView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        imageView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        imageView.userInteractionEnabled = true
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        
        tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(IAImageViewerVC.imageTapped(_:)))
        imageView.addGestureRecognizer(tapRecogniser)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public func imageTapped(recognizer:UITapGestureRecognizer!){
        guard let image = attachment.image else {return}
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let copyAction = UIAlertAction(title: "Copy image", style: .Default) { (action) -> Void in
            let pb = UIPasteboard.generalPasteboard()
            pb.image = image
        }
        alert.addAction(copyAction)
        let saveAction = UIAlertAction(title: "Save to Photoroll", style: .Default) { (action) -> Void in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}