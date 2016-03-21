//
//  SuggestionBarView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/18/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

class SuggestionBarView: UIView, PressureKeyActionDelegate {

    private(set) var suggestions:[String] = []

    weak var delegate:SuggestionBarDelegate?
    
    private(set)var pressureKeys:[PressureKey]!
    private(set)var stackView:UIStackView!
    
    override var bounds:CGRect{
        didSet{
            layoutForBounds(bounds)
            if bounds.width != oldValue.width {
                ///This ensures that the correct number of suggestions are displayed
                //updateSuggestions(suggestions)
            }
        }
    }
    
    var visibleCellCount:Int {return pressureKeys.reduce(0, combine: {$0 + ($1.hidden ? 0 : 1)})}
    
    ///updates the displayed suggestions options. The supplied suggestion array should be orderedby priority for display, with the best suggestions first.
    func updateSuggestions(newSuggestions:[String]){
        suggestions = newSuggestions
        for pk in pressureKeys {
            //guard !pk.hidden else {continue}
            if pk.tag < newSuggestions.count {
                pk.setCharKey(newSuggestions[pk.tag])
            } else {
                pk.setCharKey("")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.lightGrayColor()
        pressureKeys = []
        let maxNumberKeys = Int(max(UIScreen.mainScreen().bounds.height,UIScreen.mainScreen().bounds.width)) / 120
        for i in 0..<maxNumberKeys{
            let pk = PressureKey()
            pk.delegate = self
            pressureKeys.append(pk)
            pk.tag = i
            pk.translatesAutoresizingMaskIntoConstraints = false
        }
     
        
        stackView = UIStackView(arrangedSubviews: pressureKeys)
        self.addSubview(stackView)
        stackView.topAnchor.constraintEqualToAnchor(self.topAnchor).activateWithPriority(1000)
        stackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).activateWithPriority(1000)
        stackView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).activateWithPriority(1000)
        stackView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).activateWithPriority(1000)
        stackView.distribution = .FillEqually
        stackView.alignment = .Fill
        stackView.axis = .Horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    

    
    func layoutForBounds(bounds:CGRect){
        let numberOfCellsToMakeVisible = Int(bounds.width) / 120
        guard visibleCellCount != numberOfCellsToMakeVisible else {return}
        for pk in pressureKeys {
            if pk.tag < numberOfCellsToMakeVisible {
                pk.hidden = false
            } else {
                pk.hidden = true
            }
        }
    }
    
    ///Groups all selections into a separately named function for convenience and to enable easy changing of internal implementation.
    func pressureKeyPressed(sender: PressureControl, actionName: String, intensity: Int) {
        guard actionName != "" else {return}
        self.delegate?.suggestionSelected(self, suggestionString: actionName, intensity: intensity)
    }
    
    
}


protocol SuggestionBarDelegate:class {
    func suggestionSelected(suggestionBar:SuggestionBarView!, suggestionString:String, intensity:Int)
}
