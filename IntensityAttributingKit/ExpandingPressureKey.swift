//
//  ExpandingPressureKey.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/31/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


/** Configurable dropdown-like button which provides force-touch data when available.
Future changes: 
Add animation by animating frame expansion prior to expanding constraints to match.
Consider giving leway on out of bounds presses
 
Further cleanup code, consider switching back to selector based actions (or handle potential for closure related strong reference cycles). Note this may cause issues with passing of RawIntensity items since structs are pure swift. Also consider renaming "Key" based names to avoid ambiguity
*/
@IBDesignable public class ExpandingPressureKey: UIView, PressureControl {
    
    private(set) var isExpanded = false   //at moment of expansion this view should capture its bounds so it can return to its original status on completion
    //expansion direction
    
    public weak var delegate:PressureKeyAction?
    
    ///this is private set until means for reordering the subviews are added
    @IBInspectable public var expansionDirection:PKExpansionDirection = .Up {
        didSet{
            if oldValue.hasForwardLayoutDirection() != expansionDirection.hasForwardLayoutDirection() && !pressureKeys.isEmpty{
                layoutKeysForExpansionDirection()
            }
        }
    }
    @IBInspectable public var cornerRadius:CGFloat = 0.0 {
        didSet{self.layer.cornerRadius = cornerRadius; _ = pressureKeys.map({$0.view.layer.cornerRadius = cornerRadius})}
    }
    
    ///This is the stack view which is actually displayed, holding all of the subviews which are acting as buttons.
    private var containedStackView:UIStackView!
    
    private var topSVConstraint:NSLayoutConstraint!
    private var leftSVConstraint:NSLayoutConstraint!
    private var rightSVConstraint:NSLayoutConstraint!
    private var bottomSVConstraint:NSLayoutConstraint!
    
    lazy var forceTouchAvailable:Bool = {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapability.Available
    }()
    
    private var pressureKeys:[EPKey] = []
    private var selectedEPKey:EPKey? {
        didSet {
            highlightSelectedEPKey()
        }
    }
    

    
    private var touchIntensity: RawIntensity = RawIntensity()
    
    
    
    override public var backgroundColor:UIColor? {
        didSet {_ = pressureKeys.map({$0.view.backgroundColor = self.backgroundColor})}
    }
    ///Color for background of selected cell if 3dTouch (and so our dynamic selection background color) are not available
    public var nonTouchSelectionBGColor = UIColor.darkGrayColor()
    
    ///The control doesn't track RawIntensity and uses two level highlighting only
    public var intensityTrackingDisabled = false
    
    ///When a key is selected it will automatically become the first/primary key
    public var selectedBecomesFirst = false

    init(){
        super.init(frame:CGRectZero)
        postInitSetup()
    }
    
    public init(expansionDirection:PKExpansionDirection){
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
        
        
        topSVConstraint = containedStackView.topAnchor.constraintEqualToAnchor(self.topAnchor)
        topSVConstraint.active = true
        bottomSVConstraint = containedStackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor)
        bottomSVConstraint.active = true
        leftSVConstraint = containedStackView.leftAnchor.constraintEqualToAnchor(self.leftAnchor)
        leftSVConstraint.active = true
        rightSVConstraint = containedStackView.rightAnchor.constraintEqualToAnchor(self.rightAnchor)
        rightSVConstraint.active = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.multipleTouchEnabled = false
        
    }
    
    private func bgColorForSelectionIntensity()->UIColor?{
        guard backgroundColor != nil else {return nonTouchSelectionBGColor}
        ///If the device doesn't support force touch then we return darkGrey
        guard forceTouchAvailable && !intensityTrackingDisabled else {return nonTouchSelectionBGColor}
        var white:CGFloat = 0.0
        var alpha:CGFloat = 1.0
        backgroundColor!.getWhite(&white, alpha: &alpha)
        let intensity = touchIntensity.intensity
        let newAlpha:CGFloat = max(alpha * CGFloat(1 + intensity), 1.0)
        let newWhite:CGFloat = white * CGFloat(1 - intensity)
        return UIColor(white: newWhite, alpha: newAlpha)
    }
    
    ///Updates highlighting for selected and unselected keys
    private func highlightSelectedEPKey(){
        if selectedEPKey != nil {
            for pk in pressureKeys {
                if pk.view == selectedEPKey!.view {
                    pk.view.backgroundColor = bgColorForSelectionIntensity()
                } else {
                    pk.view.backgroundColor = self.backgroundColor
                }
            }
        } else {
            _ = pressureKeys.map({ $0.view.backgroundColor = self.backgroundColor })
        }
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return containedStackView.arrangedSubviews.first?.intrinsicContentSize() ?? CGSizeZero
    }
    

    public func addKey(keyView:UIView, triggeredActionName name:String, actionType:PressureKeyActionType){
        guard !containedStackView.arrangedSubviews.contains(keyView) else {return}
        guard !(pressureKeys.map({$0.actionName == name}).contains(true)) else {return}
        let stackIndex = pressureKeys.count
        pressureKeys.append(EPKey(view: keyView, actionName: name, actionType: actionType))
        keyView.hidden = stackIndex != 0
        
        if expansionDirection == .Down || expansionDirection == .Right {
            containedStackView.addArrangedSubview(keyView)
        } else {
            containedStackView.insertArrangedSubview(keyView, atIndex: 0)
        }
        keyView.clipsToBounds = true
        keyView.layer.cornerRadius = self.cornerRadius
        keyView.layer.borderWidth = 1.0
        keyView.layer.borderColor = UIColor.clearColor().CGColor
        keyView.backgroundColor = self.backgroundColor
    }
    
    
    public func addKey(withTextLabel text:String, withFont font:UIFont=UIFont.systemFontOfSize(20.0), actionName: String, actionType:PressureKeyActionType){
        guard !(pressureKeys.map({$0.actionName == actionName}).contains(true)) else {return}
        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        label.font = font
        
        let stackIndex = pressureKeys.count
        pressureKeys.append(EPKey(view: label, actionName: actionName, actionType: actionType))
        label.hidden = stackIndex != 0
        
        if expansionDirection == .Down || expansionDirection == .Right {
            containedStackView.addArrangedSubview(label)
        } else {
            containedStackView.insertArrangedSubview(label, atIndex: 0)
        }
        label.clipsToBounds = true
        label.layer.cornerRadius = self.cornerRadius
        label.backgroundColor = self.backgroundColor
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    public func addKey(withAttributedText attributedText:NSAttributedString, actionName: String, actionType:PressureKeyActionType){
        guard !(pressureKeys.map({$0.actionName == actionName}).contains(true)) else {return}
        let label = UILabel()
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        
        let stackIndex = pressureKeys.count
        pressureKeys.append(EPKey(view: label, actionName: actionName, actionType: actionType))
        label.hidden = stackIndex != 0
        
        if expansionDirection == .Down || expansionDirection == .Right {
            containedStackView.addArrangedSubview(label)
        } else {
            containedStackView.insertArrangedSubview(label, atIndex: 0)
        }
        label.clipsToBounds = true
        label.layer.cornerRadius = self.cornerRadius
        label.backgroundColor = self.backgroundColor
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    public func addCharKey(charToInsert char:String){
        guard !(pressureKeys.map({$0.actionName == char}).contains(true)) else {return}
        let label = UILabel()
        label.text = char
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(20.0)
        
        let stackIndex = pressureKeys.count
        pressureKeys.append(EPKey(view: label, actionName: char, actionType: .CharInsert))
        label.hidden = stackIndex != 0
        
        if expansionDirection == .Down || expansionDirection == .Right {
            containedStackView.addArrangedSubview(label)
        } else {
            containedStackView.insertArrangedSubview(label, atIndex: 0)
        }
        label.clipsToBounds = true
        label.layer.cornerRadius = self.cornerRadius
        label.backgroundColor = self.backgroundColor
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    public func removeAllKeys(){
        for pk in pressureKeys{ containedStackView.removeArrangedSubview(pk.view) }
        pressureKeys = []
    }
    
    ///Removes all key views from the stackview and inserts them in forward or reverse order of pressureKeys, depending on whether the expansionDirection has a forward or reverse layout
    private func layoutKeysForExpansionDirection(){
        for pk in pressureKeys {
            containedStackView.removeArrangedSubview(pk.view)
        }
        if expansionDirection.hasForwardLayoutDirection(){
            for pk in pressureKeys{
                containedStackView.addArrangedSubview(pk.view)
            }
        } else {
            for pk in pressureKeys {
                containedStackView.insertArrangedSubview(pk.view, atIndex: 0)
            }
        }
    }
    
    ///Moves the key with the actionName specified to the center most position
    public func centerKeyWithActionName(actionName:String){
        for pk in pressureKeys{
            if pk.actionName == actionName {
                moveEPKeyToFirst(pk)
                return
            }
        }
    }
    
    ///The provided EPKey will be moved to the primary position
    private func moveEPKeyToFirst(key:EPKey){
        for (i,pk) in pressureKeys.enumerate(){
            if pk.actionName == key.actionName {
                pressureKeys.removeAtIndex(i)
                pressureKeys.insert(key, atIndex: 0)
                break
            }
        }
        layoutKeysForExpansionDirection()
    }
    
    private func findTouchedEPKey(touch:UITouch,event:UIEvent?)->EPKey?{
        for pk in pressureKeys {
            let localPoint = touch.locationInView(pk.view)
            if pk.view.pointInside(localPoint, withEvent: event){
                return pk
            }
        }
        return nil
    }
    
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        guard !pressureKeys.isEmpty else {return}
        //there should be one and only one touch in the touches set in touchesBegan since we have multitouch disabled
        if let touch = touches.first {
            expand()
            if !intensityTrackingDisabled{
                touchIntensity = RawIntensity(withValue: touch.force, maximumPossibleForce: touch.maximumPossibleForce)
            }
            selectedEPKey = findTouchedEPKey(touch, event: event)
        }
        
        
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        guard !pressureKeys.isEmpty else {return}
        if let touch = touches.first {
            let newSelectedKey = findTouchedEPKey(touch, event: event)
            if newSelectedKey == nil {
                if !intensityTrackingDisabled{
                    touchIntensity.reset()
                }
                selectedEPKey = nil
            } else if newSelectedKey?.view != selectedEPKey?.view {
                if !intensityTrackingDisabled{
                    touchIntensity.reset(touch.force)
                }
                selectedEPKey = newSelectedKey
            } else {
                if !intensityTrackingDisabled {
                    touchIntensity.append(touch.force)
                }
                selectedEPKey = newSelectedKey //this value is the same but we want to trigger the didSet closure so that the background updates
            }
        }
    }
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        guard !pressureKeys.isEmpty else {return}
        if let touch = touches.first {
            if let newSelectedKey = findTouchedEPKey(touch, event: event) {
                if newSelectedKey.view == selectedEPKey?.view {
                    if !intensityTrackingDisabled{
                        touchIntensity.append(touch.force)
                    }
                } else {
                    selectedEPKey = newSelectedKey
                    if !intensityTrackingDisabled{
                        touchIntensity =  RawIntensity(withValue: touch.force, maximumPossibleForce: touch.maximumPossibleForce)
                    }
                }
                //perform closure or selector here
                if !intensityTrackingDisabled{
                    delegate?.pressureKeyPressed(self, actionName: selectedEPKey!.actionName, actionType:selectedEPKey!.actionType, intensity: touchIntensity.intensity)
                } else {
                    delegate?.pressureKeyPressed(self, actionName: selectedEPKey!.actionName, actionType:selectedEPKey!.actionType, intensity: 0.0)
                }
                if selectedBecomesFirst {
                    defer{
                        moveEPKeyToFirst(newSelectedKey)
                    }
                }
            } else {
                selectedEPKey = nil
                print("touch failed: ended on touch of non subview")
            }
        } else {
            print("touch failed: ended on nil touch")
        }
        selectedEPKey = nil
        shrinkView()
    }
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("touches cancelled")
        selectedEPKey = nil
        shrinkView()
        super.touchesCancelled(touches, withEvent: event)
        
    }

    ///selection began: expands stackview and unhides its subviews
    private func expand(){
        guard !pressureKeys.isEmpty else {return}
        guard !isExpanded else {return}
        isExpanded = true
        _ = pressureKeys.map({$0.view.layer.borderColor = UIColor.blackColor().CGColor})
        if pressureKeys.count > 1 {
            
            //note: embedded functions are used here to facilitate playing around with animation options
            
            func reveal(){
                for pk in self.pressureKeys[1..<self.pressureKeys.count]{
                    pk.hidden = false
                }
            }
            
            func expand(){
                switch self.expansionDirection {
                case .Up:
                    self.topSVConstraint.constant = -(self.bounds.height * (CGFloat(self.pressureKeys.count) - 1.0))
                case .Down:
                    self.bottomSVConstraint.constant = (self.bounds.height * (CGFloat(self.pressureKeys.count) - 1.0))
                case .Left:
                    self.leftSVConstraint.constant = -(self.bounds.width * (CGFloat(self.pressureKeys.count) - 1.0))
                case .Right:
                    self.rightSVConstraint.constant = (self.bounds.width * (CGFloat(self.pressureKeys.count) - 1.0))
                }
            }
            
            expand()
            reveal()
        }
        
    }
    
    ///selection ended: return stackview to its original size, hiding all of its subviews except the one at pressureKeys[0]
    private func shrinkView(){
        guard isExpanded else {return}
        isExpanded = false
        
        func hide(){
            for pk in self.pressureKeys[1..<self.pressureKeys.count] {
                pk.hidden = true
            }
        }
        _ = pressureKeys.map({$0.view.layer.borderColor = UIColor.clearColor().CGColor})
        
        func shrink(){
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
        
        hide()
        shrink()

    }
    

}



