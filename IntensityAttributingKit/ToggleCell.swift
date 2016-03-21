//
//  ToggleCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/21/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


class ToggleCell:UITableViewCell {
    
    var toggleControl:UISwitch!
    
    init(reuseIdentifier:String? = nil){
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        setupCell()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(){
        toggleControl = UISwitch(frame: CGRectZero)
        toggleControl.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(toggleControl)
        
        toggleControl.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
        toggleControl.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -8).active = true
        
    }
    
}
