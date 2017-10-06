//
//  IAModalOverBlurPresenter.swift
//  BlurAndFillTransition_Demo
//
//  Created by Evan Mckee on 6/27/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import Foundation
import UIKit

class IAModalOverBlurAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    ///sourceView defines the region from which the presented VC appears to emanate. If this isn't set then the Modal emerges from the center of the containerView
    weak var sourceView:UIView?
    
    var duration:TimeInterval = 0.6
    lazy var dismissalDuration:TimeInterval = {return self.duration}()
    
    var presenting:Bool!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            animatePresentation(withContext: transitionContext)
        } else {
            animateDismissal(withContext: transitionContext)
        }
    }
    
    private func animatePresentation(withContext transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let modalView = transitionContext.view(forKey: .to),
            let modalVC = transitionContext.viewController(forKey: .to) as? IAModalOverBlurVC,
            let modalContentView = modalVC.contentView else {
                transitionContext.completeTransition(false)
                return
        }
        modalContentView.frame = sourceView?.frame ?? CGRect(origin: transitionContext.containerView.center, size: CGSize.zero)
        modalContentView.alpha = 0.5
        modalView.addSubview(modalContentView)
        if !containerView.subviews.contains(modalView) {
            containerView.addSubview(modalView)
        }
        
        let endFrame = modalVC.desiredFrameForContentView(inContainerViewOfSize: containerView.bounds.size)
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .calculationModeCubicPaced, .layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
                modalContentView.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                modalContentView.frame = endFrame
            })
        }) { (result) in
            transitionContext.completeTransition(result)
        }
    }
    
    private func animateDismissal(withContext transitionContext: UIViewControllerContextTransitioning) {
        guard let _ = transitionContext.view(forKey: .from),
            let modalVC = transitionContext.viewController(forKey: .from) as? IAModalOverBlurVC,
            let modalContentView = modalVC.contentView else {
                transitionContext.completeTransition(false)
                return
        }
        let destRect = sourceView?.frame ?? CGRect(origin: transitionContext.containerView.center, size: CGSize.zero)
        let snap = modalContentView.snapshotView(afterScreenUpdates: false)!
        snap.contentMode = .scaleAspectFill
        modalContentView.addSubview(snap)
        snap.frame = modalContentView.bounds
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .calculationModeCubicPaced, .layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                modalContentView.frame = destRect
            })
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                modalContentView.alpha = 0.5
            })
        }) { (result) in
            transitionContext.completeTransition(result)
        }
    }
    
    convenience init(sourceView:UIView) {
        self.init()
        self.sourceView = sourceView
    }
    
}

