//
//  IAAccessoryVC.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/26/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

class IAAccessoryVC: UIInputViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var kbSwitchButton:UIButton!
    var cameraButton:UIButton!
    var intensityAdjuster:IntensityAdjuster!
    var optionButton:UIButton!
    var transformButton:ExpandingKeyControl!
    var stackView:UIStackView!
    var imagePicker:UIImagePickerController!
    
    var delegate:IAAccessoryDelegate?
    
    private lazy var bundle:NSBundle = { return NSBundle(forClass: self.dynamicType) }()
    
    //MARK:- layout constants
    
    let kAccessoryHeight:CGFloat = 44.0
    let kButtonCornerRadius:CGFloat = 5.0
    let kButtonBorderThickness:CGFloat = 1.0
    let kButtonBorderColor:CGColor = UIColor.darkGrayColor().CGColor
    let kButtonBackgroundColor:UIColor = UIColor.lightGrayColor()
    //let kButtonTextColor = UIColor.darkGrayColor()
    
    
    
    //MARK:- init and setup
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupVC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupVC()
    }
    
    func setupVC(){
        self.inputView!.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        self.inputView!.translatesAutoresizingMaskIntoConstraints = false

        
        kbSwitchButton = UIButton(type: .System)
        kbSwitchButton.setImage(UIImage(named: "Keyboard", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal )
        kbSwitchButton.imageView?.contentMode = .ScaleAspectFit
        kbSwitchButton.backgroundColor = kButtonBackgroundColor
        kbSwitchButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        kbSwitchButton.addTarget(self, action: "kbSwitchButtonPressed:", forControlEvents: .TouchUpInside)
        kbSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        kbSwitchButton.layer.cornerRadius = kButtonCornerRadius
        kbSwitchButton.layer.borderColor = kButtonBorderColor
        kbSwitchButton.layer.borderWidth = kButtonBorderThickness
        kbSwitchButton.clipsToBounds = true
        

        cameraButton = UIButton(type: .System)
        cameraButton.setImage(UIImage(named: "camera", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal )
        cameraButton.imageView?.contentMode = .ScaleAspectFit
        cameraButton.backgroundColor = kButtonBackgroundColor
        cameraButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        cameraButton.addTarget(self, action: "cameraButtonPressed:", forControlEvents: .TouchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.layer.cornerRadius = kButtonCornerRadius
        cameraButton.layer.borderColor = kButtonBorderColor
        cameraButton.layer.borderWidth = kButtonBorderThickness
        cameraButton.clipsToBounds = true
        cameraButton.widthAnchor.constraintEqualToAnchor(cameraButton.heightAnchor).activateWithPriority(800)
        
        intensityAdjuster = IntensityAdjuster()
        intensityAdjuster.translatesAutoresizingMaskIntoConstraints = false
        intensityAdjuster.componentBackgroundColor = kButtonBackgroundColor
        intensityAdjuster.componentBorderColor = kButtonBorderColor
        intensityAdjuster.componentBorderWidth = kButtonBorderThickness
        intensityAdjuster.componentCornerRadius = kButtonCornerRadius
        intensityAdjuster.stackViewSpacing = 2.0
        intensityAdjuster.heightAnchor.constraintEqualToConstant(kAccessoryHeight).active = true
        //intensityAdjuster.showPressureSlider = true
        intensityAdjuster.clipsToBounds = true
        intensityAdjuster.delegate = self

        
        optionButton = UIButton(type: .Custom)
        optionButton.backgroundColor = kButtonBackgroundColor
        optionButton.setTitle("Opts", forState: .Normal)
        optionButton.addTarget(self, action: "optionButtonPressed", forControlEvents: .TouchUpInside)
        optionButton.layer.cornerRadius = kButtonCornerRadius
        optionButton.layer.borderColor = kButtonBorderColor
        optionButton.layer.borderWidth = kButtonBorderThickness
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        optionButton.setContentCompressionResistancePriority(400, forAxis: .Horizontal)
        optionButton.widthAnchor.constraintEqualToAnchor(optionButton.heightAnchor).activateWithPriority(500)
 

        transformButton = ExpandingKeyControl(expansionDirection: .Up)
        transformButton.setSelector(self, selector: "transformButtonPressed:")
        let weightSample = IntensityTransformers.WeightScheme.transformer.generateSampleFromText("abc", size: 20.0)
        let hueGYRSample = IntensityTransformers.HueGYRScheme.transformer.generateSampleFromText("abc", size: 20.0)
        let fontSizeSample = IntensityTransformers.FontSizeScheme.transformer.generateSampleFromText("abc", size: 20.0)
        transformButton.addKey(withAttributedText: weightSample, actionName: IntensityTransformers.WeightScheme.rawValue)
        transformButton.addKey(withAttributedText: hueGYRSample, actionName: IntensityTransformers.HueGYRScheme.rawValue)
        transformButton.addKey(withAttributedText: fontSizeSample, actionName: IntensityTransformers.FontSizeScheme.rawValue)
        
        transformButton.backgroundColor = kButtonBackgroundColor
        transformButton.cornerRadius = kButtonCornerRadius
        transformButton.widthAnchor.constraintGreaterThanOrEqualToConstant(transformButton.intrinsicContentSize().width + 10.0).active = true
        transformButton.widthAnchor.constraintGreaterThanOrEqualToAnchor(transformButton.heightAnchor).active = true
        transformButton.layer.borderColor = kButtonBorderColor
        transformButton.layer.borderWidth = kButtonBorderThickness
        //add config here
        
        
        
        

        stackView = UIStackView(arrangedSubviews: [kbSwitchButton, cameraButton, intensityAdjuster, transformButton ,optionButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .Fill
        stackView.axis = .Horizontal
        stackView.distribution = .Fill
        stackView.spacing = 2.0
        
        inputView!.addSubview(stackView)
        
        //setup constraints now that all views have been added

        
        let topConstraint = stackView.topAnchor.constraintEqualToAnchor(view.topAnchor)
            topConstraint.priority = 999
            topConstraint.active = true
        let bottomConstraint = stackView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
            bottomConstraint.priority = 999
            bottomConstraint.active = true
        let leftConstraint = stackView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
            leftConstraint.priority = 1000
            leftConstraint.active = true
        let rightConstraint = stackView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
            rightConstraint.priority = 900
            rightConstraint.active = true
        
        self.inputView!.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: kAccessoryHeight)
        
        if let mapping = IAKitOptions.singleton.forceIntensityMapping {
            RawIntensity.forceIntensityMapping = mapping.namedFunction
        } else {
            if self.traitCollection.forceTouchCapability == UIForceTouchCapability.Available {
                IAKitOptions.singleton.forceIntensityMapping = ForceIntensityMappingFunctions.AvailableFunctions.SmoothedAverageLastTen
                RawIntensity.forceIntensityMapping = ForceIntensityMappingFunctions.AvailableFunctions.SmoothedAverageLastTen.namedFunction
            } else {
                IAKitOptions.singleton.forceIntensityMapping = ForceIntensityMappingFunctions.AvailableFunctions.DurationLinearScaleToConstant
                RawIntensity.forceIntensityMapping = ForceIntensityMappingFunctions.AvailableFunctions.DurationLinearScaleToConstant.namedFunction
            }
            IAKitOptions.singleton.saveOptions()
        }
    }
    
    //MARK:- Lifecycle and resizing layout
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        layoutForBounds(UIScreen.mainScreen().bounds.size)

    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        layoutForBounds(size)
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    func layoutForBounds(size:CGSize){
        if !intensityAdjuster.forceTouchAvailable && size.width > 350{
            intensityAdjuster.showPressureSlider = true
            intensityAdjuster.showPressurePad = false
        } else if size.width > size.height {
            intensityAdjuster.showPressureSlider = true
            intensityAdjuster.showPressurePad = true
        } else {
            intensityAdjuster.showPressurePad = true
            intensityAdjuster.showPressureSlider = false
        }
    }

}