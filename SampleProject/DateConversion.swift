//
//  DateConversion.swift
//
//
//  Created by Evan Mckee on 8/9/15.
//
//

import Foundation

class DateConversion {
    
    static let parseUTCDateFormatter:NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")!
        return dateFormatter
    }()
    
    static let shortTimeFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .NoStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    static let shortDateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    static let dayOfWeekAndTimeFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.autoupdatingCurrentLocale()
        formatter.setLocalizedDateFormatFromTemplate("HH:mm EEEE")
        return formatter
    }()
    
    static let shortDTFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    
    ///Converts the parse date string (iso 8601 string) to an NSDate. Returns nil if it fails or is provided a nil value.
    class func convertParseUTCStringToNSDate(dateString:String?)->NSDate?{
        if let dateString = dateString {
            return parseUTCDateFormatter.dateFromString(dateString)
        }
        return nil
    }
    
    class func convertNSDateUTCToString(date:NSDate)->String{
        return parseUTCDateFormatter.stringFromDate(date)
    }
    
    class func convertNSDateToParseTimestampObject(date:NSDate)->[String:String]{
        return ["__type":"Date","iso":convertNSDateUTCToString(date)]
    }
    
    ///Returns a user friendly string representing the date and time of a message which varies depending on how recent it was
    class func adaptiveDTString(date:NSDate)->String{
        let age = NSDate().timeIntervalSinceDate(date)
        if age < 86400.0 {
            return shortTimeFormatter.stringFromDate(date)
        } else if age < 172800 {
            return "Yesterday\n\(shortTimeFormatter.stringFromDate(date))"
        } else if age < 518400{
            return dayOfWeekAndTimeFormatter.stringFromDate(date).stringByReplacingFirstOccurrenceOfString(" ", withString: "\n")
        } else {
            return shortDTFormatter.stringFromDate(date).stringByReplacingFirstOccurrenceOfString(" ", withString: "\n")
        }
    }
    
    
    
}

