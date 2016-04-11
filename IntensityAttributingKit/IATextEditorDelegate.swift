//
//  IATextEditorDelegate.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/3/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit



public protocol IATextEditorDelegate:class {
    ///The default implementation of this will present the view controller using the delegate adopter
    func iaTextEditorRequestsPresentation(iaTextEditor:IACompositeTextEditor, shouldPresentVC:UIViewController)
    
}
public extension IATextEditorDelegate  {
    public func iaTextEditorRequestsPresentation(iaTextEditor:IACompositeTextEditor, shouldPresentVC:UIViewController){
        guard let vc = self as? UIViewController else {return}
        vc.presentViewController(shouldPresentVC, animated: true) { () -> Void in
            
        }
    }
}
