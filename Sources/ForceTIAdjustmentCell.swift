//
//  ForceTIAdjustmentCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/15/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///Prebaked tableview cell for adjusting the RawIntensity parameters within the keyboard options menu or otherwise.
final class ForceTIAdjustmentCell:RawIntensityAdjustmentCellBase {

    
    override init() {
        super.init()
        self.itemDescriptionLabel.text = "Intensity is determined by the screen pressure of a keypress. Available on 6s/6s Plus devices."
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
