//
//  IACardModalManager.swift
//  BlurAndFillTransition
//
//  Created by Evan Mckee on 9/27/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import UIKit

class IACardModalManager: NSObject {
    var transitionAnimator: IACardModalAnimator = IACardModalAnimator()
    var interactionController: UIPercentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
}

extension IACardModalManager: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return IACardModalPresenter(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.presenting = true
        return transitionAnimator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.presenting = false
        return transitionAnimator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}


