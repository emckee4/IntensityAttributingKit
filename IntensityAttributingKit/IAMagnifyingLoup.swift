//
//  IAMagnifyingLoup.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 5/7/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//  Inspired by https://github.com/acoomans/iOS-MagnifyingGlass

import UIKit


/// The IAMagnifyingLoup provides a zoomed in view of a text selection caret or boundary in an IACompositeTextEditor.
final class IAMagnifyingLoup:UIView {
    
    weak var viewToMagnify:UIView?
    
    var magnificationFactor:CGFloat = 1.75
    var magnificationCenter:CGPoint?
    fileprivate(set) var magnifyerRadius:CGFloat = 35.0
    fileprivate(set) var loupCenterOffset:CGVector = CGVector(dx: 0, dy: 35)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = frame.size.width / 2
        self.layer.masksToBounds = true
        
        //self.layer.shadowRadius = 4.0
        //self.layer.shadowColor = UIColor.blackColor().CGColor
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
    }
    
    convenience init(viewToMagnify:UIView){
        self.init(frame:CGRect.zero)
        self.viewToMagnify = viewToMagnify
        self.isHidden = true
    }
    
    ///magnifies at the given point, using default radius and offset values
    func magnifyAtPoint(_ point:CGPoint){
        self.isHidden = false
        magnificationCenter = point
        layer.cornerRadius = magnifyerRadius
        frame = CGRect(x: magnificationCenter!.x - loupCenterOffset.dx - magnifyerRadius,
                           y: magnificationCenter!.y - loupCenterOffset.dy - magnifyerRadius,
                           width: magnifyerRadius * 2.0, height: magnifyerRadius * 2.0)
        setNeedsDisplay()
    }
    
    func magnifyAtPoint(_ point:CGPoint, withRadius radius:CGFloat, offset:CGVector? = nil){
        self.isHidden = false
        magnificationCenter = point
        magnifyerRadius = radius
        if let offset = offset {loupCenterOffset = offset}
        layer.cornerRadius = radius
        frame = CGRect(x: magnificationCenter!.x - loupCenterOffset.dx - magnifyerRadius,
                           y: magnificationCenter!.y - loupCenterOffset.dy - magnifyerRadius,
                           width: radius * 2.0, height: radius * 2.0)
        setNeedsDisplay()
    }
    
    
    
    override func draw(_ rect: CGRect) {
        guard magnificationCenter != nil && viewToMagnify != nil else {return}
        UIColor.white.setFill()
        UIRectFill(self.bounds)
        guard let context = UIGraphicsGetCurrentContext() else {return}
        context.translateBy(x: -magnificationCenter!.x * magnificationFactor + magnifyerRadius, y: -magnificationCenter!.y * magnificationFactor + magnifyerRadius )
        context.scaleBy(x: magnificationFactor, y: magnificationFactor)
        //viewToMagnify!.layer.renderInContext(context!)
        viewToMagnify!.drawHierarchy(in: viewToMagnify!.bounds, afterScreenUpdates: true)
    }
    
    
    
}






