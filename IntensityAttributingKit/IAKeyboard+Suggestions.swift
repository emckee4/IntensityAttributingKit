//
//  IAKeyboard+Suggestions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/21/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


extension IAKeyboard:SuggestionBarDelegate {
    
    
    var suggestionBarActive:Bool {
        get{return !suggestionsBar.hidden}
        set{suggestionsBar.hidden = !newValue}
    }
    
    func updateSuggestions(newSuggestions: [String]){
        guard !suggestionsBar.hidden else {return}
        suggestionsBar.updateSuggestions(newSuggestions)
    }
    
    func suggestionSelected(suggestionBar: SuggestionBarView!, suggestionString: String, intensity: Int) {
        self.delegate?.iaKeyboard(self, suggestionSelected: suggestionString, intensity: intensity)
    }
    
}