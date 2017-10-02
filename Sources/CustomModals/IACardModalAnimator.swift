//
//  IACardModalAnimator.swift
//  BlurAndFillTransition
//
//  Created by Evan Mckee on 9/27/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import UIKit


class IACardModalAnimator:NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting:Bool!
    weak var sourceView:UIView?
    
    var duration:TimeInterval = 1

    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting == true {
            animatePresentation(using: transitionContext)
        } else {
            animateDismissal(using: transitionContext)
        }
    }
    
    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let modalVC = transitionContext.viewController(forKey: .to) as? IACardModalViewController,
            let modalView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        let containerView = transitionContext.containerView
        modalView.frame = sourceView?.frame ?? CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: 0)
        modalView.alpha = 0.5
        transitionContext.finalFrame(for: modalVC)
        containerView.addSubview(modalView)
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .beginFromCurrentState, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                modalView.frame = transitionContext.finalFrame(for: modalVC)
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
                modalView.alpha = 1
            })
        }, completion: { (result) in
            transitionContext.completeTransition(result && !transitionContext.transitionWasCancelled)
        })
    }
    
    private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let _ = transitionContext.viewController(forKey: .from) as? IACardModalViewController,
            let modalView = transitionContext.view(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
        }
        let containerView = transitionContext.containerView
        let finalFrame = sourceView?.frame ?? CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: 0)
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .calculationModeCubic, .layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                modalView.frame = finalFrame
            })
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                modalView.alpha = 0.25
            })
        }, completion: { (result) in
            transitionContext.completeTransition(result && !transitionContext.transitionWasCancelled)
        })
    }
    
}

