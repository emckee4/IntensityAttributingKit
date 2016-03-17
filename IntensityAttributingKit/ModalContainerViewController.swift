//
//  ModalContainerViewController.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/16/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///ViewController with dismiss button intended to hold other VCs during modal presentations
class ModalContainerViewController: UIViewController {

    var dismissButton:UIButton!
    
    var dismissalCompletionBlock:(Void->Void)?
    
    ///If true then the dismissButton will overlay the trailing top corner. Otherwise it will be placed above it.
    var dismissButtonOverlays:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissButton = UIButton(type: .System)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dismissButton)
        dismissButton.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor).active = true
        dismissButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        dismissButton.widthAnchor.constraintEqualToConstant(25.0).activateWithPriority(1000)
        dismissButton.heightAnchor.constraintEqualToConstant(25.0).activateWithPriority(1000)
        dismissButton.backgroundColor = UIColor.darkGrayColor()
        dismissButton.addTarget(self, action: "dismissButtonPressed", forControlEvents: .TouchUpInside)
        
        guard let child = childViewControllers.first else {return}
        self.view.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).activateWithPriority(1000)
        child.view.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).activateWithPriority(1000)
        child.view.bottomAnchor.constraintEqualToAnchor(self.bottomLayoutGuide.topAnchor).activateWithPriority(1000)
        
        if dismissButtonOverlays {
            child.view.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor).activateWithPriority(1000)
            self.view.bringSubviewToFront(dismissButton)
            dismissButton.opaque = false
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
