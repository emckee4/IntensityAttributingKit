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

    var iaAccessoryView:IAAccessoryView!
    var delegate:IAAccessoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
    func setupVC(){
        iaAccessoryView = IAAccessoryView()
        iaAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        inputView!.addSubview(iaAccessoryView)
        inputView!.translatesAutoresizingMaskIntoConstraints = false
        inputView!.heightAnchor.constraint(equalToConstant: iaAccessoryView.kAccessoryHeight).isActive = true
        inputView!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - inputView!.safeAreaInsets.left - inputView!.safeAreaInsets.right, height: iaAccessoryView.kAccessoryHeight)
        
        iaAccessoryView!.backgroundColor = IAKitPreferences.visualPreferences.accessoryBackgroundColor
        iaAccessoryView!.translatesAutoresizingMaskIntoConstraints = false
        iaAccessoryView!.layer.rasterizationScale = UIScreen.main.scale
        iaAccessoryView!.layer.shouldRasterize = true
        iaAccessoryView!.tintColor = IAKitPreferences.visualPreferences.accessoryTintColor
        iaAccessoryView.kbSwitchButton.addTarget(self, action: #selector(IAAccessoryVC.kbSwitchButtonPressed(_:)), for: .touchUpInside)
        iaAccessoryView.intensitySlider.addTarget(self, action: #selector(IAAccessoryVC.sliderValueChanged(_:)), for: .valueChanged)
        iaAccessoryView.optionButton.addTarget(self, action: #selector(IAAccessoryVC.optionButtonPressed), for: .touchUpInside)
        iaAccessoryView.attachmentButton.setSelector(self, selector: "attachmentButtonPressed:")
        iaAccessoryView.tokenizerButton.setSelector(self, selector: "tokenizerButtonPressed:")
        iaAccessoryView.transformButton.setSelector(self, selector: "transformButtonPressed:")
        iaAccessoryView.intensityButton.delegate = self
        
        iaAccessoryView.topAnchor.constraint(equalTo: inputView!.safeAreaLayoutGuide.topAnchor, constant: 1).activateWithPriority(1000, identifier: "iaAccessory.stackView.top")
        iaAccessoryView.bottomAnchor.constraint(equalTo: inputView!.safeAreaLayoutGuide.bottomAnchor, constant: -1).activateWithPriority(1000, identifier: "iaAccessory.stackView.bottom")
        iaAccessoryView.leftAnchor.constraint(equalTo: inputView!.safeAreaLayoutGuide.leftAnchor, constant: 1).activateWithPriority(1000, identifier: "iaAccessory.stackView.left")
        iaAccessoryView.rightAnchor.constraint(equalTo: inputView!.safeAreaLayoutGuide.rightAnchor, constant: -1).activateWithPriority(1000, identifier: "iaAccessory.stackView.right")
        
        self.inputView!.backgroundColor = IAKitPreferences.visualPreferences.kbBackgroundColor
        iaAccessoryView.backgroundColor = IAKitPreferences.visualPreferences.accessoryBackgroundColor
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
            iaAccessoryView.intensitySlider.isHidden = false; iaAccessoryView.tokenizerButton.isHidden = true; iaAccessoryView.transformButton.isHidden = true
        case (true,false): //landscape, system keyboard
            iaAccessoryView.intensitySlider.isHidden = false; iaAccessoryView.tokenizerButton.isHidden = false; iaAccessoryView.transformButton.isHidden = false
        case (false,true): //portrait, iaKeyboard
            iaAccessoryView.intensitySlider.isHidden = true; iaAccessoryView.tokenizerButton.isHidden = false; iaAccessoryView.transformButton.isHidden = false
        case (true,true): //landscape, iaKeyboard
            iaAccessoryView.intensitySlider.isHidden = false; iaAccessoryView.tokenizerButton.isHidden = false; iaAccessoryView.transformButton.isHidden = false
        }
    }

}
