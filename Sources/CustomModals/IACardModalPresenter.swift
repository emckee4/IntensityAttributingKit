//
//  IACardModalPresenter.swift
//  BlurAndFillTransition
//
//  Created by Evan Mckee on 9/27/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import UIKit

class IACardModalPresenter: UIPresentationController {
    
    private var dimmingView:UIView!
    private let kMaxDimmingAlpha:CGFloat = 0.6

    override var frameOfPresentedViewInContainerView: CGRect {
        guard containerView != nil else {
            fatalError()
        }
        let topMargin = modalTopMargin(forContainerView: containerView!)
        return CGRect(x: 0, y: topMargin, width: containerView!.bounds.width, height: containerView!.bounds.height - topMargin)
    }
    
    override var shouldRemovePresentersView: Bool {return false}
    
    override func presentationTransitionWillBegin() {
        guard containerView != nil else {return}
        setupDimmingView()
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = kMaxDimmingAlpha
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = self.kMaxDimmingAlpha
        })
        
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if dimmingView == nil {
            setupDimmingView()
            dimmingView.alpha = kMaxDimmingAlpha
        }
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0
            return
        }
        coordinator.animate(alongsideTransition: { (_) in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    private func setupDimmingView() {
        dimmingView = UIView(frame:containerView!.bounds)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        containerView?.insertSubview(dimmingView, at: 0)
        dimmingView.topAnchor.constraint(equalTo: containerView!.topAnchor).isActive = true
        dimmingView.bottomAnchor.constraint(equalTo: containerView!.bottomAnchor).isActive = true
        dimmingView.leftAnchor.constraint(equalTo: containerView!.leftAnchor).isActive = true
        dimmingView.rightAnchor.constraint(equalTo: containerView!.rightAnchor).isActive = true
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 1)
        dimmingView.alpha = 0
    }
    
    private func modalTopMargin(forContainerView containerView:UIView) -> CGFloat {
        if #available(iOS 11.0, *) {
            return max(containerView.safeAreaInsets.top + 25, 35)
        } else {
            return 35
        }
    }
}
