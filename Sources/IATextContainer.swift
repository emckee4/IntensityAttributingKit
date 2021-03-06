//
//  IATextContainer.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/4/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


///The IATextContainer provides means for requesting standard thumbnail sizes when the layout manager calls the IATextAttachment's NSTextAttachmentContainer protocol functions. This allows us to leverage the built in typesetter and TextKit layout engine for integrating text and image layout.
final public class IATextContainer:NSTextContainer {
    ///This flag can be used to indicate to the IATextAttachments that they should return nil from imageForBounds because the image will be drawn by in another layer. This is the standard behavior for the IAKit
    var shouldPresentEmptyImageContainers:Bool = true
    var preferedThumbSize:IAThumbSize = .Medium {
        didSet{
            if preferedThumbSize != oldValue {layoutManager?.textContainerChangedGeometry(self)}
        }
    }
    
    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(preferedThumbSize.rawValue, forKey: "thumbsize")
        aCoder.encode(shouldPresentEmptyImageContainers, forKey: "shouldPresentEmptyImages")
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        if let tsname = coder.decodeObject(forKey: "thumbsize") as? String {
            if let ts = IAThumbSize(rawValue: tsname) {
                preferedThumbSize = ts
            }
        }
        if let emptyImages = coder.decodeObject(forKey: "shouldPresentEmptyImages") as? Bool {
            shouldPresentEmptyImageContainers = emptyImages
        }
    }
    
    init(){
        super.init(size:CGSize.zero)
    }
    
    override init(size:CGSize){
        super.init(size: size)
    }
    
}
