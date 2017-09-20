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
                case .sending: self.setForSending()
                case .receiving: self.setForReceiving()
                }
            }
        }
    }
    
    static let kVerticalInsets:CGFloat = 4.0
    static let kHorizontalInsets:CGFloat = 4.0
    
    fileprivate var receiverConstraints:[NSLayoutConstraint] = []
    fileprivate var senderConstraints:[NSLayoutConstraint] = []
    
    
    override init(style:UITableViewCellStyle, reuseIdentifier:String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
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
        iaTextView = IACompositeTextView(frame: CGRect.zero)

        iaTextView.translatesAutoresizingMaskIntoConstraints = false
        iaTextView.selectable = true
        self.contentView.addSubview(iaTextView)
        
        dateLabel = UILabel()
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .center
        dateLabel.backgroundColor = UIColor.white
        self.contentView.addSubview(dateLabel)
        
        //universal constraints
        iaTextView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: MessageCell.kVerticalInsets).isActive = true
        contentView.bottomAnchor.constraint(equalTo: iaTextView.bottomAnchor, constant: MessageCell.kVerticalInsets).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -MessageCell.kVerticalInsets).isActive = true

        iaTextView.widthAnchor.constraint(greaterThanOrEqualToConstant: 50.0).isActive = true
        iaTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0).isActive = true

        iaTextView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .vertical)
        iaTextView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 901), for: .horizontal)
        
        iaTextView.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.75).isActive = true
        dateLabel.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.25).isActive = true
        
        //RecConstraints
        receiverConstraints = [
            iaTextView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: MessageCell.kHorizontalInsets),
            dateLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -MessageCell.kHorizontalInsets).withPriority(900)
        ]
        //Sending Constraints
        senderConstraints = [
            iaTextView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -MessageCell.kHorizontalInsets),
            dateLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:  MessageCell.kHorizontalInsets).withPriority(900)
        ]
        self.selectionStyle = .none
        self.contentView.isOpaque = true
        iaTextView.cornerRadius = 8.0
    }
    
    func setForReceiving(){
        iaTextView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        NSLayoutConstraint.deactivate(senderConstraints)
        NSLayoutConstraint.activate(receiverConstraints)
    }
    
    func setForSending(){
        iaTextView.backgroundColor = UIColor(hue: 0.3, saturation: 0.3, brightness: 0.9, alpha: 1.0)
        NSLayoutConstraint.deactivate(receiverConstraints)
        NSLayoutConstraint.activate(senderConstraints)
        
    }
    
    static func textViewWidthForCellWidth(_ cellWidth:CGFloat)->CGFloat {
        return (cellWidth * 0.75) - 1.5 * kHorizontalInsets
    }

    enum DisplayMode{
        case sending, receiving
    }
    
}
