//
//  MessageThreadTableVC.swift
//  IntensityMessaging
//
//  Created by Evan Mckee on 11/20/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit
import IntensityAttributingKit

class MessageThreadTableVC: UITableViewController, IATextViewDelegate {

    var messages:[Message] = []
    
    ///Caches height calculations for message cells
    var heightCache:[String:CGFloat] = [:]
    
    ///Cell iaTextViews will have their preferredMAxLayoutWidth set to values based on this rather than the present width if non-nil. This is used during rotations.
    var reloadingToWidth:CGFloat?
    
    ///Background view and layer for tableview
    var gv:UIView!
    var gradientLayer:CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        
        self.tableView.separatorStyle = .None
        self.tableView.keyboardDismissMode = .Interactive
        self.tableView.panGestureRecognizer.addTarget(self.parentViewController!, action: #selector(MessageThreadViewController.pan(_:)))
        
        gv = UIView(frame: tableView.bounds)
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: CGPointZero, size: UIScreen.mainScreen().bounds.size)
        gradientLayer.colors = [UIColor.darkGrayColor().CGColor,UIColor.purpleColor().CGColor]
        gradientLayer.locations = [0.0,1.0]
        gv.layer.insertSublayer(gradientLayer, atIndex: 0)
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundView = gv
        gv.widthAnchor.constraintEqualToAnchor(tableView.widthAnchor).active = true
        gv.heightAnchor.constraintEqualToAnchor(tableView.heightAnchor).active = true
        gv.topAnchor.constraintEqualToAnchor(tableView.topAnchor).active = true
        gv.leftAnchor.constraintEqualToAnchor(tableView.leftAnchor).active = true
        gv.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.backgroundColor = UIColor.darkGrayColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        cell.iaTextView.delegate = self
        let message = messages[indexPath.row]
        configureCell(cell, message: message)
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        return cell
    }
    
    func configureCell(cell:MessageCell, message:Message){
        cell.iaTextView.delegate = self
        if reloadingToWidth != nil {
            cell.iaTextView.preferedMaxLayoutWidth = MessageCell.textViewWidthForCellWidth(reloadingToWidth!)
        } else {
            cell.iaTextView.preferedMaxLayoutWidth = MessageCell.textViewWidthForCellWidth(self.view.bounds.width)

        }
        if message.isSender {
            cell.displayMode = MessageCell.DisplayMode.Sending
        } else {
            cell.displayMode = MessageCell.DisplayMode.Receiving
        }

        cell.dateLabel.text = DateConversion.adaptiveDTString(message.createdAt)

        cell.dateLabel.numberOfLines = 2
        cell.dateLabel.font = UIFont.systemFontOfSize(13.0)
        cell.iaTextView.setIAString(message.iaString, withCacheIdentifier: message.messageID)
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        let cachedName = message.messageID + "-\(reloadingToWidth ?? tableView.bounds.width)"
        if let height = heightCache[cachedName] {
            return height
        } else {
            //let est = calculateHeightEstimate(indexPath)
            let height = calculateCellHeightUsingAutoLayout(message)
            //print("est: \(est), height: \(height), delta: \(est - height), iaStringLength: \(message.iaString.length), attachments: \(message.iaString.attachmentCount)")
            self.heightCache[cachedName] = height
            return height
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        let cachedName = message.messageID + "-\(tableView.bounds.width)"
        if let height = heightCache[cachedName] {
            return height
        } else {
            return calculateHeightEstimate(message)
        }
    }
    
    ///Estimates cell height using basic math rather than calling autolayout engine
    func calculateHeightEstimate(message:Message)->CGFloat{
        let charCount:Int = message.iaString.length
        let attachCount:Int = message.iaString.attachmentCount
        let extraAttachWidth = (10 * attachCount)
        let baseLineCount:Int = Int(ceil(Float(charCount + extraAttachWidth) / (Float(self.tableView.bounds.width) / 15.0)))
        let adjustedLineCount:Int = max(baseLineCount - attachCount, 0)
        let tvEstimate:CGFloat = 14 + (CGFloat(adjustedLineCount) * 24) + (CGFloat(attachCount) * IAThumbSize.Medium.size.height) + (2 * MessageCell.kVerticalInsets)
        return tvEstimate
    }
    
    ///Calculates the exact height of the message cell using current tableview width
    func calculateCellHeightUsingAutoLayout(forMessage:Message)->CGFloat{
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        configureCell(cell, message: forMessage)
        cell.iaTextView.preferedMaxLayoutWidth = tableView.bounds.width * 0.74
        return cell.contentView.systemLayoutSizeFittingSize(CGSizeMake(tableView.bounds.width, 1000), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: 200).height
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    
    func scrollToBottom(animated:Bool){
        guard let lastSection = tableView.numberOfSections - 1 as Int? where lastSection >= 0 else {return}
        guard let lastRow = tableView.numberOfRowsInSection(lastSection) - 1 as Int? where lastRow >= 0 else {return}
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRow, inSection: lastSection), atScrollPosition: .None, animated: animated)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        //tableView.
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        reloadingToWidth = size.width
        let maxDimension = max(size.width + 30,size.height + 30)
        self.gradientLayer.frame = CGRect(origin: CGPointZero,size: CGSize(width:maxDimension, height: maxDimension))
        
        coordinator.animateAlongsideTransition(nil) { (context) in
            self.reloadingToWidth = nil
            self.scrollToBottom(true)
            self.gradientLayer.frame = CGRect(origin: CGPointZero,size: CGSize(width: size.width + 40, height: size.height + 40))
        }
        tableView.reloadData()
        
    }
    
    func iaTextView(atTextView: IACompositeTextView, userInteractedWithURL URL: NSURL, inRange characterRange: NSRange) {
        UIApplication.sharedApplication().openURL(URL)
    }
    
    func iaTextView(atTextView: IACompositeTextView, userInteractedWithAttachment attachment: IATextAttachment, inRange: NSRange) {
        guard let navController = self.navigationController else {print("image viewer should be presented by nav controller"); return}
        if let imageAttachment = attachment as? IAImageAttachment where imageAttachment.image != nil {
            let imageViewer = IAImageViewerVC()
            imageViewer.attachment = imageAttachment
            navController.pushViewController(imageViewer, animated: true)
        } else if let videoAttachment = attachment as? IAVideoAttachment {
            let videoViewer = IAVideoViewerVC()
            videoViewer.attachment = videoAttachment
            navController.pushViewController(videoViewer, animated: true)
        } else if let locationAttachment = attachment as? IALocationAttachment {
            locationAttachment.mapItemForLocation().openInMapsWithLaunchOptions(nil)
        } else {
            print(attachment)
        }
    }
    
    func appendMessage(message:Message){
        messages.append(message)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: messages.count - 1, inSection: 0)], withRowAnimation: .Automatic)
    }
    
}


