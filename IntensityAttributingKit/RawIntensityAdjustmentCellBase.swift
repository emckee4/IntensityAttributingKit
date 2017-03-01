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
        super.init(style: .default, reuseIdentifier: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        itemDescriptionLabel = UILabel(frame: CGRect.zero)
        itemDescriptionLabel.numberOfLines = 0

        itemDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutMargins = UIEdgeInsetsMake(4.0, 8.0, 8.0, 4.0)
        contentStackView = UIStackView(arrangedSubviews: [itemDescriptionLabel])
        contentStackView.frame = CGRect(x: 0, y: 0, width: 300, height: 20)
        contentStackView.spacing = 5.0
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        self.contentView.addSubview(contentStackView)
        
        contentStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
        contentStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true

    }
    
    
    
}
