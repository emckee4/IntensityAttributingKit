//
//  scrap.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/11/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

//import Foundation



//extension IACompositeTextEditor {
//
//    func setTopTVInputDelegate(){
//        let intermediateInputDelegate = TextInputDelegateIntermediary()
//        intermediateInputDelegate.owningCompositeTE = self
//        topTV.inputDelegate = intermediateInputDelegate
//    }
//
//    private func topTVSelectionDidChange(){
//        updateSelectionIndicators()
//        inputDelegate?.selectionDidChange(self)
//    }
//
//    private func topTVSelectionWillChange(){
//        inputDelegate?.selectionWillChange(self)
//    }
//
//    private func topTVTextWillChange(){
//        inputDelegate?.textWillChange(self)
//    }
//
//    private func topTVTextDidChange(){
//        inputDelegate?.textDidChange(self)
//    }
//
//}
//
//private class TextInputDelegateIntermediary:NSObject,UITextInputDelegate {
//    weak var owningCompositeTE:IACompositeTextEditor?
//    @objc private func textDidChange(textInput: UITextInput?) {
//        owningCompositeTE?.topTVTextDidChange()
//    }
//    @objc private func textWillChange(textInput: UITextInput?) {
//        owningCompositeTE?.topTVTextWillChange()
//    }
//    @objc private func selectionDidChange(textInput: UITextInput?) {
//        owningCompositeTE?.topTVSelectionDidChange()
//    }
//    @objc private func selectionWillChange(textInput: UITextInput?) {
//        owningCompositeTE?.topTVTextWillChange()
//    }
//}
