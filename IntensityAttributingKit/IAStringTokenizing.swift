//
//  IAStringTokenizing.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/12/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


///Intensity tokenizing determines how intensity values are smoothed/averaged across text when displayed. Intensity can be displayed at the individual character level of granularity or values can be averaged by words, sentences, or the entire message.
public enum IAStringTokenizing:String, CustomStringConvertible {
    case Char = "Char",
    Word = "Word",
    Sentence = "Sequence",
    Line = "Line",
    Paragraph = "Paragraph",
    Message = "Message"
    
    
    
    public var description:String {
        switch self {
        case .Char: return "Char"
        case .Word: return "Word"
        case .Sentence: return "Sentence"
        case .Line: return "Line"
        case .Paragraph: return "Paragraph"
        case .Message: return "Message"
        }
    }
    
    public var enumerationOption:NSString.EnumerationOptions!{
        switch self {
        case .Char: return .byComposedCharacterSequences
        case .Word: return .byWords
        case .Sentence: return .bySentences
        case .Line: return NSString.EnumerationOptions()
        case .Paragraph: return .byParagraphs
        default:return nil
        }
        
    }
    
    public init!(enumerationOption:NSString.EnumerationOptions){
        if enumerationOption.contains(.byComposedCharacterSequences){
            self = .Char
        } else if enumerationOption.contains(.byWords) {
            self = .Word
        } else if enumerationOption.contains(.bySentences){
            self = .Sentence
        } else if enumerationOption.contains(NSString.EnumerationOptions()) {
            self = .Line
        }else if enumerationOption.contains(.byParagraphs){
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
        case .Message: return "M"
        }
    }
    
    public init!(shortLabel:String!){
        guard shortLabel != nil else {return nil}
        switch shortLabel {
        case IAStringTokenizing.Char.shortLabel: self = .Char
        case IAStringTokenizing.Word.shortLabel: self = .Word
        case IAStringTokenizing.Sentence.shortLabel: self = .Sentence
        case IAStringTokenizing.Line.shortLabel: self = .Line
        case IAStringTokenizing.Paragraph.shortLabel: self = .Paragraph
        case IAStringTokenizing.Message.shortLabel: self = .Message
        default: return nil
        }
    }
    
    public var granularity:UITextGranularity {
        switch self {
        case .Char: return .character
        case .Word: return .word
        case .Sentence: return .sentence
        case .Paragraph: return .paragraph
        case .Line: return .line
        case .Message: return .document
        }
    }
    
    init(granularity:UITextGranularity){
        switch granularity {
        case .character: self = .Char
        case .word: self = .Word
        case .sentence: self = .Sentence
        case .paragraph: self = .Paragraph
        case .line: self = .Line
        case .document: self = .Message
        }
    }
    
}
