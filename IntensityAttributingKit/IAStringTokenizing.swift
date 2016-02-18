//
//  IAStringTokenizing.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/12/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation



public enum IAStringTokenizing:CustomStringConvertible {
    case Char,
    Word,
    Sentence,
    Line,
    Paragraph
    
    
    
    public var description:String {
        switch self {
        case .Char: return "Char"
        case .Word: return "Word"
        case .Sentence: return "Sentence"
        case .Line: return "Line"
        case .Paragraph: return "Paragraph"
        }
    }
    
    public var enumerationOption:NSStringEnumerationOptions{
        switch self {
        case .Char: return .ByComposedCharacterSequences
        case .Word: return .ByWords
        case .Sentence: return .BySentences
        case .Line: return .ByLines
        case .Paragraph: return .ByParagraphs
        }
        
    }
    
    public init!(enumerationOption:NSStringEnumerationOptions){
        if enumerationOption.contains(.ByComposedCharacterSequences){
            self = .Char
        } else if enumerationOption.contains(.ByWords) {
            self = .Word
        } else if enumerationOption.contains(.BySentences){
            self = .Sentence
        } else if enumerationOption.contains(.ByLines) {
            self = .Line
        }else if enumerationOption.contains(.ByParagraphs){
            self = .Paragraph
        } else {
            return nil
        }
    }
    
    public var shortLabel:String {
        switch self {
        case .Char: return "Char"
        case .Word: return "Word"
        case .Sentence: return "S"
        case .Line: return "L"
        case .Paragraph: return "P"
        }
    }
    
    public init!(shortLabel:String){
        switch shortLabel {
        case IAStringTokenizing.Char.shortLabel: self = .Char
        case IAStringTokenizing.Word.shortLabel: self = .Word
        case IAStringTokenizing.Sentence.shortLabel: self = .Sentence
        case IAStringTokenizing.Line.shortLabel: self = .Line
        case IAStringTokenizing.Paragraph.shortLabel: self = .Paragraph
        default: return nil
        }
    }
    
}
