//
//  DateConversion.swift
//
//
//  Created by Evan Mckee on 8/9/15.
//
//

import Foundation

class DateConversion {
    
    static let parseUTCDateFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
        return dateFormatter
    }()
    
    static let shortTimeFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let shortDateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let dayOfWeekAndTimeFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("HH:mm EEEE")
        return formatter
    }()
    
    static let shortDTFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    
    ///Converts the parse date string (iso 8601 string) to an NSDate. Returns nil if it fails or is provided a nil value.
    class func convertParseUTCStringToNSDate(_ dateString:String?)->Date?{
        if let dateString = dateString {
            return parseUTCDateFormatter.date(from: dateString)
        }
        return nil
    }
    
    class func convertNSDateUTCToString(_ date:Date)->String{
        return parseUTCDateFormatter.string(from: date)
    }
    
    class func convertNSDateToParseTimestampObject(_ date:Date)->[String:String]{
        return ["__type":"Date","iso":convertNSDateUTCToString(date)]
    }
    
    ///Returns a user friendly string representing the date and time of a message which varies depending on how recent it was
    class func adaptiveDTString(_ date:Date)->String{
        let age = Date().timeIntervalSince(date)
        if age < 86400.0 {
            return shortTimeFormatter.string(from: date)
        } else if age < 172800 {
            return "Yesterday\n\(shortTimeFormatter.string(from: date))"
        } else if age < 518400{
            return dayOfWeekAndTimeFormatter.string(from: date).stringByReplacingFirstOccurrenceOfString(" ", withString: "\n")
        } else {
            return shortDTFormatter.string(from: date).stringByReplacingFirstOccurrenceOfString(" ", withString: "\n")
        }
    }
    
    
    
}

