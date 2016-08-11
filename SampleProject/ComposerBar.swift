//
//  ComposerBar.swift
//  IntensityMessaging
//
//  Created by Evan Mckee on 12/2/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit
import IntensityAttributingKit


class ComposerBar: UIView {
    
    var textEditor:IACompositeTextEditor!
    var sendButton:ExpandingKeyControl!
    var progressView:UIProgressView!
    weak var delegate:ComposerBarDelegate?
    
    override var bounds: CGRect {
        didSet {if bounds.size.height != oldValue.size.height {
                delegate?.composerBarHeightChanged()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBar()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBar()
    }
    
    func setupBar(){
        textEditor = IACompositeTextEditor(frame:CGRectZero)
        sendButton = ExpandingKeyControl(expansionDirection: .Up)
        sendButton.backgroundColor = UIColor.clearColor()
        sendButton.cornerRadius = 4.0
        
        self.addSubview(textEditor)
        self.addSubview(sendButton)
        
        
        self.translatesAutoresizingMaskIntoConstraints = false
        textEditor.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        //need constraints: needs to expand (weak resistance to expansion) up until some limit
        self.heightAnchor.constraintGreaterThanOrEqualToConstant(44.0).active = true
        
        textEditor.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 5.0).active = true
        textEditor.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor, constant: -5.0).active = true
        textEditor.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -2.0).active = true
        textEditor.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 2.0).active = true        
        
        sendButton.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -5.0).active = true
        sendButton.heightAnchor.constraintLessThanOrEqualToAnchor(self.heightAnchor, constant: -4).active = true
        sendButton.heightAnchor.constraintLessThanOrEqualToConstant(40.0).active = true
        let topAnchor = sendButton.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: -2.0)
        topAnchor.priority = 500
        topAnchor.active = true
        
        sendButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -2.0).active = true

        
        
        progressView = UIProgressView()
        progressView.hidden = true
        progressView.progress = 0.0
        self.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        progressView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        progressView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        
    }
    
    
}

protocol ComposerBarDelegate:class {
    func composerBarHeightChanged()
}
