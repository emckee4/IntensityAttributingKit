//
//  IAAccessoryVC.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/26/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

class IAAccessoryVC: UIInputViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    static var singleton = IAAccessoryVC(nibName:nil, bundle: nil)
    
    var kbSwitchButton:UIButton!
    var cameraButton:UIButton!
    //var intensityAdjuster:IntensityAdjuster!
    var intensityButton:PressureKey!
    var intensityLabel:UILabel!
    var intensitySlider:UISlider!
    
    var tokenizerButton:ExpandingKeyControl!
    var optionButton:UIButton!
    var transformButton:ExpandingKeyControl!
    var stackView:UIStackView!
    //var imagePicker:UIImagePickerController!
    
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
        self.inputView?.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.inputView?.layer.shouldRasterize = true
        
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

        
        intensityLabel = UILabel()
        intensityLabel.translatesAutoresizingMaskIntoConstraints = false
        intensityLabel.backgroundColor = kButtonBackgroundColor
        
        
        intensityButton = PressureKey()
        intensityButton.translatesAutoresizingMaskIntoConstraints = false
        intensityButton.backgroundColor = kButtonBackgroundColor
        intensityButton.layer.borderColor = kButtonBorderColor
        intensityButton.layer.borderWidth = kButtonBorderThickness
        intensityButton.layer.cornerRadius = kButtonCornerRadius
        intensityButton.widthAnchor.constraintGreaterThanOrEqualToAnchor(intensityButton.heightAnchor, multiplier: 1.0).activateWithPriority(999, identifier: "iaAccessory.intensityButton: W >= H")
        intensityButton.clipsToBounds = true
        intensityButton.setKey("100", actionName: "intensityButtonPressed")
        intensityButton.delegate = self
        
        
        
        intensitySlider = UISlider()
        intensitySlider.minimumValue = 0.0
        intensitySlider.maximumValue = 100.0
        intensitySlider.addTarget(self, action: "sliderValueChanged:", forControlEvents: .ValueChanged)
        //fix this
        intensitySlider.translatesAutoresizingMaskIntoConstraints = false
        
        
        tokenizerButton = ExpandingKeyControl(expansionDirection: .Up)
        tokenizerButton.setSelector(self, selector: "tokenizerButtonPressed:")
        let ch = IAStringTokenizing.Char.shortLabel
        tokenizerButton.addKey(withTextLabel: ch, actionName: ch)
        let word = IAStringTokenizing.Word.shortLabel
        tokenizerButton.addKey(withTextLabel: word, actionName: word)
        let sentence = IAStringTokenizing.Sentence.shortLabel
        tokenizerButton.addKey(withTextLabel: sentence, actionName: sentence)
//        let line = IAStringTokenizing.Line.shortLabel
//        tokenizerButton.addKey(withTextLabel: line, actionName: line)
        //let par = IAStringTokenizing.Paragraph.shortLabel
        //tokenizerButton.addKey(withTextLabel: par, actionName: par)
        let mes = IAStringTokenizing.Message.shortLabel
        tokenizerButton.addKey(withTextLabel: mes, actionName: mes)
        
        tokenizerButton.backgroundColor = kButtonBackgroundColor
        tokenizerButton.cornerRadius = kButtonCornerRadius
        //tokenizerButton.widthAnchor.constraintGreaterThanOrEqualToConstant(transformButton.intrinsicContentSize().width + 10.0).active = true
        tokenizerButton.widthAnchor.constraintGreaterThanOrEqualToAnchor(tokenizerButton.heightAnchor).activateWithPriority(999, identifier: "iaAccessory.tokenizerEK: W >= H")
        tokenizerButton.layer.borderColor = kButtonBorderColor
        tokenizerButton.layer.borderWidth = kButtonBorderThickness
        tokenizerButton.translatesAutoresizingMaskIntoConstraints = false


        transformButton = ExpandingKeyControl(expansionDirection: .Up)
        transformButton.setSelector(self, selector: "transformButtonPressed:")
        let weightSample = IntensityTransformers.WeightScheme.transformer.generateStaticSampleFromText("abc", size: 20.0)
        let hueGYRSample = IntensityTransformers.HueGYRScheme.transformer.generateStaticSampleFromText("abc", size: 20.0)
        let fontSizeSample = IntensityTransformers.FontSizeScheme.transformer.generateStaticSampleFromText("abc", size: 20.0)
        let alphaSample = IntensityTransformers.AlphaScheme.transformer.generateStaticSampleFromText("abc", size: 20.0)
        transformButton.addKey(withAttributedText: weightSample, actionName: IntensityTransformers.WeightScheme.rawValue)
        transformButton.addKey(withAttributedText: hueGYRSample, actionName: IntensityTransformers.HueGYRScheme.rawValue)
        transformButton.addKey(withAttributedText: fontSizeSample, actionName: IntensityTransformers.FontSizeScheme.rawValue)
        transformButton.addKey(withAttributedText: alphaSample, actionName: IntensityTransformers.AlphaScheme.rawValue)
        
        transformButton.backgroundColor = kButtonBackgroundColor
        transformButton.cornerRadius = kButtonCornerRadius
        transformButton.widthAnchor.constraintGreaterThanOrEqualToConstant(transformButton.intrinsicContentSize().width + 10.0).activateWithPriority(999, identifier: "iaAccessory.transformEK: W >= self.intrinsicContentsSize.W + 10 (ie inset)")
        transformButton.widthAnchor.constraintGreaterThanOrEqualToAnchor(transformButton.heightAnchor).activateWithPriority(999, identifier: "iaAccessory.transformEK: W >= H")
        transformButton.layer.borderColor = kButtonBorderColor
        transformButton.layer.borderWidth = kButtonBorderThickness
        //add config here
        
        
        optionButton = UIButton(type: .Custom)
        optionButton.backgroundColor = kButtonBackgroundColor
        let gear = UIImage(named: "optionsGear", inBundle: IAKitPreferences.bundle, compatibleWithTraitCollection: self.traitCollection)!
        optionButton.tintColor = UIColor.darkGrayColor()
        optionButton.setImage(gear.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        optionButton.addTarget(self, action: "optionButtonPressed", forControlEvents: .TouchUpInside)
        optionButton.layer.cornerRadius = kButtonCornerRadius
        optionButton.layer.borderColor = kButtonBorderColor
        optionButton.layer.borderWidth = kButtonBorderThickness
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        optionButton.setContentCompressionResistancePriority(400, forAxis: .Horizontal)
        optionButton.widthAnchor.constraintEqualToAnchor(optionButton.heightAnchor).activateWithPriority(500, identifier: "iaAccessory.optionButton: W = H")
         
        

        stackView = UIStackView(arrangedSubviews: [kbSwitchButton, cameraButton, intensityButton, intensitySlider, tokenizerButton, transformButton,optionButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .Fill
        stackView.axis = .Horizontal
        stackView.distribution = .Fill
        stackView.spacing = 2.0
        stackView.heightAnchor.constraintEqualToConstant(kAccessoryHeight).activateWithPriority(1000)
        
        inputView!.addSubview(stackView)
        
        //setup constraints now that all views have been added

        
        stackView.topAnchor.constraintEqualToAnchor(view.topAnchor).activateWithPriority(999, identifier: "iaAccessory.stackView.top")
        stackView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).activateWithPriority(999, identifier: "iaAccessory.stackView.bottom")
        stackView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).activateWithPriority(1000, identifier: "iaAccessory.stackView.left")
        stackView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).activateWithPriority(900, identifier: "iaAccessory.stackView.right")
        
        self.inputView!.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: kAccessoryHeight)
        
    }
    
    //MARK:- Lifecycle and resizing layout
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        RawIntensity.touchInterpreter.activate()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        layoutForBoundsAndKeyboard(size)
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    private var currentLayoutIsForIAKeyboard:Bool = true
    
    func updateAccessoryLayout(usingIAKeyboard:Bool){
        self.currentLayoutIsForIAKeyboard = usingIAKeyboard
        layoutForBoundsAndKeyboard()
    }

    func layoutForBoundsAndKeyboard(size:CGSize? = nil){
        let newSize = size ?? UIScreen.mainScreen().bounds.size
        let isWideView = newSize.width >= 450
        //let iaShowing = self.delegate?.iaKeyboardIsShowing() ?? true
        switch (isWideView, currentLayoutIsForIAKeyboard) {
        case (false,false): //portrait, system keyboard
            intensitySlider.hidden = false; tokenizerButton.hidden = true; transformButton.hidden = true
        case (true,false): //landscape, system keyboard
            intensitySlider.hidden = false; tokenizerButton.hidden = false; transformButton.hidden = false
        case (false,true): //portrait, iaKeyboard
            intensitySlider.hidden = true; tokenizerButton.hidden = false; transformButton.hidden = false
        case (true,true): //landscape, iaKeyboard
            intensitySlider.hidden = false; tokenizerButton.hidden = false; transformButton.hidden = false
        }
    }

}