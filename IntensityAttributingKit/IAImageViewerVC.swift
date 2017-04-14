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
open class IAImageViewerVC: UIViewController {
    
    open var imageView:UIImageView!
    open var attachment:IAImageAttachment!
    open var tapRecogniser:UITapGestureRecognizer!
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        imageView = UIImageView(image: attachment.image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        imageView.isUserInteractionEnabled = true
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        
        tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(IAImageViewerVC.imageTapped(_:)))
        imageView.addGestureRecognizer(tapRecogniser)
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }
    
    open func imageTapped(_ recognizer:UITapGestureRecognizer!){
        guard let image = attachment.image else {return}
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(title: "Copy image", style: .default) { (action) -> Void in
            let pb = UIPasteboard.general
            pb.image = image
        }
        alert.addAction(copyAction)
        let saveAction = UIAlertAction(title: "Save to Photoroll", style: .default) { (action) -> Void in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
