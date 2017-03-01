//
//  ToggleCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/21/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


///Configurable cell type used in the RawIntensity param adjustment cells. This one has a switch control.
class ToggleCell:UITableViewCell {
    
    var toggleControl:UISwitch!
    
    init(reuseIdentifier:String? = nil){
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(){
        toggleControl = UISwitch(frame: CGRect.zero)
        toggleControl.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(toggleControl)
        
        toggleControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        toggleControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        
    }
    
}
