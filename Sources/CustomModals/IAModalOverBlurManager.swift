//
//  IAModalOverBlurManager.swift
//  BlurAndFillTransition
//
//  Created by Evan Mckee on 9/26/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import UIKit

class IAModalOverBlurManager:NSObject {
    var transitionAnimator: IAModalOverBlurAnimator
    
    override init() {
        transitionAnimator = IAModalOverBlurAnimator()
        super.init()
    }
    
    init(sourceView:UIView) {
        transitionAnimator = IAModalOverBlurAnimator(sourceView:sourceView)
        super.init()
    }
}

extension IAModalOverBlurManager: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.presenting = true
        return transitionAnimator
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return IAModalOverBlurPresenter(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.presenting = false
        return transitionAnimator
    }
}

