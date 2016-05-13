//
//  IAMagnifyingLoup.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 5/7/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//  Inspired by https://github.com/acoomans/iOS-MagnifyingGlass

import UIKit



class IAMagnifyingLoup:UIView {
    
    weak var viewToMagnify:UIView?
    
    var magnificationFactor:CGFloat = 1.75
    var magnificationCenter:CGPoint?
    private(set) var magnifyerRadius:CGFloat = 35.0
    private(set) var loupCenterOffset:CGVector = CGVectorMake(0, 35)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = frame.size.width / 2
        self.layer.masksToBounds = true
        
        //self.layer.shadowRadius = 4.0
        //self.layer.shadowColor = UIColor.blackColor().CGColor
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
    }
    
    convenience init(viewToMagnify:UIView){
        self.init(frame:CGRectZero)
        self.viewToMagnify = viewToMagnify
        self.hidden = true
    }
    
    ///magnifies at the given point, using default radius and offset values
    func magnifyAtPoint(point:CGPoint){
        self.hidden = false
        magnificationCenter = point
        layer.cornerRadius = magnifyerRadius
        frame = CGRectMake(magnificationCenter!.x - loupCenterOffset.dx - magnifyerRadius,
                           magnificationCenter!.y - loupCenterOffset.dy - magnifyerRadius,
                           magnifyerRadius * 2.0, magnifyerRadius * 2.0)
        setNeedsDisplay()
    }
    
    func magnifyAtPoint(point:CGPoint, withRadius radius:CGFloat, offset:CGVector? = nil){
        self.hidden = false
        magnificationCenter = point
        magnifyerRadius = radius
        if let offset = offset {loupCenterOffset = offset}
        layer.cornerRadius = radius
        frame = CGRectMake(magnificationCenter!.x - loupCenterOffset.dx - magnifyerRadius,
                           magnificationCenter!.y - loupCenterOffset.dy - magnifyerRadius,
                           radius * 2.0, radius * 2.0)
        setNeedsDisplay()
    }
    
    
    
    override func drawRect(rect: CGRect) {
        guard magnificationCenter != nil && viewToMagnify != nil else {return}
        UIColor.whiteColor().setFill()
        UIRectFill(self.bounds)
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, -magnificationCenter!.x * magnificationFactor + magnifyerRadius, -magnificationCenter!.y * magnificationFactor + magnifyerRadius )
        CGContextScaleCTM(context, magnificationFactor, magnificationFactor)
        //viewToMagnify!.layer.renderInContext(context!)
        viewToMagnify!.drawViewHierarchyInRect(viewToMagnify!.bounds, afterScreenUpdates: true)
    }
    
    
    
}






