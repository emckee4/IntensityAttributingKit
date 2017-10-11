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
 Expand in two directions: L shaped expansion like multi keys on the ios system keyboard.
*/
open class ExpandingKeyBase: UIView {
    
    fileprivate(set) open var isExpanded = false
    
    
    ///this is private set until means for reordering the subviews are added
    open var expansionDirection:EKDirection = .up {
        didSet{
            if oldValue.hasForwardLayoutDirection != expansionDirection.hasForwardLayoutDirection && !epKeys.isEmpty{
                layoutKeysForExpansionDirection()
            }
            self.containedStackView.axis = expansionDirection.axis
        }
    }
    
    public var expansionCaretColor:UIColor? = UIColor.red {
        didSet {
            if expansionCaretColor == nil {
                expansionCaretLayer = nil
            } else {
                expansionCaretLayer = generateExpansionCaretLayer()
            }
        }
    }
    private var expansionCaretLayer:CAShapeLayer! {
        willSet {
            if newValue == nil {
                expansionCaretLayer?.removeFromSuperlayer()
            } else {
                self.layer.insertSublayer(newValue, at: 999)
            }
        }
    }
    
    @IBInspectable open var cornerRadius:CGFloat = 0.0 {
        didSet{self.layer.cornerRadius = cornerRadius; _ = epKeys.map({$0.view.layer.cornerRadius = cornerRadius})}
    }
    
    ///This is the stack view which is actually displayed, holding all of the subviews which are acting as buttons.
    fileprivate var containedStackView:UIStackView!
    
    fileprivate var topSVConstraint:NSLayoutConstraint!
    fileprivate var leftSVConstraint:NSLayoutConstraint!
    fileprivate var rightSVConstraint:NSLayoutConstraint!
    fileprivate var bottomSVConstraint:NSLayoutConstraint!
    
    
    internal var epKeys:[EPKey] = []
    internal var selectedEPKey:EPKey? {
        didSet {
            highlightSelectedEPKey()
        }
    }
    
    override open var backgroundColor:UIColor?{
        didSet {_ = epKeys.map({$0.view.backgroundColor = self.backgroundColor})}
    }
    ///Background color for selected cell. On PressureSensitive subclasses this will be the color which indicates 100% pressure.
    @IBInspectable open var selectionColor:UIColor?
    
    ///This is the default text color when none is provided otherwise. Setting this after providing a color to an individual label based cell (e.g. via an NSAttributedString) will overwrite that textColor.
    open var textColor: UIColor = UIColor.black{
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
    open var selectedBecomesFirst = false
    
    
    //MARK:- inits
    
    init(){
        super.init(frame:CGRect.zero)
        postInitSetup()
    }
    
    public init(expansionDirection:EKDirection){
        super.init(frame:CGRect.zero)
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
    
    fileprivate func postInitSetup(){
        containedStackView = UIStackView()
        containedStackView.axis = (expansionDirection == .up || expansionDirection == .down) ? .vertical : .horizontal
        containedStackView.distribution = .fillEqually
        containedStackView.alignment = .fill
        containedStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containedStackView)
        
        
        topSVConstraint = containedStackView.topAnchor.constraint(equalTo: self.topAnchor).activateWithPriority(999, identifier: "ExpandingKey.topSVConstraint")
        bottomSVConstraint = containedStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).activateWithPriority(999, identifier: "ExpandingKey.bottomSVConstraint")
        leftSVConstraint = containedStackView.leftAnchor.constraint(equalTo: self.leftAnchor).activateWithPriority(1000, identifier: "ExpandingKey.leftSVConstraint")
        rightSVConstraint = containedStackView.rightAnchor.constraint(equalTo: self.rightAnchor).activateWithPriority(1000, identifier: "ExpandingKey.rightSVConstraint")
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isMultipleTouchEnabled = false
        if expansionCaretColor != nil {
            expansionCaretLayer = generateExpansionCaretLayer()
        }
    }
    
    
    
    ///This should be overriden in the intensity registering subclass. It just returns selectionColor (or darkGrey) otherwise
    internal func bgColorForSelection()->UIColor{
        guard selectionColor != nil else {return UIColor.darkGray}
        return selectionColor!
    }
    
    
    ///Updates highlighting for selected and unselected keys
    fileprivate func highlightSelectedEPKey(){
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
    
    override open var intrinsicContentSize : CGSize {
        //TODO: consider calculating and storing ics in epk upon initialization. Maybe include an option in the initializer to indicate that the view will not change size after creation and if all have this then just return a precalculated value
        var maxWidth:CGFloat = 0
        var maxHeight:CGFloat = 0
        for ics in self.epKeys.map({$0.view.intrinsicContentSize}) {
            maxWidth = max(ics.width, maxWidth)
            maxHeight = max(ics.height, maxHeight)
        }
        return CGSize(width: maxWidth, height: maxHeight)
    }
    
    
    ///Reorders keys in the stackview to match the order in the epKeys array, subject to reversal if the expansion direction is not one with forward ordered layout.
    internal func layoutKeysForExpansionDirection(){
        if expansionDirection.hasForwardLayoutDirection {
            for (i,epkey) in self.epKeys.enumerated() {
                if epkey.view != containedStackView.arrangedSubviews[i] {
                    containedStackView.insertArrangedSubview(epkey.view, at: i)
                    assert(containedStackView.arrangedSubviews.count == containedStackView.subviews.count   )
                }
            }
        } else {
            for (i,epkey) in self.epKeys.reversed().enumerated() {
                if epkey.view != containedStackView.arrangedSubviews[i] {
                    //containedStackView.removeArrangedSubview(epkey.view)
                    containedStackView.insertArrangedSubview(epkey.view, at: i)
                    assert(containedStackView.arrangedSubviews.count == containedStackView.subviews.count   )
                }
            }
        }
    }
    
    ///Moves the key with the actionName specified to the center most position
    open func centerKeyWithActionName(_ actionName:String){
        guard actionName != epKeys.first?.actionName else {return}
        for pk in epKeys{
            if pk.actionName == actionName {
                moveEPKeyToFirst(pk)
                return
            }
        }
    }
    
    ///The provided EPKey will be moved to the primary position
    internal func moveEPKeyToFirst(_ key:EPKey){
        for (i,pk) in epKeys.enumerated(){
            if pk.actionName == key.actionName {
                epKeys.remove(at: i)
                epKeys.insert(key, at: 0)
                break
            }
        }
        setHiddenForExpansionState()
        layoutKeysForExpansionDirection()
    }
    
    internal func findTouchedEPKey(_ touch:UITouch,event:UIEvent?)->EPKey?{
        for pk in epKeys {
            let localPoint = touch.location(in: pk.view)
            if pk.view.point(inside: localPoint, with: event){
                return pk
            }
        }
        return nil
    }
    
    
    
    //MARK:- key expansion and contraction
    
    ///selection began: expands stackview and unhides its subviews
    fileprivate func expand(){
        guard !epKeys.isEmpty else {return}
        guard !isExpanded else {return}
        isExpanded = true
        _ = epKeys.map({$0.view.layer.borderColor = UIColor.black.cgColor})
        if epKeys.count > 1 {
            
            //expanding:
            switch self.expansionDirection {
            case .up:
                self.topSVConstraint.constant = -(self.bounds.height * (CGFloat(self.epKeys.count) - 1.0))
            case .down:
                self.bottomSVConstraint.constant = (self.bounds.height * (CGFloat(self.epKeys.count) - 1.0))
            case .left:
                self.leftSVConstraint.constant = -(self.bounds.width * (CGFloat(self.epKeys.count) - 1.0))
            case .right:
                self.rightSVConstraint.constant = (self.bounds.width * (CGFloat(self.epKeys.count) - 1.0))
            }

            //Revealing:
            setHiddenForExpansionState()
            expansionCaretLayer?.isHidden = true
        }
        
    }
    
    ///selection ended: return stackview to its original size, hiding all of its subviews except the one at epKeys[0]
    fileprivate func shrinkView(){
        guard isExpanded else {return}
        isExpanded = false
        
        //border color
        _ = epKeys.map({$0.view.layer.borderColor = UIColor.clear.cgColor})
        
        //hiding:
        setHiddenForExpansionState()
        
        //Shrinking:
        switch self.expansionDirection {
        case .up:
            self.topSVConstraint.constant = 0.0
        case .down:
            self.bottomSVConstraint.constant = 0.0
        case .left:
            self.leftSVConstraint.constant = 0.0
        case .right:
            self.rightSVConstraint.constant = 0.0
        }
        expansionCaretLayer?.isHidden = false
    }
    
    fileprivate func setHiddenForExpansionState(){
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
    
    open func addKey(_ keyView:UIView, actionName name:String){
        guard !containedStackView.arrangedSubviews.contains(keyView) else {return}
        guard !(epKeys.map({$0.actionName == name}).contains(true)) else {return}
        let stackIndex = epKeys.count
        epKeys.append(EPKey(view: keyView, actionName: name))
        keyView.isHidden = stackIndex != 0
        
        if expansionDirection == .down || expansionDirection == .right {
            containedStackView.addArrangedSubview(keyView)
        } else {
            containedStackView.insertArrangedSubview(keyView, at: 0)
        }
        keyView.translatesAutoresizingMaskIntoConstraints = false
        keyView.clipsToBounds = true
        keyView.layer.cornerRadius = self.cornerRadius
        keyView.layer.borderWidth = 1.0
        keyView.layer.borderColor = UIColor.clear.cgColor
        keyView.backgroundColor = self.backgroundColor
    }
    
    open func addKey(image:UIImage, actionName:String, contentMode:UIViewContentMode = .scaleAspectFit, edgeInsets: UIEdgeInsets? = nil){
        guard !(epKeys.map({$0.actionName == actionName}).contains(true)) else {return}
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = contentMode
        if let edgeInsets = edgeInsets, edgeInsets != UIEdgeInsets.zero{
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(iv)
            iv.leftAnchor.constraint(equalTo: container.leftAnchor, constant: edgeInsets.left).activateWithPriority(999, identifier: "\(actionName) image leftInset")
            iv.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -edgeInsets.right).activateWithPriority(999, identifier: "\(actionName) image rightInset")
            iv.topAnchor.constraint(equalTo: container.topAnchor, constant: edgeInsets.top).activateWithPriority(999, identifier: "\(actionName) image topInset")
            iv.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -edgeInsets.bottom).activateWithPriority(999, identifier: "\(actionName) image bottomInset")
            self.addKey(container, actionName: actionName)
        } else {
           self.addKey(iv, actionName: actionName)
        }
    }
    
    open func addKey(withTextLabel text:String, withFont font:UIFont=UIFont.systemFont(ofSize: 20.0), actionName: String){
        guard !(epKeys.map({$0.actionName == actionName}).contains(true)) else {return}
        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = font
        label.textColor = self.textColor
        self.addKey(label, actionName: actionName)
    }
    
    open func addKey(withAttributedText attributedText:NSAttributedString, actionName: String){
        guard !(epKeys.map({$0.actionName == actionName}).contains(true)) else {return}
        let label = UILabel()
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        if attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil) == nil {
            label.textColor = self.textColor
        }
        self.addKey(label, actionName: actionName)
    }
    
    open func removeKey(withActionName actionName:String){
        guard let keyIndex = epKeys.index(where: {$0.actionName == actionName}) else {return}
        let keyToRemove = epKeys.remove(at: keyIndex)
        keyToRemove.view.removeFromSuperview()
        self.layoutKeysForExpansionDirection()
    }
    
    
    ///Removes all keys, setting the pressureKey as empty
    open func removeAllKeys(){
        for pk in epKeys{ containedStackView.removeArrangedSubview(pk.view) }
        epKeys = []
    }
    
    
    ///Executed immediately prior to a setting call on selectedEPKey, in touchesBegan, touchesMoved, touchesEnded, and touchesCancelled. Override to implement additional non standard actions during touchesBegan.
    func keySelectionWillUpdate(withTouch touch:UITouch!, previousSelection oldKey:EPKey?, nextSelection:EPKey?){
        
    }
    ///Called immediately after selectedEPKey is updated to a non-nil value in touches ended. Override to implement additional non standard actions during touchesEnded to handle key selection.
    func handleKeySelection(_ selectedKey:EPKey, finalTouch:UITouch?){
        
    }
    
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
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
    
    
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
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
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
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
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches cancelled")
        keySelectionWillUpdate(withTouch: nil, previousSelection: selectedEPKey, nextSelection: nil)
        selectedEPKey = nil
        shrinkView()
        super.touchesCancelled(touches, with: event)
    }
    
    private func generateExpansionCaretLayer()->CAShapeLayer! {
        guard let color = expansionCaretColor?.cgColor else {return nil}
        let layer = CAShapeLayer()
        let path = CGMutablePath()
        path.addLines(between: [
            CGPoint(x: 3, y:0),
            CGPoint(x: 0, y:3),
            CGPoint(x: 6, y:3)])
        layer.path = path
        layer.strokeColor = color
        layer.fillColor = color
        layer.lineWidth = 0.5
        layer.frame = CGRect(x: 3, y: 2, width: 10, height: 10)
        return layer
    }
    
}

