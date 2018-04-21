//
//  ExtentionString.swift
//  MySecret
//
//  Created by amir lahav on 8.10.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    static func random(length: Int = 16) -> String {
        
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: String.IndexDistance(randomValue))])"
        }
        return randomString
    }
    

    static func getHeaderSubtitle(date:String, country:String) -> String
    {
        return "\(date)  \u{00B7}  \(country)"
    }
    
    static func getDate(date: Date,sectionType:SectionType) -> String
    {
        
        switch sectionType {
        case .day:
            return getDate(date: date)
        case .month:
            return getMonthDate(date: date)
        case .year:
            return getYearDate(date: date)
        default:
            break
        }
        
        
        return ""
    }

    static func getDate(date: Date) -> String
    {
        let sysDate = Date()
        let diff = date.interval(ofComponent: .day, fromDate: sysDate)
        switch diff {
        case 0:
            return "Today"
        case (-1):
            return "Yesterday"
        case (-6)...(-2):
            return getWeekday(date: date)
        default:
            return getDateString(date: date)
        }
        
    }
    
    func containsIgnoreCase(_ string: String) -> Bool {
        return self.lowercased().contains(string.lowercased())
    }
    
        func startsWith(string: String) -> Bool {
            guard let range = range(of: string, options:[.anchored,.caseInsensitive]) else {
                return false
            }
            return range.lowerBound == startIndex
        }
    
        func caseInsensitiveHasPrefix(_ prefix: String) -> Bool {
            return lowercased().hasPrefix(prefix.lowercased())
        }
    

    
    
    static func getWeekday(date:Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
        
    }
    
    static func getShortDate(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = DateFormatter.Style.short
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
    
    static func getYearDate(date:Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
    
    static func getMonthDate(date:Date) -> String
    {
        let today = Date()
        let calendar = Calendar.init(identifier: .gregorian)
        let year = calendar.component(.year, from: today)
        let dateYear = calendar.component(.year, from: date)
        let isEqual = year == dateYear
        let dateFormatter = DateFormatter()
        

            switch isEqual {
            case true:
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
            default:
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMM, yyyy")
            }
            
            let convertedDate = dateFormatter.string(from: date)
            return convertedDate
        
    }
    
    static func getDateString(date: Date) -> String
    {
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today)
        let dateYear = calendar.component(.year, from: date)
        let isEqual = year == dateYear
        let dateFormatter = DateFormatter()

        switch isEqual {
        case true:
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd")
        default:
            dateFormatter.locale = Locale.current
            dateFormatter.dateStyle = DateFormatter.Style.long
        }

        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
    
    static func getTimeFromDateString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeStyle = DateFormatter.Style.short
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
    
    static func convertStringToDate(string:String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return dateFormatter.date(from:string)!
        
        
        
        //        dateFormatter.dateStyle = DateFormatter.Style.short //Your date format
        //        let date = dateFormatter.date(from: string)
        //        return date!
        
    }
    
    static  func stringFromTimeInterval(interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        if interval >= 3600 {
            formatter.allowedUnits.insert(.hour)
        }
        
        return formatter.string(from: interval)!
    }
    
    static func photoCountToString(count: Int) -> String
    {
        switch count == 1 {
        case true: return "1 Asset"
        default: return "\(count) Assets"
        }
    }
    
    var first: String {
        return String(characters.prefix(1))
    }
    var last: String {
        return String(characters.suffix(1))
    }
    var uppercaseFirst: String {
        return first.uppercased() + String(characters.dropFirst())
    }
    
    static func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.gray ])
        let boldFontAttribute: [String: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: font.pointSize, weight: UIFontWeightSemibold)]
        let blackFontAttribute = [NSForegroundColorAttributeName: UIColor.black]
        guard let range = string.lowercased().range(of: boldString.lowercased()) else {return attributedString}
        let newRange = NSRange(range, in:string)
        attributedString.addAttributes(boldFontAttribute, range: newRange)
        attributedString.addAttributes(blackFontAttribute, range: newRange)
        return attributedString
    }
}
