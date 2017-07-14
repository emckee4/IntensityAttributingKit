//
//  SpellCheckToggleCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/21/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///Prebaked tableview cell for enabling/disabling the suggestion bar in the IAKeyboard.
class SpellCheckToggleCell: ToggleCell {

    
    override func setupCell(){
        super.setupCell()
        
        toggleControl.addTarget(self, action: #selector(SpellCheckToggleCell.toggleValueChanged(_:)), for: .valueChanged)
        self.textLabel?.text = "Word Suggestions"
        toggleControl.isOn = IAKitPreferences.spellingSuggestionsEnabled
    }

    func toggleValueChanged(_ sender:UISwitch!){
        IAKitPreferences.spellingSuggestionsEnabled = toggleControl.isOn
    }
    
}
