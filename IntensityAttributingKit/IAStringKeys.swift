//
//  IAStringKeys.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/26/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


public struct IAStringKeys {
    public static let text = "text"
    public static let intensities = "intensities"
    public static let linkRVPs = "linkRVPs"
    public static let attachments = "attachments"
    public static let baseAttributes = "iaBaseAttributes"
    public static let renderScheme = "renderScheme"
    public static let preferedSmoothing = "preferedSmoothing"
    public static let options = "options"
    
    ///Used for transfering iaTextAttachments within the app. The data objects contained within this key shouldnt be transfered externally
    public static let iaTextAttachments = "iaTextAttachments"
}