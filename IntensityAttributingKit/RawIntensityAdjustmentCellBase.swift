//
//  RawIntensityAdjustmentCellBase.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/14/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///Abstract cell type used in the RawIntensity param adjustment cells.
class RawIntensityAdjustmentCellBase: UITableViewCell {

    var itemDescriptionLabel:UILabel!
    
    var contentStackView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    init(){
        super.init(style: .Default, reuseIdentifier: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        itemDescriptionLabel = UILabel(frame: CGRectZero)
        itemDescriptionLabel.numberOfLines = 0

        itemDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutMargins = UIEdgeInsetsMake(4.0, 8.0, 8.0, 4.0)
        contentStackView = UIStackView(arrangedSubviews: [itemDescriptionLabel])
        contentStackView.frame = CGRectMake(0, 0, 300, 20)
        contentStackView.spacing = 5.0
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .Vertical
        self.contentView.addSubview(contentStackView)
        
        contentStackView.topAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.topAnchor, constant: 0).active = true
        contentStackView.leadingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.leadingAnchor).active = true
        contentStackView.trailingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.trailingAnchor).active = true
        contentStackView.bottomAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.bottomAnchor).active = true

    }
    
    
    
}
