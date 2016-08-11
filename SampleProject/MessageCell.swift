//
//  MessageCell.swift
//  IntensityMessaging
//
//  Created by Evan Mckee on 11/20/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit
import IntensityAttributingKit

class MessageCell: UITableViewCell {

    var iaTextView:IACompositeTextView!
    var dateLabel:UILabel!
    
    var displayMode:DisplayMode! {
        didSet{
            if displayMode != nil {
                switch displayMode! {
                case .Sending: self.setForSending()
                case .Receiving: self.setForReceiving()
                }
            }
        }
    }
    
    static let kVerticalInsets:CGFloat = 4.0
    static let kHorizontalInsets:CGFloat = 4.0
    
    private var receiverConstraints:[NSLayoutConstraint] = []
    private var senderConstraints:[NSLayoutConstraint] = []
    
    
    override init(style:UITableViewCellStyle, reuseIdentifier:String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    init(reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    
    
    func setupCell(){
        iaTextView = IACompositeTextView(frame: CGRectZero)

        iaTextView.translatesAutoresizingMaskIntoConstraints = false
        iaTextView.selectable = true
        self.contentView.addSubview(iaTextView)
        
        dateLabel = UILabel()
        dateLabel.textAlignment = .Center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .Center
        dateLabel.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(dateLabel)
        
        //universal constraints
        iaTextView.topAnchor.constraintEqualToAnchor(self.contentView.topAnchor, constant: MessageCell.kVerticalInsets).active = true
        contentView.bottomAnchor.constraintEqualToAnchor(iaTextView.bottomAnchor, constant: MessageCell.kVerticalInsets).active = true
        dateLabel.bottomAnchor.constraintEqualToAnchor(self.contentView.bottomAnchor, constant: -MessageCell.kVerticalInsets).active = true

        iaTextView.widthAnchor.constraintGreaterThanOrEqualToConstant(50.0).active = true
        iaTextView.heightAnchor.constraintGreaterThanOrEqualToConstant(40.0).active = true

        iaTextView.setContentHuggingPriority(251, forAxis: .Vertical)
        iaTextView.setContentHuggingPriority(251, forAxis: .Horizontal)
        dateLabel.setContentCompressionResistancePriority(901, forAxis: .Horizontal)
        
        iaTextView.widthAnchor.constraintLessThanOrEqualToAnchor(self.contentView.widthAnchor, multiplier: 0.75).active = true
        dateLabel.widthAnchor.constraintLessThanOrEqualToAnchor(self.contentView.widthAnchor, multiplier: 0.25).active = true
        
        //RecConstraints
        receiverConstraints = [
            iaTextView.leadingAnchor.constraintEqualToAnchor(self.contentView.leadingAnchor, constant: MessageCell.kHorizontalInsets),
            dateLabel.trailingAnchor.constraintEqualToAnchor(self.contentView.trailingAnchor, constant: -MessageCell.kHorizontalInsets).withPriority(900)
        ]
        //Sending Constraints
        senderConstraints = [
            iaTextView.trailingAnchor.constraintEqualToAnchor(self.contentView.trailingAnchor, constant: -MessageCell.kHorizontalInsets),
            dateLabel.leadingAnchor.constraintEqualToAnchor(self.contentView.leadingAnchor, constant:  MessageCell.kHorizontalInsets).withPriority(900)
        ]
        self.selectionStyle = .None
        self.contentView.opaque = true
        iaTextView.cornerRadius = 8.0
    }
    
    func setForReceiving(){
        iaTextView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        NSLayoutConstraint.deactivateConstraints(senderConstraints)
        NSLayoutConstraint.activateConstraints(receiverConstraints)
    }
    
    func setForSending(){
        iaTextView.backgroundColor = UIColor(hue: 0.3, saturation: 0.3, brightness: 0.9, alpha: 1.0)
        NSLayoutConstraint.deactivateConstraints(receiverConstraints)
        NSLayoutConstraint.activateConstraints(senderConstraints)
        
    }
    
    static func textViewWidthForCellWidth(cellWidth:CGFloat)->CGFloat {
        return (cellWidth * 0.75) - 1.5 * kHorizontalInsets
    }

    enum DisplayMode{
        case Sending, Receiving
    }
    
}
