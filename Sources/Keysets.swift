//
//  Keysets.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/7/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


struct AvailableIAKeysets {
    static var BasicEnglish =  IAKeyset(name: "BasicEnglish", keyPages:
        [
            IAKeyPage(
                pageName: "Alpha",
                qRow: ["q","w","e","r","t","y","u","i","o","p"],
                aRow: ["a","s","d","f","g","h","j","k","l"],
                zRow: ["z","x","c","v","b","n","m"]
            ),
            IAKeyPage(pageName: "Numpad",
                qRow: ["1","2","3","4","5","6","7","8","9","0"],
                aRow: ["-","~",":",";","(",")","$","&","@","\""],
                zRow: [".","+","=","*","/","\\","'"]
            )
        ]
    )
}

