//
//  ModalContainerViewController.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/16/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///ViewController with dismiss button intended to hold other VCs during modal presentations. This is used primarily to hold the IAKitSettingsTableViewController while keeping it flexible enough to be displayed as-is elsewhere. It also has the benefit of having a dismissalCompletionBlock.
class ModalContainerViewController: UIViewController {

    var dismissButton:UIButton!
    var effectView:UIVisualEffectView!
    
    var dismissalCompletionBlock:(Void->Void)?
    let kDismissButtonSize:CGFloat = 26
    
    ///If true then the dismissButton will overlay the trailing top corner. Otherwise it will be placed above it.
    var dismissButtonOverlays:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        effectView = UIVisualEffectView(effect: blur)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(effectView)
        
        dismissButton = UIButton(type: .System)
        let xImage = UIImage(named: "circleX", inBundle: IAKitPreferences.bundle, compatibleWithTraitCollection: self.traitCollection)!
        dismissButton.setImage(xImage, forState: .Normal)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dismissButton)
        dismissButton.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor).active = true
        dismissButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        dismissButton.widthAnchor.constraintEqualToConstant(kDismissButtonSize).activateWithPriority(1000)
        dismissButton.heightAnchor.constraintEqualToConstant(kDismissButtonSize).activateWithPriority(1000)
        dismissButton.addTarget(self, action: #selector(ModalContainerViewController.dismissButtonPressed), forControlEvents: .TouchUpInside)
        
        effectView.topAnchor.constraintEqualToAnchor(dismissButton.topAnchor).active = true
        effectView.trailingAnchor.constraintEqualToAnchor(dismissButton.trailingAnchor).active = true
        effectView.widthAnchor.constraintEqualToConstant(kDismissButtonSize).activateWithPriority(1000)
        effectView.heightAnchor.constraintEqualToConstant(kDismissButtonSize).activateWithPriority(1000)
        
        
        guard let child = childViewControllers.first else {return}
        self.view.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).activateWithPriority(1000)
        child.view.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).activateWithPriority(1000)
        child.view.bottomAnchor.constraintEqualToAnchor(self.bottomLayoutGuide.topAnchor).activateWithPriority(1000)
        
        if dismissButtonOverlays {
            child.view.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor).activateWithPriority(1000)
            self.view.bringSubviewToFront(effectView)
            self.view.bringSubviewToFront(dismissButton)
        } else {
            child.view.topAnchor.constraintEqualToAnchor(self.dismissButton.bottomAnchor).activateWithPriority(1000)
        }
        if self.view.backgroundColor == nil {
            self.view.backgroundColor = UIColor.lightGrayColor()
        }
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissButtonPressed(){
        self.dismissViewControllerAnimated(true, completion: dismissalCompletionBlock)
    }

}
