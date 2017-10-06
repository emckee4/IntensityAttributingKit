//
//  IAModalOverBlurVC.swift
//  BlurAndFillTransition
//
//  Created by Evan Mckee on 9/25/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import UIKit

/**
 Subclass this VC to use as the modal or use it as a container for embedded content.
 Ensure that the preferedContentSize is set since layout depends on it.
 */
open class IAModalOverBlurVC: UIViewController {
    
    public var contentVC:UIViewController! {
        didSet{
            if contentVC == nil {
                oldValue?.removeFromParentViewController()
                contentView?.removeFromSuperview()
                contentView = nil
            } else
            {
                self.addChildViewController(contentVC)
                contentView = contentVC.view
            }
        }
    }
    
    var cvCenterXConstraint:NSLayoutConstraint!
    var cvCenterYConstraint:NSLayoutConstraint!
    var cvHeightConstraint:NSLayoutConstraint!
    var cvWidthConstraint:NSLayoutConstraint!
    
    private(set) var contentView:UIView! {
        didSet {
            contentView?.layer.cornerRadius = self.cornerRadius
            contentView?.clipsToBounds = true
            view.addSubview(contentView)
            applyContentViewConstraints()
        }
    }
    
    @IBInspectable public var cornerRadius:CGFloat = 8 {
        didSet {
            contentView?.layer.cornerRadius = cornerRadius
        }
    }
    
    private(set) lazy var mobManager:IAModalOverBlurManager = {return IAModalOverBlurManager()}()
    
    public weak var sourceView:UIView? {
        didSet{mobManager.transitionAnimator.sourceView = sourceView}
    }
    
    public var presentationDuration:TimeInterval {
        get {return mobManager.transitionAnimator.duration}
        set {mobManager.transitionAnimator.duration = newValue}
    }
    
    public var dismissalDuration:TimeInterval {
        get {return mobManager.transitionAnimator.dismissalDuration}
        set {mobManager.transitionAnimator.dismissalDuration = newValue}
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        onInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        onInit()
    }
    
    public convenience init(contentVC:UIViewController, modalSize:CGSize? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.contentVC = contentVC
        self.addChildViewController(contentVC)
        if modalSize != nil {
            self.preferredContentSize = modalSize!
        } else if contentVC.preferredContentSize != CGSize.zero {
            self.preferredContentSize = contentVC.preferredContentSize
        } else {
            self.preferredContentSize = CGSize(width: 300, height: 300)
        }
        self.contentView = contentVC.view
        contentView?.layer.cornerRadius = self.cornerRadius
        contentView?.clipsToBounds = true
        view.addSubview(contentView)
        applyContentViewConstraints()
    }
    
    public func onInit(){
        restorationIdentifier = "ModalOverBlurViewController"
        self.transitioningDelegate = self.mobManager
        self.modalPresentationStyle = .custom
    }
    
    open override func updateViewConstraints() {
        applyContentViewConstraints()
        super.updateViewConstraints()
    }
    
    func desiredFrameForContentView(inContainerViewOfSize cvSize:CGSize, preferredSize:CGSize? = nil) -> CGRect {
        let prefSize = preferredSize ?? self.preferredContentSize
        let origin = CGPoint(x: (cvSize.width - prefSize.width) / 2,
                             y: (cvSize.height - prefSize.height) / 2)
        return CGRect(origin: origin, size: prefSize)
    }
    
    func applyContentViewConstraints() {
        guard contentView != nil else {return}
        if contentView.translatesAutoresizingMaskIntoConstraints {
            contentView.translatesAutoresizingMaskIntoConstraints = false
        }
        if cvCenterXConstraint == nil {
            cvCenterXConstraint = contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            cvCenterXConstraint.identifier = "cvCenterXConstraint"
            cvCenterXConstraint.isActive = true
        }
        if cvCenterYConstraint == nil {
            cvCenterYConstraint = contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            cvCenterYConstraint.identifier = "cvCenterYConstraint"
            cvCenterYConstraint.isActive = true
        }
        if cvHeightConstraint == nil {
            cvHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: preferredContentSize.height)
            cvHeightConstraint.identifier = "cvHeightConstraint"
            cvHeightConstraint.isActive = true
        } else if cvHeightConstraint.constant != preferredContentSize.height {
            cvHeightConstraint.constant = preferredContentSize.height
        }
        if cvWidthConstraint == nil {
            cvWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: preferredContentSize.width)
            cvWidthConstraint.identifier = "cvHeightConstraint"
            cvWidthConstraint.isActive = true
        } else if cvWidthConstraint.constant != preferredContentSize.width {
            cvWidthConstraint.constant = preferredContentSize.width
        }
    }
}


