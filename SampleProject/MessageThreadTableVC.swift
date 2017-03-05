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
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        
        self.tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.panGestureRecognizer.addTarget(self.parent!, action: #selector(MessageThreadViewController.pan(_:)))
        
        gv = UIView(frame: tableView.bounds)
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
        gradientLayer.colors = [UIColor.darkGray.cgColor,UIColor.purple.cgColor]
        gradientLayer.locations = [0.0,1.0]
        gv.layer.insertSublayer(gradientLayer, at: 0)
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.backgroundView = gv
        gv.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        gv.heightAnchor.constraint(equalTo: tableView.heightAnchor).isActive = true
        gv.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        gv.leftAnchor.constraint(equalTo: tableView.leftAnchor).isActive = true
        gv.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.backgroundColor = UIColor.darkGray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        cell.iaTextView.delegate = self
        let message = messages[indexPath.row]
        configureCell(cell, message: message)
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        return cell
    }
    
    func configureCell(_ cell:MessageCell, message:Message){
        cell.iaTextView.delegate = self
        if reloadingToWidth != nil {
            cell.iaTextView.preferedMaxLayoutWidth = MessageCell.textViewWidthForCellWidth(reloadingToWidth!)
        } else {
            cell.iaTextView.preferedMaxLayoutWidth = MessageCell.textViewWidthForCellWidth(self.view.bounds.width)

        }
        if message.isSender {
            cell.displayMode = MessageCell.DisplayMode.sending
        } else {
            cell.displayMode = MessageCell.DisplayMode.receiving
        }

        cell.dateLabel.text = DateConversion.adaptiveDTString(message.createdAt)

        cell.dateLabel.numberOfLines = 2
        cell.dateLabel.font = UIFont.systemFont(ofSize: 13.0)
        cell.iaTextView.setIAString(message.iaString, withCacheIdentifier: message.messageID)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        let cachedName = message.messageID + "-\(tableView.bounds.width)"
        if let height = heightCache[cachedName] {
            return height
        } else {
            return calculateHeightEstimate(message)
        }
    }
    
    ///Estimates cell height using basic math rather than calling autolayout engine
    func calculateHeightEstimate(_ message:Message)->CGFloat{
        let charCount:Int = message.iaString.length
        let attachCount:Int = message.iaString.attachmentCount
        let extraAttachWidth = (10 * attachCount)
        let baseLineCount:Int = Int(ceil(Float(charCount + extraAttachWidth) / (Float(self.tableView.bounds.width) / 15.0)))
        let adjustedLineCount:Int = max(baseLineCount - attachCount, 0)
        let tvEstimate:CGFloat = 14 + (CGFloat(adjustedLineCount) * 24) + (CGFloat(attachCount) * IAThumbSize.Medium.size.height) + (2 * MessageCell.kVerticalInsets)
        return tvEstimate
    }
    
    ///Calculates the exact height of the message cell using current tableview width
    func calculateCellHeightUsingAutoLayout(_ forMessage:Message)->CGFloat{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        configureCell(cell, message: forMessage)
        cell.iaTextView.preferedMaxLayoutWidth = tableView.bounds.width * 0.74
        return cell.contentView.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 1000), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: 200).height
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    
    func scrollToBottom(_ animated:Bool){
        guard let lastSection = tableView.numberOfSections - 1 as Int?, lastSection >= 0 else {return}
        guard let lastRow = tableView.numberOfRows(inSection: lastSection) - 1 as Int?, lastRow >= 0 else {return}
        tableView.scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .none, animated: animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //tableView.
        super.viewWillTransition(to: size, with: coordinator)
        reloadingToWidth = size.width
        let maxDimension = max(size.width + 30,size.height + 30)
        self.gradientLayer.frame = CGRect(origin: CGPoint.zero,size: CGSize(width:maxDimension, height: maxDimension))
        
        coordinator.animate(alongsideTransition: nil) { (context) in
            self.reloadingToWidth = nil
            self.scrollToBottom(true)
            self.gradientLayer.frame = CGRect(origin: CGPoint.zero,size: CGSize(width: size.width + 40, height: size.height + 40))
        }
        tableView.reloadData()
        
    }
    
    func iaTextView(_ atTextView: IACompositeTextView, userInteractedWithURL URL: Foundation.URL, inRange characterRange: NSRange) {
        UIApplication.shared.open(URL, options: [UIApplicationOpenURLOptionUniversalLinksOnly: false], completionHandler: nil)
    }
    
    func iaTextView(_ atTextView: IACompositeTextView, userInteractedWithAttachment attachment: IATextAttachment, inRange: NSRange) {
        guard let navController = self.navigationController else {print("image viewer should be presented by nav controller"); return}
        if let imageAttachment = attachment as? IAImageAttachment, imageAttachment.image != nil {
            let imageViewer = IAImageViewerVC()
            imageViewer.attachment = imageAttachment
            navController.pushViewController(imageViewer, animated: true)
        } else if let videoAttachment = attachment as? IAVideoAttachment {
            let videoViewer = IAVideoViewerVC()
            videoViewer.attachment = videoAttachment
            navController.pushViewController(videoViewer, animated: true)
        } else if let locationAttachment = attachment as? IALocationAttachment {
            locationAttachment.mapItemForLocation().openInMaps(launchOptions: nil)
        } else {
            print(attachment)
        }
    }
    
    func appendMessage(_ message:Message){
        messages.append(message)
        tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .automatic)
    }
    
}


