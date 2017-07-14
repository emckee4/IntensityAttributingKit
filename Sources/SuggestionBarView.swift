//
//  SuggestionBarView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/18/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/**
Provides an interface for displaying and selecting suggestions on and as provided by the IAKeyboard. The SuggestionBarView is able to provide intensity data because it's actually an array of PressureKey's, though it acts as the delegate to those keys and packages events received into its own SuggestionBarDelegate.
*/
class SuggestionBarView: UIView, PressureKeyActionDelegate {

    fileprivate(set) var suggestions:[String] = []

    weak var delegate:SuggestionBarDelegate?
    
    fileprivate(set)var pressureKeys:[PressureKey]!
    fileprivate(set)var stackView:UIStackView!
    
    var textColor:UIColor? {
        didSet{if textColor != nil {
            _ = pressureKeys.map({$0.textColor = textColor})
            }
        }
    }
    override var backgroundColor: UIColor? {
        didSet {
            _ = pressureKeys.map({$0.backgroundColor = backgroundColor})
        }
    }
    
    var visibleCellCount:Int {return pressureKeys.reduce(0, {$0 + ($1.isHidden ? 0 : 1)})}
    
    ///updates the displayed suggestions options. The supplied suggestion array should be orderedby priority for display, with the best suggestions first.
    func updateSuggestions(_ newSuggestions:[String]){
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
//        self.backgroundColor = UIColor.lightGrayColor()
        pressureKeys = []
        let maxNumberKeys = Int(max(UIScreen.main.bounds.height,UIScreen.main.bounds.width)) / 120
        for i in 0..<maxNumberKeys{
            let pk = PressureKey()
            pk.delegate = self
            pressureKeys.append(pk)
            pk.tag = i
            pk.translatesAutoresizingMaskIntoConstraints = false
            if self.backgroundColor != nil {
                pk.backgroundColor = self.backgroundColor
            }
            if self.textColor != nil {
                pk.textColor = self.textColor
            }
        }
     
        
        stackView = UIStackView(arrangedSubviews: pressureKeys)
        self.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.topAnchor).activateWithPriority(1000)
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).activateWithPriority(1000)
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).activateWithPriority(1000)
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).activateWithPriority(1000)
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        let numberOfCellsToMakeVisible = Int(bounds.width) / 120
        if visibleCellCount != numberOfCellsToMakeVisible {
            for pk in pressureKeys {
                if pk.tag < numberOfCellsToMakeVisible {
                    pk.isHidden = false
                } else {
                    pk.isHidden = true
                }
            }
        }
        super.layoutSubviews()
    }
    
    ///Groups all selections into a separately named function for convenience and to enable easy changing of internal implementation.
    func pressureKeyPressed(_ sender: PressureControl, actionName: String, intensity: Int) {
        guard actionName != "" else {return}
        self.delegate?.suggestionSelected(self, suggestionString: actionName, intensity: intensity)
    }
    
    
}


protocol SuggestionBarDelegate:class {
    func suggestionSelected(_ suggestionBar:SuggestionBarView!, suggestionString:String, intensity:Int)
}
