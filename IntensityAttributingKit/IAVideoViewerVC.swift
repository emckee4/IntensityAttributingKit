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
open class IAVideoViewerVC: UIViewController {
    
    open var playerController:AVPlayerViewController!
    open var attachment:IAVideoAttachment!
    
    fileprivate var previousNavTranslucency:Bool?
    fileprivate var previousNavBackgroundImage:UIImage?
    fileprivate var previousNavShadowImage: UIImage?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        var vidURL:URL!
        if let localURL = attachment.localVideoURL, (try? localURL.checkResourceIsReachable()) ?? false {
            vidURL = localURL
        } else if let localTempURL = attachment.temporaryVideoURL, (try? localTempURL.checkResourceIsReachable()) ?? false {
            vidURL = localTempURL
        } else if let remoteURL = attachment.remoteVideoURL {
            vidURL = remoteURL
        } else {
            print("video attachment has no valid video url") //should never happen
            vidURL = URL(string:"")!
        }
        
        let avPlayer = AVPlayer(url:vidURL)
        playerController = AVPlayerViewController()
        playerController.player = avPlayer
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        playerController.view.translatesAutoresizingMaskIntoConstraints = false
        playerController.didMove(toParentViewController: self)
        
        
        playerController.view.topAnchor.constraint(equalTo: self.view.topAnchor).activateWithPriority(999)
        playerController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).activateWithPriority(999)
        playerController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).activateWithPriority(999)
        playerController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).activateWithPriority(999)
        
        setNavbarBackgroundClear()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        revertNavbarBackground()
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func setNavbarBackgroundClear(){
        guard let navBar = navigationController?.navigationBar else {return}
        previousNavTranslucency = navBar.isTranslucent
        previousNavBackgroundImage = navBar.backgroundImage(for: .default)
        previousNavShadowImage = navBar.shadowImage
        
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
    }
    
    func revertNavbarBackground(){
        guard let navBar = navigationController?.navigationBar else {return}
        navBar.isTranslucent = previousNavTranslucency ?? true
        navBar.setBackgroundImage(previousNavBackgroundImage, for: .default)
        navBar.shadowImage = previousNavShadowImage 
    }
    
}
