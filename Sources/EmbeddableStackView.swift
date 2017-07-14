//
//  EmbeddableStackView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/4/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import UIKit
/**Shim view to deal with constraint errors arrising from embedding stackViews directly within stackViews
 see: http://stackoverflow.com/questions/32428210/uistackview-unable-to-simultaneously-satisfy-constraints-on-squished-hidden
 http://stackoverflow.com/questions/33073127/nested-uistackviews-broken-constraints
 */
public class EmbeddableStackView: UIView {
    
    private var stackView:UIStackView
    private var layoutConstraints:[NSLayoutConstraint] = []
    
    public override init(frame: CGRect) {
        
        stackView = UIStackView(frame: frame)
        super.init(frame: frame)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: ["stackView":stackView]))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: ["stackView":stackView]))
        for constraint in layoutConstraints {
            constraint.activateWithPriority(999, identifier: "EmbeddableStackView edge constraint")
        }
    }
    
    init(arrangedSubviews views: [UIView]){
        stackView = UIStackView(arrangedSubviews: views)
        super.init(frame: stackView.frame)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: ["stackView":stackView]))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: ["stackView":stackView]))
        layoutConstraints[0].activateWithPriority(999, identifier: "EmbeddableStackView edge constraint")
        for constraint in layoutConstraints[1..<3] {
            constraint.activateWithPriority(1000, identifier: "EmbeddableStackView edge constraint")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("unimplemented")
    }
    
    public var arrangedSubviews:[UIView] {
        return stackView.arrangedSubviews
    }
    
    public var alignment:UIStackViewAlignment {
        get {return stackView.alignment}
        set {stackView.alignment = newValue}
    }
    
    public var axis:UILayoutConstraintAxis {
        get {return stackView.axis}
        set {stackView.axis = newValue}
    }
    
    public var isBaselineRelativeArrangement:Bool{
        get {return stackView.isBaselineRelativeArrangement}
        set {stackView.isBaselineRelativeArrangement = newValue}
    }
    
    public var distribution:UIStackViewDistribution {
        get {return stackView.distribution}
        set {stackView.distribution = newValue}
    }
    
    public var isLayoutMarginsRelativeArrangement:Bool {
        get {return stackView.isLayoutMarginsRelativeArrangement}
        set {stackView.isLayoutMarginsRelativeArrangement = newValue}
    }
    
    public var spacing:CGFloat {
        get {return stackView.spacing}
        set {stackView.spacing = CGFloat(newValue)}
    }
    
    public func addArrangedSubview(_ view:UIView){
        stackView.addArrangedSubview(view)
    }
    
    public func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
        stackView.insertArrangedSubview(view, at: stackIndex)
    }
    
    public func removeArrangedSubview(_ view: UIView) {
        stackView.removeArrangedSubview(view)
    }

}
