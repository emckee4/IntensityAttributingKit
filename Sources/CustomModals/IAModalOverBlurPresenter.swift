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
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard containerView != nil else {return CGRect.zero}
        let preferedSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        return childViewFrame(inContainerViewOfSize: containerView!.bounds.size, preferedSize: preferedSize)
    }
    
    override var shouldRemovePresentersView: Bool {return false}
    
    override func presentationTransitionWillBegin() {
        print("presentationTransitionWillBegin")
        guard let containerView = containerView else {print("containerView nil"); return}
        containerView.insertSubview(effectsView, at: 0)
        effectsView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        effectsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        effectsView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        effectsView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true

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
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return container.preferredContentSize
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let destFrame = childViewFrame(inContainerViewOfSize: size, preferedSize: presentedViewController.preferredContentSize)
        coordinator.animate(alongsideTransition: { (context) in
            self.presentedView?.frame = destFrame
        })
    }

    func childViewFrame(inContainerViewOfSize cvSize:CGSize, preferedSize:CGSize) -> CGRect {
        let origin = CGPoint(x: (cvSize.width - preferedSize.width) / 2,
                             y: (cvSize.height - preferedSize.height) / 2)
        return CGRect(origin: origin, size: preferedSize)
    }
    
}
