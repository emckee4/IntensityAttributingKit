//
//  IAModalOverBlurPresenter.swift
//  BlurAndFillTransition
//
//  Created by Evan Mckee on 9/25/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import UIKit

class IAModalOverBlurPresenter: UIPresentationController {
    
    lazy var effectsView:UIVisualEffectView = {
        let v = UIVisualEffectView(frame: .zero)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override var shouldRemovePresentersView: Bool {return false}
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        updatePresentedViewPosition()
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {print("containerView nil"); return}
        containerView.insertSubview(effectsView, at: 0)
        effectsView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        effectsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        effectsView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        effectsView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        updatePresentedViewPosition()
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            effectsView.effect = UIBlurEffect(style: .regular)
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.effectsView.effect = UIBlurEffect(style: .regular)
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            effectsView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            effectsView.effect = nil
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.effectsView.effect = nil
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            effectsView.removeFromSuperview()
        }
    }
    
    /** Calling this frequently serves as a workaround for cases when modals are presented on top of this modal
     which themselves remove the presenters view.
     */
    private func updatePresentedViewPosition() {
        guard let containerView = containerView, let presentedView = presentedView else {return}
        if !containerView.subviews.contains(presentedView) {
            containerView.addSubview(presentedView)
        }
        if presentedView.frame != containerView.bounds {
            presentedView.frame = containerView.bounds
        }
    }
    
}

