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
        guard let modalView = transitionContext.view(forKey: .to), let modalVC = transitionContext.viewController(forKey: .to) as? IAModalOverBlurVC else {
            transitionContext.completeTransition(false)
            return
        }
        modalView.frame = sourceView?.frame ?? CGRect(origin: transitionContext.containerView.center, size: CGSize.zero)
        modalView.alpha = 0.5
        containerView.addSubview(modalView)
        let endFrameOrigin = CGPoint(x: (containerView.bounds.size.width - modalVC.preferredContentSize.width) / 2,
                                     y: (containerView.bounds.size.height - modalVC.preferredContentSize.height) / 2)
        let endFrame = CGRect(origin: endFrameOrigin, size: modalVC.preferredContentSize)
        
        UIView.animate(withDuration: duration / 3, animations: {
            modalView.alpha = 1
        })
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            modalView.frame = endFrame
        }) { (result) in
            transitionContext.completeTransition(result)
        }
    }
    
    private func animateDismissal(withContext transitionContext: UIViewControllerContextTransitioning) {
        let modalView = transitionContext.view(forKey: .from)
        let destRect = sourceView?.frame ?? CGRect(origin: transitionContext.containerView.center, size: CGSize.zero)
        UIView.animate(withDuration: dismissalDuration / 3, delay: 2 * dismissalDuration / 3, options: [], animations: {
            modalView?.alpha = 0.5
        }, completion: nil)
        UIView.animate(withDuration: dismissalDuration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            modalView?.frame = destRect
        }) { (result) in
            transitionContext.completeTransition(result)
        }
    }
    
    convenience init(sourceView:UIView) {
        self.init()
        self.sourceView = sourceView
    }
    
}

