//
//  ExpandingKeyBase.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/8/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/**
Abstract base class for ExpandingKeyControl and ExpandingPressureControl which provides all the common elements for the two but leaves the notifications/delegate calls/selector calls to its subclasses.
 
 Future changes:
 Add animation by animating frame expansion prior to expanding constraints to match.
 Consider giving leway on out of bounds presses
 -Expand in two directions: L shaped expansion like multi keys on the ios system keyboard.

*/
public class ExpandingKeyBase: UIView {
    
    private(set) public var isExpanded = false
    
    
    ///this is private set until means for reordering the subviews are added
    @IBInspectable public var expansionDirection:EKDirection = .Up {
        didSet{
            if oldValue.hasForwardLayoutDirection != expansionDirection.hasForwardLayoutDirection && !epKeys.isEmpty{
                layoutKeysForExpansionDirection()
            }
            self.containedStackView.axis = expansionDirection.axis
        }
    }
    
    @IBInspectable public var cornerRadius:CGFloat = 0.0 {
        didSet{self.layer.cornerRadius = cornerRadius; _ = epKeys.map({$0.view.layer.cornerRadius = cornerRadius})}
    }
    
    ///This is the stack view which is actually displayed, holding all of the subviews which are acting as buttons.
    private var containedStackView:UIStackView!
    
    private var topSVConstraint:NSLayoutConstraint!
    private var leftSVConstraint:NSLayoutConstraint!
    private var rightSVConstraint:NSLayoutConstraint!
    private var bottomSVConstraint:NSLayoutConstraint!
    
    
    internal var epKeys:[EPKey] = []
    internal var selectedEPKey:EPKey? {
        didSet {
            highlightSelectedEPKey()
        }
    }
    
    override public var backgroundColor:UIColor?{
        didSet {_ = epKeys.map({$0.view.backgroundColor = self.backgroundColor})}
    }
    ///Background color for selected cell. On PressureSensitive subclasses this will be the color which indicates 100% pressure.
    @IBInspectable public var selectionColor:UIColor?
    
    ///This is the default text color when none is provided otherwise. Setting this after providing a color to an individual label based cell (e.g. via an NSAttributedString) will overwrite that textColor.
    public var textColor: UIColor = UIColor.blackColor(){
        didSet{
            guard textColor != oldValue else {return}
            for key in epKeys {
                if let lab = key.view as? UILabel {
                    lab.textColor = textColor
                }
            }
        }
    }
    
    ///When a key is selected it will automatically become the first/primary key
    public var selectedBecomesFirst = false
    
    
    //MARK:- inits
    
    init(){
        super.init(frame:CGRectZero)
        postInitSetup()
    }
    
    public init(expansionDirection:EKDirection){
        super.init(frame:CGRectZero)
        self.expansionDirection = expansionDirection
        postInitSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        postInitSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInitSetup()
    }
    
    private func postInitSetup(){
        containedStackView = UIStackView()
        containedStackView.axis = (expansionDirection == .Up || expansionDirection == .Down) ? .Vertical : .Horizontal
        containedStackView.distribution = .FillEqually
        containedStackView.alignment = .Fill
        containedStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containedStackView)
        
        
        topSVConstraint = containedStackView.topAnchor.constraintEqualToAnchor(self.topAnchor).activateWithPriority(999, identifier: "ExpandingKey.topSVConstraint")
        bottomSVConstraint = containedStackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).activateWithPriority(999, identifier: "ExpandingKey.bottomSVConstraint")
        leftSVConstraint = containedStackView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).activateWithPriority(1000, identifier: "ExpandingKey.leftSVConstraint")
        rightSVConstraint = containedStackView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).activateWithPriority(1000, identifier: "ExpandingKey.rightSVConstraint")
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.multipleTouchEnabled = false
        
    }
    
    
    
    ///This should be overriden in the intensity registering subclass. It just returns selectionColor (or darkGrey) otherwise
    internal func bgColorForSelection()->UIColor{
        guard selectionColor != nil else {return UIColor.darkGrayColor()}
        return selectionColor!
    }
    
    
    ///Updates highlighting for selected and unselected keys
    private func highlightSelectedEPKey(){
        if selectedEPKey != nil {
            for pk in epKeys {
                if pk == self.selectedEPKey! {
                    pk.view.backgroundColor = bgColorForSelection()
                } else if pk.view.backgroundColor != self.backgroundColor {
                    pk.view.backgroundColor = self.backgroundColor
                }
            }
        } else {
            _ = epKeys.map({ $0.view.backgroundColor = self.backgroundColor })
        }
    }
    
    //MARK:- Layout and view ordering helpers
    
    override public func intrinsicContentSize() -> CGSize {
        //TODO: consider calculating and storing ics in epk upon initialization. Maybe include an option in the initializer to indicate that the view will not change size after creation and if all have this then just return a precalculated value
        var maxWidth:CGFloat = 0
        var maxHeight:CGFloat = 0
        for ics in self.epKeys.map({$0.view.intrinsicContentSize()}) {
            maxWidth = max(ics.width, maxWidth)
            maxHeight = max(ics.height, maxHeight)
        }
        return CGSize(width: maxWidth, height: maxHeight)
    }
    
    
    ///Reorders keys in the stackview to match the order in the epKeys array, subject to reversal if the expansion direction is not one with forward ordered layout.
    internal func layoutKeysForExpansionDirection(){
        if expansionDirection.hasForwardLayoutDirection {
            for (i,epkey) in self.epKeys.enumerate() {
                if epkey.view != containedStackView.arrangedSubviews[i] {
                    containedStackView.insertArrangedSubview(epkey.view, atIndex: i)
                    assert(containedStackView.arrangedSubviews.count == containedStackView.subviews.count   )
                }
            }
        } else {
            for (i,epkey) in self.epKeys.reverse().enumerate() {
                if epkey.view != containedStackView.arrangedSubviews[i] {
                    //containedStackView.removeArrangedSubview(epkey.view)
                    containedStackView.insertArrangedSubview(epkey.view, atIndex: i)
                    assert(containedStackView.arrangedSubviews.count == containedStackView.subviews.count   )
                }
            }
        }
    }
    
    ///Moves the key with the actionName specified to the center most position
    public func centerKeyWithActionName(actionName:String){
        guard actionName != epKeys.first?.actionName else {return}
        for pk in epKeys{
            if pk.actionName == actionName {
                moveEPKeyToFirst(pk)
                return
            }
        }
    }
    
    ///The provided EPKey will be moved to the primary position
    internal func moveEPKeyToFirst(key:EPKey){
        for (i,pk) in epKeys.enumerate(){
            if pk.actionName == key.actionName {
                epKeys.removeAtIndex(i)
                epKeys.insert(key, atIndex: 0)
                break
            }
        }
        setHiddenForExpansionState()
        layoutKeysForExpansionDirection()
    }
    
    internal func findTouchedEPKey(touch:UITouch,event:UIEvent?)->EPKey?{
        for pk in epKeys {
            let localPoint = touch.locationInView(pk.view)
            if pk.view.pointInside(localPoint, withEvent: event){
                return pk
            }
        }
        return nil
    }
    
    
    
    //MARK:- key expansion and contraction
    
    ///selection began: expands stackview and unhides its subviews
    private func expand(){
        guard !epKeys.isEmpty else {return}
        guard !isExpanded else {return}
        isExpanded = true
        _ = epKeys.map({$0.view.layer.borderColor = UIColor.blackColor().CGColor})
        if epKeys.count > 1 {
            
            //expanding:
            switch self.expansionDirection {
            case .Up:
                self.topSVConstraint.constant = -(self.bounds.height * (CGFloat(self.epKeys.count) - 1.0))
            case .Down:
                self.bottomSVConstraint.constant = (self.bounds.height * (CGFloat(self.epKeys.count) - 1.0))
            case .Left:
                self.leftSVConstraint.constant = -(self.bounds.width * (CGFloat(self.epKeys.count) - 1.0))
            case .Right:
                self.rightSVConstraint.constant = (self.bounds.width * (CGFloat(self.epKeys.count) - 1.0))
            }

            //Revealing:
            setHiddenForExpansionState()
        }
        
    }
    
    ///selection ended: return stackview to its original size, hiding all of its subviews except the one at epKeys[0]
    private func shrinkView(){
        guard isExpanded else {return}
        isExpanded = false
        
        //border color
        _ = epKeys.map({$0.view.layer.borderColor = UIColor.clearColor().CGColor})
        
        //hiding:
        setHiddenForExpansionState()
        
        //Shrinking:
        switch self.expansionDirection {
        case .Up:
            self.topSVConstraint.constant = 0.0
        case .Down:
            self.bottomSVConstraint.constant = 0.0
        case .Left:
            self.leftSVConstraint.constant = 0.0
        case .Right:
            self.rightSVConstraint.constant = 0.0
        }
    }
    
    private func setHiddenForExpansionState(){
        if isExpanded {
            for pk in self.epKeys[0..<self.epKeys.count]{
                pk.hidden = false
            }
        } else {
            self.epKeys.first?.hidden = false
            for pk in self.epKeys[1..<self.epKeys.count] {
                pk.hidden = true
            }
        }
    }
    
    /////////////////////////
    //Adding/removing keys
    
    public func addKey(keyView:UIView, actionName name:String){
        guard !containedStackView.arrangedSubviews.contains(keyView) else {return}
        guard !(epKeys.map({$0.actionName == name}).contains(true)) else {return}
        let stackIndex = epKeys.count
        epKeys.append(EPKey(view: keyView, actionName: name))
        keyView.hidden = stackIndex != 0
        
        if expansionDirection == .Down || expansionDirection == .Right {
            containedStackView.addArrangedSubview(keyView)
        } else {
            containedStackView.insertArrangedSubview(keyView, atIndex: 0)
        }
        keyView.translatesAutoresizingMaskIntoConstraints = false
        keyView.clipsToBounds = true
        keyView.layer.cornerRadius = self.cornerRadius
        keyView.layer.borderWidth = 1.0
        keyView.layer.borderColor = UIColor.clearColor().CGColor
        keyView.backgroundColor = self.backgroundColor
    }
    
    public func addKey(withTextLabel text:String, withFont font:UIFont=UIFont.systemFontOfSize(20.0), actionName: String){
        guard !(epKeys.map({$0.actionName == actionName}).contains(true)) else {return}
        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        label.font = font
        label.textColor = self.textColor
        self.addKey(label, actionName: actionName)
    }
    
    public func addKey(withAttributedText attributedText:NSAttributedString, actionName: String){
        guard !(epKeys.map({$0.actionName == actionName}).contains(true)) else {return}
        let label = UILabel()
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        if attributedText.attribute(NSForegroundColorAttributeName, atIndex: 0, effectiveRange: nil) == nil {
            label.textColor = self.textColor
        }
        self.addKey(label, actionName: actionName)
    }
    
    public func removeKey(withActionName actionName:String){
        guard let keyIndex = epKeys.indexOf({$0.actionName == actionName}) else {return}
        let keyToRemove = epKeys.removeAtIndex(keyIndex)
        keyToRemove.view.removeFromSuperview()
//        let svIndex = containedStackView.subviews.indexOf({$0 == keyToRemove.view})
//        containedStackView.subviews.removeAtIndex(svIndex)
        self.layoutKeysForExpansionDirection()
    }
    
    
    ///Removes all keys, setting the pressureKey as empty
    public func removeAllKeys(){
        for pk in epKeys{ containedStackView.removeArrangedSubview(pk.view) }
        epKeys = []
    }
    
    
    ///Executed immediately prior to a setting call on selectedEPKey, in touchesBegan, touchesMoved, touchesEnded, and touchesCancelled. Override to implement additional non standard actions during touchesBegan.
    func keySelectionWillUpdate(withTouch touch:UITouch!, previousSelection oldKey:EPKey?, nextSelection:EPKey?){
        
    }
    ///Called immediately after selectedEPKey is updated to a non-nil value in touches ended. Override to implement additional non standard actions during touchesEnded to handle key selection.
    func handleKeySelection(selectedKey:EPKey, finalTouch:UITouch?){
        
    }
    
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        guard !epKeys.isEmpty else {return}
        //there should be one and only one touch in the touches set in touchesBegan since we have multitouch disabled
        if let touch = touches.first {
            expand()
            let newSelectedKey = findTouchedEPKey(touch, event: event)
            //handleTouchBegan(touch, onKey:newSelectedKey)
            keySelectionWillUpdate(withTouch: touch, previousSelection: nil, nextSelection: newSelectedKey)
            selectedEPKey = newSelectedKey
        }
    }
    
    
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        guard !epKeys.isEmpty else {return}
        if let touch = touches.first {
            let newSelectedKey = findTouchedEPKey(touch, event: event)
            keySelectionWillUpdate(withTouch:touch, previousSelection:selectedEPKey, nextSelection:newSelectedKey)
            if newSelectedKey == nil {
                selectedEPKey = nil
            } else if newSelectedKey?.view != selectedEPKey?.view {
                selectedEPKey = newSelectedKey
            } else {
                selectedEPKey = newSelectedKey //this value is the same but we want to trigger the didSet closure so that the background updates
            }
        }
    }
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        guard !epKeys.isEmpty else {return}
        if let touch = touches.first {
            let newSelectedKey = findTouchedEPKey(touch, event: event)
            keySelectionWillUpdate(withTouch:touch, previousSelection:selectedEPKey, nextSelection:newSelectedKey)
            if newSelectedKey?.view != selectedEPKey?.view {
                selectedEPKey = newSelectedKey
            }
            guard selectedEPKey != nil else {selectedEPKey = nil; shrinkView(); return}
            
            defer {handleKeySelection(newSelectedKey!, finalTouch: touch)}
            if selectedBecomesFirst {
                defer{
                    moveEPKeyToFirst(newSelectedKey!)
                }
            }
            
        }
        selectedEPKey = nil
        shrinkView()
    }
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("touches cancelled")
        keySelectionWillUpdate(withTouch: nil, previousSelection: selectedEPKey, nextSelection: nil)
        selectedEPKey = nil
        shrinkView()
        super.touchesCancelled(touches, withEvent: event)
    }
    
}
