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
    
    var dismissalCompletionBlock:((Void)->Void)?
    let kDismissButtonSize:CGFloat = 26
    
    ///If true then the dismissButton will overlay the trailing top corner. Otherwise it will be placed above it.
    var dismissButtonOverlays:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.light)
        effectView = UIVisualEffectView(effect: blur)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(effectView)
        
        dismissButton = UIButton(type: .system)
        let xImage = UIImage(named: "circleX", in: IAKitPreferences.bundle, compatibleWith: self.traitCollection)!
        dismissButton.setImage(xImage, for: UIControlState())
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dismissButton)
        dismissButton.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: kDismissButtonSize).activateWithPriority(1000)
        dismissButton.heightAnchor.constraint(equalToConstant: kDismissButtonSize).activateWithPriority(1000)
        dismissButton.addTarget(self, action: #selector(ModalContainerViewController.dismissButtonPressed), for: .touchUpInside)
        
        effectView.topAnchor.constraint(equalTo: dismissButton.topAnchor).isActive = true
        effectView.trailingAnchor.constraint(equalTo: dismissButton.trailingAnchor).isActive = true
        effectView.widthAnchor.constraint(equalToConstant: kDismissButtonSize).activateWithPriority(1000)
        effectView.heightAnchor.constraint(equalToConstant: kDismissButtonSize).activateWithPriority(1000)
        
        
        guard let child = childViewControllers.first else {return}
        self.view.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).activateWithPriority(1000)
        child.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).activateWithPriority(1000)
        child.view.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).activateWithPriority(1000)
        
        if dismissButtonOverlays {
            child.view.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).activateWithPriority(1000)
            self.view.bringSubview(toFront: effectView)
            self.view.bringSubview(toFront: dismissButton)
        } else {
            child.view.topAnchor.constraint(equalTo: self.dismissButton.bottomAnchor).activateWithPriority(1000)
        }
        if self.view.backgroundColor == nil {
            self.view.backgroundColor = UIColor.lightGray
        }
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissButtonPressed(){
        self.dismiss(animated: true, completion: dismissalCompletionBlock)
    }

}
