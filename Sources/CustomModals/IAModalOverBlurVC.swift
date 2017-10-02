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
    
    @IBInspectable public var cornerRadius:CGFloat = 8 {
        didSet {
            view.layer.cornerRadius = cornerRadius
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
    
    open override func loadView() {
        super.loadView()
        view.layer.cornerRadius = cornerRadius
        self.view.clipsToBounds = true
    }

    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        onInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        onInit()
    }
    
    public func onInit(){
        restorationIdentifier = "ModalOverBlurViewController"
        self.transitioningDelegate = self.mobManager
        self.modalPresentationStyle = .custom
    }
}

