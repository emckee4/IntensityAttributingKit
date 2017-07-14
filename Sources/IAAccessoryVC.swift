//
//  IAAccessoryVC.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/26/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

/** The IAAccessoryVC provides the input accessory used by the IACompositeEditor. It provides access to a varity of options and interfaces and can trigger the presentation of other VCs relevant to the IAString editing process.
 */
class IAAccessoryVC: UIInputViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    static var singleton = IAAccessoryVC(nibName:nil, bundle: nil)
    
    var kbSwitchButton:UIButton!
    var attachmentButton:ExpandingKeyControl!
    var intensityButton:PressureKey!
    var intensitySlider:UISlider!
    
    var tokenizerButton:ExpandingKeyControl!
    var optionButton:UIButton!
    var transformButton:ExpandingKeyControl!
    var stackView:UIStackView!
    
    var delegate:IAAccessoryDelegate?
    
    fileprivate lazy var bundle:Bundle = { return Bundle(for: type(of: self)) }()
    
    //MARK:- layout constants
    
    let kAccessoryHeight:CGFloat = 44.0
    let kButtonCornerRadius:CGFloat = IAKitPreferences.visualPreferences.accessoryButtonCornerRadius//5.0
    let kButtonBorderThickness:CGFloat = IAKitPreferences.visualPreferences.accessoryButtonBorderWidth
    let kButtonBorderColor:CGColor = IAKitPreferences.visualPreferences.accessoryButtonBorderColor.cgColor
    let kButtonBackgroundColor:UIColor = IAKitPreferences.visualPreferences.accessoryButtonBackgroundColor
    
    
    //MARK:- init and setup
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupVC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupVC()
    }
    
    func setupVC(){
        inputView!.backgroundColor = IAKitPreferences.visualPreferences.accessoryBackgroundColor
        inputView!.translatesAutoresizingMaskIntoConstraints = false
        inputView!.layer.rasterizationScale = UIScreen.main.scale
        inputView!.layer.shouldRasterize = true
        inputView!.tintColor = IAKitPreferences.visualPreferences.accessoryTintColor
        
        //MARK: Keyboard switch setup
        
        kbSwitchButton = UIButton(type: .system)
        kbSwitchButton.setImage(UIImage(named: "Keyboard", in: bundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate), for: UIControlState() )
        kbSwitchButton.imageView?.contentMode = .scaleAspectFit
        kbSwitchButton.backgroundColor = kButtonBackgroundColor
        kbSwitchButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        kbSwitchButton.widthAnchor.constraint(lessThanOrEqualTo: kbSwitchButton.heightAnchor, multiplier: 1.2).activateWithPriority(998, identifier: "kbSwitchButton W <= H*1.2")
        kbSwitchButton.addTarget(self, action: #selector(IAAccessoryVC.kbSwitchButtonPressed(_:)), for: .touchUpInside)
        kbSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        kbSwitchButton.layer.cornerRadius = kButtonCornerRadius
        kbSwitchButton.layer.borderColor = kButtonBorderColor
        kbSwitchButton.layer.borderWidth = kButtonBorderThickness
        kbSwitchButton.clipsToBounds = true
        
        
        //MARK: Attachment insertion expanding key setup
        
        attachmentButton = ExpandingKeyControl(expansionDirection: .up)
        attachmentButton.setSelector(self, selector: "attachmentButtonPressed:")
        let cameraImage = UIImage(named: "camera", in: bundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        attachmentButton.addKey(image: cameraImage, actionName: "photo", contentMode: .scaleAspectFit, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        let videoImage = UIImage(named: "video", in: bundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        attachmentButton.addKey(image: videoImage, actionName: "video", contentMode: .scaleAspectFit, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        let locationImage = UIImage(named: "locationPin", in: bundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        attachmentButton.addKey(image: locationImage, actionName: "location", contentMode: .scaleAspectFit, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        attachmentButton.backgroundColor = kButtonBackgroundColor
        attachmentButton.cornerRadius = kButtonCornerRadius
        attachmentButton.widthAnchor.constraint(equalTo: attachmentButton.heightAnchor, multiplier: 1.0).activateWithPriority(999, identifier: "iaAccessory.attachmentButton: W = H")
        attachmentButton.layer.borderColor = kButtonBorderColor
        attachmentButton.layer.borderWidth = kButtonBorderThickness
        
        //MARK: Intensity button setup
        
        intensityButton = PressureKey()
        intensityButton.translatesAutoresizingMaskIntoConstraints = false
        intensityButton.backgroundColor = kButtonBackgroundColor
        intensityButton.layer.borderColor = kButtonBorderColor
        intensityButton.layer.borderWidth = kButtonBorderThickness
        intensityButton.layer.cornerRadius = kButtonCornerRadius
        intensityButton.widthAnchor.constraint(greaterThanOrEqualTo: intensityButton.heightAnchor, multiplier: 1.0).activateWithPriority(999, identifier: "iaAccessory.intensityButton: W >= H")
        intensityButton.clipsToBounds = true
        intensityButton.setKey("100", actionName: "intensityButtonPressed")
        intensityButton.textColor = IAKitPreferences.visualPreferences.accessoryTintColor
        intensityButton.delegate = self
        
        //MARK: Intensity slider setup
        
        intensitySlider = UISlider()
        intensitySlider.minimumValue = 0.0
        intensitySlider.maximumValue = 100.0
        intensitySlider.addTarget(self, action: #selector(IAAccessoryVC.sliderValueChanged(_:)), for: .valueChanged)
        intensitySlider.translatesAutoresizingMaskIntoConstraints = false
        
        
        //MARK: Tokenizer selecting expanding key setup
        
        tokenizerButton = ExpandingKeyControl(expansionDirection: .up)
        tokenizerButton.setSelector(self, selector: "tokenizerButtonPressed:")
        let charIcon = UIImage(named: "charTok", in: IAKitPreferences.bundle, compatibleWith: self.traitCollection)!.withRenderingMode(.alwaysTemplate)
        tokenizerButton.addKey(image: charIcon, actionName: IAStringTokenizing.Char.shortLabel, contentMode: .scaleAspectFit)
        let wordIcon = UIImage(named: "word", in: IAKitPreferences.bundle, compatibleWith: self.traitCollection)!.withRenderingMode(.alwaysTemplate)
        tokenizerButton.addKey(image: wordIcon, actionName: IAStringTokenizing.Word.shortLabel, contentMode: .scaleAspectFit)
        let sentenceIcon = UIImage(named: "sentence", in: IAKitPreferences.bundle, compatibleWith: self.traitCollection)!.withRenderingMode(.alwaysTemplate)
        tokenizerButton.addKey(image: sentenceIcon, actionName: IAStringTokenizing.Sentence.shortLabel, contentMode: .scaleAspectFit)
        let messageIcon = UIImage(named: "message", in: IAKitPreferences.bundle, compatibleWith: self.traitCollection)!.withRenderingMode(.alwaysTemplate)
        tokenizerButton.addKey(image: messageIcon, actionName: IAStringTokenizing.Message.shortLabel, contentMode: .scaleAspectFit)
        tokenizerButton.backgroundColor = kButtonBackgroundColor
        tokenizerButton.cornerRadius = kButtonCornerRadius
        //tokenizerButton.widthAnchor.constraintGreaterThanOrEqualToConstant(transformButton.intrinsicContentSize().width + 10.0).active = true
        tokenizerButton.widthAnchor.constraint(greaterThanOrEqualTo: tokenizerButton.heightAnchor).activateWithPriority(999, identifier: "iaAccessory.tokenizerEK: W >= H")
        tokenizerButton.widthAnchor.constraint(equalTo: tokenizerButton.heightAnchor, multiplier: 1.33).activateWithPriority(800, identifier: "iaAccessory.tokenizerEK: W = H*1.25")
        tokenizerButton.layer.borderColor = kButtonBorderColor
        tokenizerButton.layer.borderWidth = kButtonBorderThickness
        tokenizerButton.translatesAutoresizingMaskIntoConstraints = false

        //MARK: Transformer selecting ExpandingKey setup
        
        transformButton = ExpandingKeyControl(expansionDirection: .up)
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
        transformButton.widthAnchor.constraint(greaterThanOrEqualToConstant: transformButton.intrinsicContentSize.width + 10.0).activateWithPriority(999, identifier: "iaAccessory.transformEK: W >= self.intrinsicContentsSize.W + 10 (ie inset)")
        transformButton.widthAnchor.constraint(greaterThanOrEqualTo: transformButton.heightAnchor).activateWithPriority(999, identifier: "iaAccessory.transformEK: W >= H")
        transformButton.widthAnchor.constraint(equalTo: transformButton.heightAnchor, multiplier: 1.33).activateWithPriority(800, identifier: "iaAccessory.transformEK: W = H*1.33")
        transformButton.layer.borderColor = kButtonBorderColor
        transformButton.layer.borderWidth = kButtonBorderThickness
    
        //MARK: OptionButton (cog) setup
        
        optionButton = UIButton(type: .custom)
        optionButton.backgroundColor = kButtonBackgroundColor
        let gear = UIImage(named: "optionsGear", in: IAKitPreferences.bundle, compatibleWith: self.traitCollection)!.withRenderingMode(.alwaysTemplate)
        optionButton.setImage(gear.withRenderingMode(.alwaysTemplate), for: UIControlState())
        optionButton.addTarget(self, action: #selector(IAAccessoryVC.optionButtonPressed), for: .touchUpInside)
        optionButton.layer.cornerRadius = kButtonCornerRadius
        optionButton.layer.borderColor = kButtonBorderColor
        optionButton.layer.borderWidth = kButtonBorderThickness
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        optionButton.setContentCompressionResistancePriority(400, for: .horizontal)
        optionButton.widthAnchor.constraint(equalTo: optionButton.heightAnchor).activateWithPriority(500, identifier: "iaAccessory.optionButton: W = H")
         
        //MARK: stackview setup

        stackView = UIStackView(arrangedSubviews: [kbSwitchButton, attachmentButton, intensityButton, intensitySlider, tokenizerButton, transformButton,optionButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 2.0
        stackView.heightAnchor.constraint(equalToConstant: kAccessoryHeight).activateWithPriority(1000)
        
        inputView!.addSubview(stackView)
        
        //setup constraints now that all views have been added

        stackView.topAnchor.constraint(equalTo: view.topAnchor).activateWithPriority(999, identifier: "iaAccessory.stackView.top")
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activateWithPriority(999, identifier: "iaAccessory.stackView.bottom")
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor).activateWithPriority(1000, identifier: "iaAccessory.stackView.left")
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor).activateWithPriority(900, identifier: "iaAccessory.stackView.right")
        
        self.inputView!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: kAccessoryHeight)
        
    }
    
    //MARK:- Lifecycle and resizing layout
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        RawIntensity.touchInterpreter.activate()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layoutForBoundsAndKeyboard(size)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    fileprivate var currentLayoutIsForIAKeyboard:Bool = true
    
    func updateAccessoryLayout(_ usingIAKeyboard:Bool){
        self.currentLayoutIsForIAKeyboard = usingIAKeyboard
        layoutForBoundsAndKeyboard()
    }

    func layoutForBoundsAndKeyboard(_ size:CGSize? = nil){
        let newSize = size ?? UIScreen.main.bounds.size
        let isWideView = newSize.width >= 450
        //let iaShowing = self.delegate?.iaKeyboardIsShowing() ?? true
        switch (isWideView, currentLayoutIsForIAKeyboard) {
        case (false,false): //portrait, system keyboard
            intensitySlider.isHidden = false; tokenizerButton.isHidden = true; transformButton.isHidden = true
        case (true,false): //landscape, system keyboard
            intensitySlider.isHidden = false; tokenizerButton.isHidden = false; transformButton.isHidden = false
        case (false,true): //portrait, iaKeyboard
            intensitySlider.isHidden = true; tokenizerButton.isHidden = false; transformButton.isHidden = false
        case (true,true): //landscape, iaKeyboard
            intensitySlider.isHidden = false; tokenizerButton.isHidden = false; transformButton.isHidden = false
        }
    }

}
