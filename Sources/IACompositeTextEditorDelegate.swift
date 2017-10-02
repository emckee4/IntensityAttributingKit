//
//  IACompositeTextEditorDelegate.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 9/24/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import Foundation


@objc public protocol IACompositeTextEditorDelegate:class {
    ///The default implementation of this will present the view controller using the delegate adopter
    @objc optional func iaTextEditorRequestsPresentationOfOptionsVC(_ iaTextEditor:IACompositeTextEditor)->UIViewController?
    @objc optional func iaTextEditorRequestsPresentationOfContentPicker(_ iaTextEditor:IACompositeTextEditor)->UIViewController?
}
