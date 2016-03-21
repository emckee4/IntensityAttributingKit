//
//  SpellCheckToggleCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/21/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

class SpellCheckToggleCell: ToggleCell {

    
    
    override func setupCell(){
        super.setupCell()
        
        toggleControl.addTarget(self, action: "toggleValueChanged:", forControlEvents: .ValueChanged)
        self.textLabel?.text = "Word Suggestions"
        toggleControl.on = IAKitOptions.spellingSuggestionsEnabled
    }

    func toggleValueChanged(sender:UISwitch!){
        IAKitOptions.spellingSuggestionsEnabled = toggleControl.on
    }
    
}
