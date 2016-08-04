//
//  IACompositeTextView+Animations.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/14/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


///Common text animation handling for all IACompositeBase derived classes.
extension IACompositeBase{
    
    static func generateOpacityAnimation(startAlpha:Float = 0, endAlpha:Float = 1, duration:NSTimeInterval, offset:NSTimeInterval = 0)->CABasicAnimation{
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = NSNumber(float: startAlpha)
        anim.toValue = NSNumber(float: endAlpha)
        
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.autoreverses = true
        anim.duration = duration
        anim.repeatCount = 100
        anim.timeOffset = offset
        return anim
    }
    
    
    public func startAnimation(){
        guard let options = iaString?.baseOptions?.optionsWithOverridesApplied(IAKitPreferences.iaStringOverridingOptions) where options.animatesIfAvailable == true && options.renderScheme.isAnimatable && iaString.length > 0 else {return}
        if bottomTV.hidden == true {bottomTV.hidden = false}
        let trans:IntensityTransformers =  options.renderScheme
        guard let animatingTransformer:AnimatedIntensityTransforming.Type = (trans.transformer as? AnimatedIntensityTransforming.Type) else {return}
        let aniParams:IAAnimationParameters = options.animationOptions ?? animatingTransformer.defaultAnimationParameters
        // get properties, adjust offsets, start animation
        let baseOffset = NSProcessInfo.processInfo().systemUptime % aniParams.duration
        
        if animatingTransformer.topLayerAnimates {
            let topAnimation = IACompositeTextView.generateOpacityAnimation(aniParams.topLayerFromValue, endAlpha: aniParams.topLayerToValue, duration: aniParams.duration, offset: baseOffset)
            topTV.layer.addAnimation(topAnimation, forKey: "opacity")
        } else {
            topTV.layer.removeAnimationForKey("opacity")
        }
        if animatingTransformer.bottomLayerAnimates{
            let bottomOffset = baseOffset + (animatingTransformer.bottomLayerTimingOffset * aniParams.duration)
            let bottomAnimation = IACompositeTextView.generateOpacityAnimation(aniParams.bottomLayerFromValue, endAlpha: aniParams.bottomLayerToValue, duration: aniParams.duration, offset: bottomOffset)
            bottomTV.layer.addAnimation(bottomAnimation, forKey: "opacity")
        } else {
            bottomTV.layer.removeAnimationForKey("opacity")
        }
        
    }
    
    public func stopAnimation(){
        topTV.layer.removeAnimationForKey("opacity")
        bottomTV.layer.removeAnimationForKey("opacity")
        //bottomTV.hidden = true
        //TODO: may want to set final value for opacity here
    }
}
