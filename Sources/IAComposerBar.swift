//
//  IAComposerBar.swift
//  IntensityMessaging
//
//  Created by Evan Mckee on 12/2/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

public class IAComposerBar: UIView {
    
    public var textEditor:IACompositeTextEditor!
    public var sendButton:ExpandingKeyControl!
    public var progressView:UIProgressView!
    public weak var delegate:IAComposerBarDelegate?
    public var composerBarBib:UIView!
    
    public override var bounds: CGRect {
        didSet {if bounds.size.height != oldValue.size.height {
            delegate?.composerBarHeightChanged()
            }
        }
    }
    
    public override var backgroundColor: UIColor? {
        didSet{composerBarBib.backgroundColor = backgroundColor}
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupBar()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBar()
    }
    
    func setupBar(){
        textEditor = IACompositeTextEditor(frame:CGRect.zero)
        sendButton = ExpandingKeyControl(expansionDirection: .up)
        sendButton.backgroundColor = UIColor.clear
        sendButton.cornerRadius = 4.0
        
        self.addSubview(textEditor)
        self.addSubview(sendButton)
        
        
        self.translatesAutoresizingMaskIntoConstraints = false
        textEditor.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        //need constraints: needs to expand (weak resistance to expansion) up until some limit
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0).isActive = true
        
        textEditor.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5.0).isActive = true
        textEditor.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -5.0).isActive = true
        textEditor.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.0).isActive = true
        textEditor.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.0).isActive = true
        
        sendButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5.0).isActive = true
        sendButton.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor, constant: -4).isActive = true
        sendButton.heightAnchor.constraint(lessThanOrEqualToConstant: 40.0).isActive = true
        let topAnchor = sendButton.topAnchor.constraint(equalTo: self.topAnchor, constant: -2.0)
        topAnchor.priority = 500
        topAnchor.isActive = true
        
        sendButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.0).isActive = true
        
        progressView = UIProgressView()
        progressView.isHidden = true
        progressView.progress = 0.0
        self.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        progressView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        composerBarBib = UIView()
        composerBarBib.translatesAutoresizingMaskIntoConstraints = false
        composerBarBib.backgroundColor = self.backgroundColor
        self.insertSubview(composerBarBib, at: 0)
        composerBarBib.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        composerBarBib.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 50).isActive = true
        composerBarBib.leftAnchor.constraint(equalTo: self.leftAnchor, constant: -60).isActive = true
        composerBarBib.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 60).isActive = true
    }
    
    
}

public protocol IAComposerBarDelegate:class {
    func composerBarHeightChanged()
}
