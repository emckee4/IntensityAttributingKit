//
//  IASelectionView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/14/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

final class IASelectionView: UIView {


    //private(set) var selectionRects:[CGRect] = []
    private(set) var selectionRects:[IATextSelectionRect] = []
    private(set) var caretRect:CGRect?
    
    
    var selectionColor:UIColor = UIColor.cyanColor().colorWithAlphaComponent(0.3)
    var caretColor:UIColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
    var caretBlinks = true {
        didSet{
            self.layer.removeAnimationForKey("opacity")
        }
    }
    
    
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard !selectionRects.isEmpty || caretRect != nil else {return}
        if selectionRects.isEmpty && caretRect != nil{
            //draw caret
            caretColor.setFill()
            UIRectFill(caretRect!)
            if caretBlinks {
                self.layer.addAnimation(blinkAnimation, forKey: "opacity")
            } else {
                self.layer.removeAnimationForKey("opacity")
            }
        } else {
            //draw selectionRects
            self.layer.removeAnimationForKey("opacity")
            selectionColor.setFill()
            for sr in selectionRects {
                UIRectFill(sr.rect)
            }
        }
    }
    
    let blinkAnimation:CABasicAnimation = {
        let caretBlink = CABasicAnimation(keyPath: "opacity")
        caretBlink.fromValue = 1.0
        caretBlink.toValue = 0.4
        caretBlink.repeatCount = 99999
        caretBlink.duration = 0.75
        caretBlink.autoreverses = true
        return caretBlink
    }()
    
    ///Use this to update selectionRects and caretRect. This may mark the entire view as hidden if nothing is selected or unhide itself if something is selected.
    func updateSelections(rawSelectionRects:[CGRect], caretRect:CGRect?, markEnds:Bool){
        self.selectionRects = IATextSelectionRect.generateSelectionArray(rawSelectionRects, markEnds:markEnds)
        self.caretRect = caretRect
        if selectionRects.isEmpty && caretRect == nil {
            self.hidden = true
        } else {
            self.hidden = false
            self.setNeedsDisplay()
        }
    }

    ///If called without parameters then this will clear and hide the selectionView
    func updateSelections(selectionRects:[IATextSelectionRect] = [], caretRect:CGRect? = nil){
        self.selectionRects = selectionRects
        self.caretRect = caretRect
        if selectionRects.isEmpty && caretRect == nil {
            self.hidden = true
        } else {
            self.hidden = false
            self.setNeedsDisplay()
        }
    }
    
    func hideCursor(){
        if self.caretRect != nil {
            caretRect = nil
            if selectionRects.isEmpty {
                self.hidden = true
            } else {
                self.setNeedsDisplay()
            }
        }
    }
    
    ///clears selection rects, caret, and hides
    func clearSelection(){
        selectionRects = []
        caretRect = nil
        layer.removeAnimationForKey("opaciy")
        self.hidden = true
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(){
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let sc = aDecoder.decodeObjectForKey("selectionColor") as? UIColor {
            selectionColor = sc
        }
        if let cb = aDecoder.decodeObjectForKey("caretBlinks") as? Bool {
            caretBlinks = cb
        }
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(selectionColor, forKey: "selectionColor")
        aCoder.encodeObject(caretBlinks, forKey: "caretBlinks")
    }

}
