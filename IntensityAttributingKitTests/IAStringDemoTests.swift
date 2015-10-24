//
//  IAStringDemoTests.swift
//  IAStringDemoTests
//
//  Created by Evan Mckee on 10/22/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import XCTest

import UIKit
@testable import IntensityAttributingKit

class IAStringDemoTests: XCTestCase {
    
    var retainedMAS:NSMutableAttributedString = NSMutableAttributedString()
    var textView:UITextView!
    var count:Int = 0 {
        didSet {
            if count % 5 == 0 {
                cycleCount++
            }
            if count > 100 {
                count = 0
            }
        }
    }
    var cycleCount = 0
    //var preserveText = false
    var transformToggling = false

    var iterationRange = 0...200
    
    var scheme:IntensityTransformers = .WeightScheme
    var currentScheme:String {
        get {return scheme.rawValue}
        set {scheme = IntensityTransformers(rawValue: newValue)!}
    }
    
    
    override func setUp() {
        super.setUp()
        constructionBenchSetup()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
//    func testConstruction() {
//        
//        self.measureBlock {
//            self.textView.text = ""
//            for _ in 0...100{
//                
//                self.updateWithRetainedMAS()
//            }
//
//            
//        }
//    }
    
    
    func testupdateIAUpdateOption() {
        
        self.measureMetrics(XCTestCase.defaultPerformanceMetrics(), automaticallyStartMeasuring: false) { () -> Void in
            self.textView.text = ""
            self.startMeasuring()
            for _ in self.iterationRange{
                self.updateIAUpdateOption()
            }
            self.stopMeasuring()
        }
        
    }
    
    
    func testupdateRetainedMASOnly() {
        
        self.measureMetrics(XCTestCase.defaultPerformanceMetrics(), automaticallyStartMeasuring: false) { () -> Void in
            self.retainedMAS.deleteCharactersInRange(NSRange(location: 0, length: self.retainedMAS.length))
            self.startMeasuring()
            for _ in self.iterationRange{
                self.updateRetainedMASOnly()
            }
            self.stopMeasuring()
        }
        
    }
    
    func testupdateWithRetainedMAS() {

        self.measureMetrics(XCTestCase.defaultPerformanceMetrics(), automaticallyStartMeasuring: false) { () -> Void in
            self.retainedMAS.deleteCharactersInRange(NSRange(location: 0, length: self.retainedMAS.length))
            self.startMeasuring()
            for _ in self.iterationRange{
                self.updateWithRetainedMAS()
            }
            self.stopMeasuring()
        }

    }

    
    func testTransformMASOnly(){
        for _ in self.iterationRange{
            self.updateWithRetainedMAS()
        }
        self.measureBlock { () -> Void in
            self.transformMASOnly()
        }
    }
    
    func testTransformTV(){
        for _ in self.iterationRange{
            self.updateWithRetainedMAS()
        }
        self.measureBlock { () -> Void in
            self.transformTV()
        }
        
    }
        
    func updateIAUpdateOption(){
        let newIntensity = intensityAttributesForCycleIndex()
        
        let newText = String(count / 10)
        
        let insertPortion = NSAttributedString(string: newText, defaultAttributes: newIntensity, renderWithScheme: currentScheme)
        let mutCurrent = NSMutableAttributedString(attributedString: textView.attributedText)
        mutCurrent.appendAttributedString(insertPortion)

        if transformToggling && cycleCount % 10 == 9 {
            toggleScheme()
            mutCurrent.transformWithRenderSchemeInPlace(currentScheme)
        }
        
        textView.attributedText = mutCurrent
        count++

    }
    
    
    func updateRetainedMASOnly(){
        let newIntensity = intensityAttributesForCycleIndex()
        
        let newText = String(count / 10)
        
        let insertPortion = NSAttributedString(string: newText, defaultAttributes: newIntensity, renderWithScheme: currentScheme)
        retainedMAS.appendAttributedString(insertPortion)
        
        if transformToggling && cycleCount % 10 == 9 {
            toggleScheme()
            retainedMAS.transformWithRenderSchemeInPlace(currentScheme)
        }

        count++
        
    }
    
    func updateWithRetainedMAS(){
        let newIntensity = intensityAttributesForCycleIndex()
        
        let newText = String(count / 10)
        
        let insertPortion = NSAttributedString(string: newText, defaultAttributes: newIntensity, renderWithScheme: currentScheme)
        retainedMAS.appendAttributedString(insertPortion)
        
        if transformToggling && cycleCount % 10 == 9 {
            toggleScheme()
            retainedMAS.transformWithRenderSchemeInPlace(currentScheme)
        }
        textView.attributedText = NSAttributedString(attributedString:retainedMAS)
        count++
        
    }
    
    
    func transformMASOnly(){
        toggleScheme()
        retainedMAS.transformWithRenderSchemeInPlace(currentScheme)
    }
    
    func transformTV(){
        toggleScheme()
        textView.attributedText = textView.attributedText.transformWithRenderScheme(currentScheme)
    }
    
    func constructionBenchSetup(){
        textView = UITextView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        //var textView:UITextView!
//        let IAUpdateOption = "updateIAUpdateOption"
//        let AttStringUpdate = "updateAttStringUpdate"
//        let RetainSeparateMAS = "updateRetainSeparateMAS"
//        let BGThreadSeparateMAS = "updateBGThreadSeparateMAS"
//        
//        var kUpdateOption:String {return IAUpdateOption}

        count = 0
        cycleCount = 0
        currentScheme = "TextColorScheme"//"WeightScheme"
        retainedMAS = NSMutableAttributedString()
        
//        if preserveText && NSFileManager.defaultManager().fileExistsAtPath(mutFP){
//            retainedMAS = NSKeyedUnarchiver.unarchiveObjectWithFile(mutFP) as! NSMutableAttributedString
//        }

    }
    
    func toggleScheme(){
        let possibleSchemes:[String] = Array(availableIntensityTransformers.keys)
        let currentIndex = possibleSchemes.indexOf(currentScheme)!
        currentScheme = currentIndex < possibleSchemes.count - 1 ? possibleSchemes[currentIndex + 1] : possibleSchemes[0]
    }
    func intensityAttributesForCycleIndex()->IntensityAttributes{
        var ia = IntensityAttributes(intensity: Float(count) / 100.0, size: 18.0)
        if cycleCount % 3 == 1{
            ia.isBold = true
        }
        if cycleCount % 4 == 2{
            ia.isItalic = true
        }
        if cycleCount % 5 == 3{
            ia.isUnderlined = true
        }
        if cycleCount % 7 == 4{
            ia.isStrikethrough = true
        }
        return ia
    }
    
}



//extension NSAttributedString {
//    func stripIAData()->NSAttributedString{
//        var astringCopy = NSMutableAttributedString(attributedString: self)
//        let range = NSRange(location: 0, length: astringCopy.length)
//        for attName in IATags.allTags {
//            
//            astringCopy.removeAttribute(attName, range: range)
//        }
//        return astringCopy
//    }
//}
