//
//  IASelectionView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/14/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/**
    IASelectionView is used to layer selection rects, blinking insertion carets, and marked text rects onto the IACompositeTextBase subclasses. Carets and marked text rects will display simultaneously but if the selectionRects array is non empty then the selection rects will be displayed while the caret and marked text rect will be hidden.
*/
final class IASelectionView: UIView {

    fileprivate(set) var selectionRects:[IATextSelectionRect] = []
    fileprivate(set) var caretRect:CGRect?
    fileprivate(set) var markedTextRect:CGRect?
    
    var selectionColor:UIColor = UIColor.cyan.withAlphaComponent(0.25)
    var markingColor:UIColor = UIColor.yellow.withAlphaComponent(0.22)
    var caretColor:UIColor = UIColor.blue.withAlphaComponent(0.5)
    var caretBlinks = true {
        didSet{
            self.layer.removeAnimation(forKey: "opacity")
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard !selectionRects.isEmpty || caretRect != nil || markedTextRect != nil else {return}
        if selectionRects.isEmpty {
            
            
            if markedTextRect != nil {
                markingColor.setFill()
                UIRectFill(markedTextRect!)
            }
            if caretRect != nil{
                //draw caret
                caretColor.setFill()
                UIRectFill(caretRect!)
                if caretBlinks && markedTextRect == nil{
                    self.layer.add(blinkAnimation, forKey: "opacity")
                } else {
                    self.layer.removeAnimation(forKey: "opacity")
                }
            }
        } else {
            //draw selectionRects
            self.layer.removeAnimation(forKey: "opacity")
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
    func updateSelections(_ rawSelectionRects:[CGRect], caretRect:CGRect?, markEnds:Bool){
        self.selectionRects = IATextSelectionRect.generateSelectionArray(rawSelectionRects, markEnds:markEnds)
        self.markedTextRect = nil
        self.caretRect = caretRect
        if selectionRects.isEmpty && caretRect == nil {
            self.isHidden = true
        } else {
            self.isHidden = false
            self.setNeedsDisplay()
        }
    }

    ///If called without parameters then this will clear and hide the selectionView
    func updateSelections(_ selectionRects:[IATextSelectionRect] = [], caretRect:CGRect? = nil){
        self.markedTextRect = nil
        self.selectionRects = selectionRects
        self.caretRect = caretRect
        if selectionRects.isEmpty && caretRect == nil {
            self.isHidden = true
        } else {
            self.isHidden = false
            self.setNeedsDisplay()
        }
    }
    
    ///Sets markedText and caret, clears selection rects
    func setTextMarking(_ markedTextRect:CGRect?,caretRect:CGRect?){
        selectionRects = []
        self.markedTextRect = markedTextRect
        self.caretRect = caretRect
        if self.markedTextRect == nil && caretRect == nil {
            self.isHidden = true
            
        } else {
            self.isHidden = false
            self.setNeedsDisplay()
        }
    }
    
    func hideCursor(){
        if self.caretRect != nil {
            caretRect = nil
            if selectionRects.isEmpty && markedTextRect == nil{
                self.isHidden = true
            } else {
                self.setNeedsDisplay()
            }
        }
    }
    
    ///clears selection rects, caret, and hides
    func clearSelection(){
        selectionRects = []
        caretRect = nil
        markedTextRect = nil
        layer.removeAnimation(forKey: "opacity")
        self.isHidden = true
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(){
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let sc = aDecoder.decodeObject(forKey: "selectionColor") as? UIColor {
            selectionColor = sc
        }
        if let cb = aDecoder.decodeObject(forKey: "caretBlinks") as? Bool {
            caretBlinks = cb
        }
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(selectionColor, forKey: "selectionColor")
        aCoder.encode(caretBlinks, forKey: "caretBlinks")
    }

}
