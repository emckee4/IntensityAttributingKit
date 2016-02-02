//
//  IAStringViewer.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/30/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

class IAStringViewer: UIView {

    var textContainer:NSTextContainer
    
    override init(frame: CGRect) {
        self.textContainer = NSTextContainer(size: frame.size)
        //TODO: add insets
        super.init(frame: frame)
        self.layer.borderColor = UIColor.redColor().CGColor
        self.layer.borderWidth = 2.0
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setIAString(iaString:IAString){
        let nsAttString = iaString.convertToNSAttributedString()
        
        
    }
    
}










