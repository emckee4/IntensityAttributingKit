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
    
    static func generateOpacityAnimation(_ startAlpha:Float = 0, endAlpha:Float = 1, duration:TimeInterval, offset:TimeInterval = 0)->CABasicAnimation{
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = NSNumber(value: startAlpha as Float)
        anim.toValue = NSNumber(value: endAlpha as Float)
        
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.autoreverses = true
        anim.duration = duration
        anim.repeatCount = 100
        anim.timeOffset = offset
        return anim
    }
    
    
    public func startAnimation(){
        guard let options = iaString?.baseOptions?.optionsWithOverridesApplied(IAKitPreferences.iaStringOverridingOptions), options.animatesIfAvailable == true && options.renderScheme.isAnimatable && iaString.length > 0 else {return}
        if bottomTV.isHidden == true {bottomTV.isHidden = false}
        let trans:IntensityTransformers =  options.renderScheme
        guard let animatingTransformer:AnimatedIntensityTransforming.Type = (trans.transformer as? AnimatedIntensityTransforming.Type) else {return}
        let aniParams:IAAnimationParameters = options.animationOptions ?? animatingTransformer.defaultAnimationParameters
        // get properties, adjust offsets, start animation
        let baseOffset = ProcessInfo.processInfo.systemUptime.truncatingRemainder(dividingBy: aniParams.duration)
        
        if animatingTransformer.topLayerAnimates {
            let topAnimation = IACompositeTextView.generateOpacityAnimation(aniParams.topLayerFromValue, endAlpha: aniParams.topLayerToValue, duration: aniParams.duration, offset: baseOffset)
            topTV.layer.add(topAnimation, forKey: "opacity")
        } else {
            topTV.layer.removeAnimation(forKey: "opacity")
        }
        if animatingTransformer.bottomLayerAnimates{
            let bottomOffset = baseOffset + (animatingTransformer.bottomLayerTimingOffset * aniParams.duration)
            let bottomAnimation = IACompositeTextView.generateOpacityAnimation(aniParams.bottomLayerFromValue, endAlpha: aniParams.bottomLayerToValue, duration: aniParams.duration, offset: bottomOffset)
            bottomTV.layer.add(bottomAnimation, forKey: "opacity")
        } else {
            bottomTV.layer.removeAnimation(forKey: "opacity")
        }
        
    }
    
    public func stopAnimation(){
        topTV.layer.removeAnimation(forKey: "opacity")
        bottomTV.layer.removeAnimation(forKey: "opacity")
        //bottomTV.hidden = true
        //TODO: may want to set final value for opacity here
    }
}
