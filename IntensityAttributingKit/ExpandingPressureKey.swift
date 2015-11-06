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
Give option for dynamicly reordering keys so that the last pressed will become the default key
 
Further cleanup code, consider switching back to selector based actions (or handle potential for closure related strong reference cycles). Note this may cause issues with passing of RawIntensity items since structs are pure swift. Also consider renaming "Key" based names to avoid ambiguity
*/
@IBDesignable class ExpandingPressureKey: UIView, PressureControl {
    
    private(set) var isExpanded = false   //at moment of expansion this view should capture its bounds so it can return to its original status on completion
    //expansion direction
    
    weak var delegate:PressureKeyAction?
    
    ///this is private set until means for reordering the subviews are added
    @IBInspectable var expansionDirection:PKExpansionDirection = .Up {
        didSet
        {
            if oldValue.hasForwardLayoutDirection() != expansionDirection.hasForwardLayoutDirection() && !pressureKeys.isEmpty{
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
        }
    }
    @IBInspectable var cornerRadius:CGFloat = 0.0 {
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
    }
    

    
    private var touchIntensity: RawIntensity = RawIntensity()
    
    
    
    override var backgroundColor:UIColor? {
        didSet {_ = pressureKeys.map({$0.view.backgroundColor = self.backgroundColor})}
    }
    ///Color for background of selected cell if 3dTouch (and so our dynamic selection background color) are not available
    var nonTouchSelectionBGColor = UIColor.darkGrayColor()

    

    init(){
        super.init(frame:CGRectZero)
        postInitSetup()
    }
    
    init(expansionDirection:PKExpansionDirection){
        super.init(frame:CGRectZero)
        self.expansionDirection = expansionDirection
        postInitSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        postInitSetup()
    }

    required init?(coder aDecoder: NSCoder) {
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
        guard forceTouchAvailable else {return nonTouchSelectionBGColor}
        var white:CGFloat = 0.0
        var alpha:CGFloat = 1.0
        backgroundColor!.getWhite(&white, alpha: &alpha)
        let intensity = touchIntensity.intensity
        let newAlpha:CGFloat = max(alpha * CGFloat(1 + intensity), 1.0)
        let newWhite:CGFloat = white * CGFloat(1 - intensity)
        return UIColor(white: newWhite, alpha: newAlpha)
    }
    
    override func intrinsicContentSize() -> CGSize {
        return containedStackView.arrangedSubviews.first?.intrinsicContentSize() ?? CGSizeZero
    }
    

    func addKey(keyView:UIView, triggeredActionName name:String, actionType:PressureKeyActionType){
        guard !containedStackView.arrangedSubviews.contains(keyView) else {return}
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
    
    
    func addKey(withTextLabel text:String, withFont font:UIFont=UIFont.systemFontOfSize(20.0), actionName: String, actionType:PressureKeyActionType){
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
    
    func addCharKey(charToInsert char:String){
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
    
    func removeAllKeys(){
        for pk in pressureKeys{ containedStackView.removeArrangedSubview(pk.view) }
        pressureKeys = []
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
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        guard !pressureKeys.isEmpty else {return}
        //there should be one and only one touch in the touches set in touchesBegan since we have multitouch disabled
        if let touch = touches.first {
            expand()
            touchIntensity = forceTouchAvailable ? RawIntensity(withValue: touch.force, maximumPossibleForce: touch.maximumPossibleForce) : RawIntensity()
            selectedEPKey = findTouchedEPKey(touch, event: event)
        }
        
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        guard !pressureKeys.isEmpty else {return}
        if let touch = touches.first {
            let newSelectedKey = findTouchedEPKey(touch, event: event)
            if newSelectedKey == nil {
                touchIntensity.reset()
                selectedEPKey = nil
            } else if newSelectedKey?.view != selectedEPKey?.view {
                touchIntensity = forceTouchAvailable ? RawIntensity(withValue: touch.force, maximumPossibleForce: touch.maximumPossibleForce) : RawIntensity()
                selectedEPKey = newSelectedKey
            } else {
                touchIntensity.append(forceTouchAvailable ? touch.force : 0.0)
                selectedEPKey = newSelectedKey //this value is the same but we want to trigger the didSet closure so that the background updates
            }
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        guard !pressureKeys.isEmpty else {return}
        if let touch = touches.first {
            if let newSelectedKey = findTouchedEPKey(touch, event: event) {
                if newSelectedKey.view == selectedEPKey?.view {
                    forceTouchAvailable ? touchIntensity.append(touch.force) : ()
                } else {
                    selectedEPKey = newSelectedKey
                    touchIntensity = forceTouchAvailable ? RawIntensity(withValue: touch.force, maximumPossibleForce: touch.maximumPossibleForce) : RawIntensity()
                }
                //perform closure or selector here
                delegate?.pressureKeyPressed(self, actionName: selectedEPKey!.actionName, actionType:selectedEPKey!.actionType, intensity: touchIntensity.intensity)
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
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
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

///Provides the grouping of the view and closure for the ExpandingPressureView while also providing a handful of convenience functions
private class EPKey {
    var view:UIView
    var actionName:String
    var actionType:PressureKeyActionType
//    var indexFromCenter:Int
    
    var hidden:Bool {
        set {view.hidden = newValue}
        get {return view.hidden}
    }
    
    init(view:UIView,actionName:String, actionType:PressureKeyActionType){
        self.view = view
        self.actionName = actionName
        self.actionType = actionType
    }
}

///The direction in which an ExpandingPressureKey grows on selection
enum PKExpansionDirection {
    case Up,Down,Left,Right
    
    private func hasForwardLayoutDirection()->Bool{
        return self == .Down || self == .Right
    }
}



