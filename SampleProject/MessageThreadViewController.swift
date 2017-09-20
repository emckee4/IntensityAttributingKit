//
//  MessageThreadViewController.swift
//  IntensityMessaging
//
//  Created by Evan Mckee on 12/3/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit
import IntensityAttributingKit

class MessageThreadViewController: UIViewController, IACompositeTextEditorDelegate, ComposerBarDelegate {

    var composerBar:ComposerBar!
    var messageThreadTableVC:MessageThreadTableVC!
    weak var messageThreadView:UIView!
    
    var composerBottomConstraint:NSLayoutConstraint!

    
    static var draftMessageCache:IAStringArchive?

    
    ///If this is set to true before the view appears then the IATextEditor will begin as first responded
    var startInEditorMode:Bool = false
    fileprivate var keyboardIsShowing:Bool = false
        
    ///This gets an image of the composerBar and is attached to the top of the accessory during keyboard transitions, allowing the actual composerBar to be hidden for the duration of the transition. This improves performance slightly and removes the issue of having the composer bar track the top of the accessory bar which is particularly chalenging during an interactive dismissal.
    var tempImageView:UIImageView = UIImageView(image: nil)
    
    ///Indicates when an keyboard interactive dismissal is in progress. When this is true, the actual composerBar will be hidden while an image of it will be displayed in tempImageView which will be attached to the top of the IAAccessory until endInteractiveKBDismissal() is called.
    fileprivate(set) var kbIsInInteractiveDismissal:Bool = false
    
    ///Last offset value used to position the composer bar so that it's above the IAAccessory when it's present, or at the bottom of the screen otherwise.
    var lastOffset:CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSceneSetup()
        configureSendButton()
        self.navigationItem.title = "Messages"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "KB Themes", style: .plain, target: self, action: #selector(MessageThreadViewController.changeKBTheme))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageThreadViewController.kbFrameChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageThreadViewController.handleAppBecameActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)


        messageThreadTableVC.scrollToBottom(false)
        composerBar.textEditor.resetEditor()
        if let draft = MessageThreadViewController.draftMessageCache {
            self.composerBar.textEditor.setIAString(draft.iaString)
            MessageThreadViewController.draftMessageCache = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if startInEditorMode {
            _ = composerBar.textEditor.becomeFirstResponder()
            startInEditorMode = false
        } else {
            messageThreadTableVC.scrollToBottom(true) //this is handled in the keyboard will appear code if we start as first responder
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentIAString = composerBar.textEditor.iaString {
            let archive = IAStringArchive(iaString: currentIAString)
            MessageThreadViewController.draftMessageCache = archive
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    ///instantiates views, sets constraints, etc
    func initialSceneSetup(){
        messageThreadTableVC = MessageThreadTableVC()
        
        self.addChildViewController(messageThreadTableVC)
        
        messageThreadView = messageThreadTableVC.view
        messageThreadView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(messageThreadView)
        
        messageThreadView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        messageThreadView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        messageThreadView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        composerBar = ComposerBar()
        self.view.addSubview(composerBar)
        composerBar.textEditor.delegate = self
        composerBar.delegate = self
        //messageThreadView.bottomAnchor.constraintEqualToAnchor(composerBar.topAnchor).active = true
        messageThreadView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        composerBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        composerBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        composerBottomConstraint = composerBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        composerBottomConstraint.isActive = true
        composerBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        
        //self.view.backgroundColor = UIColor.lightGrayColor()
        
        composerBar.sendButton.backgroundColor = UIColor.lightGray
        messageThreadTableVC.tableView.contentInset = UIEdgeInsets(top: 6.0, left: 0.0, bottom: 48, right: 0.0)
        composerBar.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        composerBar.textEditor.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        composerBar.textEditor.cornerRadius = 5.0
        composerBar.isOpaque = true
    }
    
    func configureSendButton(){
        composerBar.sendButton.setSelector(self, selector: "sendMessageButtonPressed:")
        
        composerBar.sendButton.addKey(withTextLabel: "\u{2009}Send\u{2009}", actionName: "sendNormal")
        composerBar.sendButton.addKey(withTextLabel: "Rec", actionName: "postAsReceived")
    }
    
    
    func sendMessageButtonPressed(_ actionName:String!){
        self.view.endEditing(false)
        guard composerBar.textEditor.iaString!.length > 0 else {return}
        if actionName == "sendNormal" {
            let newMessage = Message(iaString: composerBar.textEditor.finalizeIAString(), isSender: true)
            composerBar.textEditor.resetEditor()
            messageThreadTableVC.appendMessage(newMessage)
        } else if actionName == "postAsReceived" {
            let newMessage = Message(iaString: composerBar.textEditor.finalizeIAString(), isSender: false)
            composerBar.textEditor.resetEditor()
            messageThreadTableVC.appendMessage(newMessage)
        }
        
    }
    
    
    @objc func handleAppBecameActive(_ notification:Notification){
        composerBar.textEditor.delegate = self
    }
    
    
    /**We want to use the keyboardDismissModeInteractive to handle dismisals of the keyboard when editing. This works fine except that the composerBar doesn't track the top of the accessory by default since it's in a different view hierarchy than the input views. Instead it uses notifications to animate its apparant tracking of the top of the input accessory.
     In order to make this work properly we need to determine when we're in mid interactive dismissal (we can consider when this pan's location drags below the top of the accessory's last position as given by the keyboard notifications). Once we've crossed that threshhold we call beginInteractiveKBDismissal() which renders the composerBar as an image, attaches that image to the top of the accessory (using tempImageView), then hides the composerBar and sets kbIsInInteractiveDismissal to true until the next keyboard frame change notification, which will occur at the end of the gesture, regardless of its results.
     */
    @objc func pan(_ sender:UIPanGestureRecognizer!){
        guard sender.state == UIGestureRecognizerState.changed else {return}
        guard composerBar?.textEditor?.inputAccessoryViewController?.inputView != nil && composerBar!.textEditor!.isFirstResponder else {return}
        guard lastOffset != nil else {return}
        let loc = sender.location(in: self.view)
        if loc.y > (lastOffset! + self.view.bounds.height) {
            if kbIsInInteractiveDismissal == false {
                beginInteractiveKBDismissal()
                
            }
            let offset = -(self.view.window!.frame.height - loc.y)
            self.composerBottomConstraint.constant = offset
        }
        
    }

    @objc func kbFrameChange(_ notification:Notification!){
        //print(notification.name, notification.userInfo!)
        guard notification.name == NSNotification.Name.UIKeyboardWillChangeFrame else {return}
        guard let frameEnd = (notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let duration = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval, let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Int else {return}

        if kbIsInInteractiveDismissal{
            endInteractiveKBDismissal()
        }
        let offset = -(self.view.window!.frame.height - frameEnd.origin.y)
        self.composerBottomConstraint.constant = offset
        lastOffset = offset
        
        //should check that this isn't a case where a drag to dismiss just ended, in which case we dont need to animate
        
        //also need to check if we should scroll the tableview to the bottom
        let newKeyboardIsShowing = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue?.origin.y == self.view.bounds.height
        messageThreadTableVC.tableView.contentInset.bottom = self.view.bounds.height - composerBar.frame.origin.y
        
        /* We need to use the old style animation code because animateWithDuration lacks a direct way to match the animation curve supplied by the notification. */
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.view.layoutIfNeeded()
        UIView.commitAnimations()

        if newKeyboardIsShowing {
            DispatchQueue.main.async(execute: { 
                self.messageThreadTableVC.scrollToBottom(true)
            })
        }
    }
    

    ///This causes the composerBar to be rendered as an image and then hidden. This image will then be displayed in tempImageView at the top of the IAAccessory until endInteractiveKBDismissal is called to reverse it. This is used to ensure that the composerBar appears to track the top of the IAAccessory during interactive dismissals
    func beginInteractiveKBDismissal(){
        guard let acc = composerBar.textEditor.inputAccessoryViewController else {return}
        let image = composerBar.imageFromView()!
        tempImageView.image = image
        acc.view.addSubview(tempImageView)
        tempImageView.frame = CGRect(x: 0, y: -image.size.height, width: image.size.width, height: image.size.height)
        composerBar.isHidden = true
        kbIsInInteractiveDismissal = true
    }
    
    ///Reverses the effects of beginInteractiveKBDismissal by removing the tempImageView and unhiding the composerBar
    func endInteractiveKBDismissal(){
        composerBar.isHidden = false
        tempImageView.removeFromSuperview()
        kbIsInInteractiveDismissal = false
    }
    
    func iaTextEditorRequestsPresentationOfOptionsVC(_ iaTextEditor: IACompositeTextEditor) -> Bool {
        return true
    }
    func iaTextEditorRequestsPresentationOfContentPicker(_ iaTextEditor: IACompositeTextEditor) -> Bool {
        return true
    }
    
    ///We watch this delegate function so that we can update the contentInset of the tableview when the top composerBar changes for reasons other than keyboard frame change. The contentInset changes resulting from keyboard frame change are handled in kbFrameChange().
    func composerBarHeightChanged() {
        if composerBar.frame.origin.y > 0{
            messageThreadTableVC.tableView.contentInset.bottom =  self.view.bounds.height - composerBar.frame.origin.y
        }
    }
    
    @objc func changeKBTheme(){
        switch IAKitPreferences.visualPreferences {
        
        case IAKitVisualPreferences.Default:
            IAKitPreferences.visualPreferences = IAKitVisualPreferences.HotdogStand
        case IAKitVisualPreferences.FlatBasicGray:
            IAKitPreferences.visualPreferences = IAKitVisualPreferences.Default
        default:
            IAKitPreferences.visualPreferences = IAKitVisualPreferences.FlatBasicGray
        }
        //composerBar.textEditor.resignFirstResponder()
        IAKitPreferences.resetKBAndAccessory()
    }

}

