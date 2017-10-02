//
//  IACardModalViewController.swift
//  BlurAndFillTransition
//
//  Created by Evan Mckee on 9/27/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import UIKit

open class IACardModalViewController: UIViewController {
    
    public var contentViewController:UIViewController? {
        didSet {
            contentView = contentViewController?.view
        }
    }
    
    public var contentView:UIView? {
        didSet {
            if oldValue != self.contentView {
                oldValue?.removeFromSuperview()
            }
            if let contentView = self.contentView {
                view.addSubview(contentView)
                contentView.translatesAutoresizingMaskIntoConstraints = false
                let topAnchor = contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25)
                topAnchor.priority = 1000
                topAnchor.isActive = true
                let bottomOptionalConstraint = contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                bottomOptionalConstraint.priority = 999
                bottomOptionalConstraint.isActive = true
                contentView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
                contentView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            }
        }
    }
    
    private(set) lazy var cardModalManager:IACardModalManager = IACardModalManager()
    var dismissalButton:UIButton!
    var panGestureRecognizer:UIPanGestureRecognizer!
    private var contentViewBottomConstraint:NSLayoutConstraint!
    
    public weak var sourceView:UIView? {
        didSet{cardModalManager.transitionAnimator.sourceView = sourceView}
    }
    
    override open func loadView() {
        super.loadView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 14
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.transitioningDelegate = cardModalManager
        self.modalPresentationStyle = .custom
        self.view.backgroundColor = UIColor.lightGray
    }
    
    private func setupVC() {
        dismissalButton = UIButton()
        dismissalButton.tintColor = UIColor.darkGray
        if let chevronDown = UIImage(named: "chevronDown", in: Bundle(for: IACardModalViewController.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) {
            dismissalButton.setImage(chevronDown, for: .normal)
        }
        dismissalButton.translatesAutoresizingMaskIntoConstraints = false
        dismissalButton.addTarget(self, action: #selector(self.dismissButtonPressed), for: .touchUpInside)
        view.addSubview(dismissalButton)
        dismissalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dismissalButton.widthAnchor.constraint(equalToConstant: 41).isActive = true
        dismissalButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 4).isActive = true
        dismissalButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleSwipeGesture))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 2
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func dismissButtonPressed(sender:UIButton!) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func handleSwipeGesture(sender:UIPanGestureRecognizer!) {
        guard sender != nil,
            let fullFrame = presentationController?.frameOfPresentedViewInContainerView,
            let containerView = presentationController?.containerView else {
            return
        }
        let interactionController = cardModalManager.interactionController
        let yDeltaPercent = min(sender.translation(in: containerView).y / fullFrame.size.height, 1)
        if sender.state == .changed {
            if !self.isBeingDismissed {
                if yDeltaPercent > 0.05 {
                    presentingViewController?.dismiss(animated: true, completion: nil)
                    interactionController.update(yDeltaPercent)
                }
            } else if yDeltaPercent > 0.3 {
                interactionController.finish()
            } else {
                interactionController.update(yDeltaPercent)                
            }
        } else if sender.state == .ended {
            if yDeltaPercent > 0.3 {
                interactionController.finish()
            } else {
                interactionController.cancel()
            }
        } else if sender.state == .failed {
            interactionController.cancel()
        }
    }
}
