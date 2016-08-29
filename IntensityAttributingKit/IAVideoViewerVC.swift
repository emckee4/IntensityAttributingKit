//
//  IAVideoViewController.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/28/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

/**
 IAVideoViewerVC provides a convenient prebuilt method for viewing IAImageAttachments.
 */
public class IAVideoViewerVC: UIViewController {
    
    public var playerController:AVPlayerViewController!
    public var attachment:IAVideoAttachment!
    
    private var previousNavTranslucency:Bool?
    private var previousNavBackgroundImage:UIImage?
    private var previousNavShadowImage: UIImage?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: provide better handling of different locations of the candidate video, either here or in the attachment itself
        
        let vidURL = attachment.temporaryVideoURL ?? attachment.localVideoURL ?? attachment.remoteVideoURL ?? NSURL()
        
        let avPlayer = AVPlayer(URL:vidURL)
        playerController = AVPlayerViewController()
        playerController.player = avPlayer
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        playerController.view.translatesAutoresizingMaskIntoConstraints = false
        playerController.didMoveToParentViewController(self)
        
        
        playerController.view.topAnchor.constraintEqualToAnchor(self.view.topAnchor).activateWithPriority(999)
        playerController.view.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).activateWithPriority(999)
        playerController.view.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).activateWithPriority(999)
        playerController.view.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).activateWithPriority(999)
        
        setNavbarBackgroundClear()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        revertNavbarBackground()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setNavbarBackgroundClear(){
        guard let navBar = navigationController?.navigationBar else {return}
        previousNavTranslucency = navBar.translucent
        previousNavBackgroundImage = navBar.backgroundImageForBarMetrics(.Default)
        previousNavShadowImage = navBar.shadowImage
        
        navBar.translucent = true
        navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navBar.shadowImage = UIImage()
    }
    
    func revertNavbarBackground(){
        guard let navBar = navigationController?.navigationBar else {return}
        navBar.translucent = previousNavTranslucency ?? true
        navBar.setBackgroundImage(previousNavBackgroundImage, forBarMetrics: .Default)
        navBar.shadowImage = previousNavShadowImage 
    }
    
}