//
//  Date+String+Extension.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 27/04/2021.
//

import Foundation

extension Date {
    
    var ordinalStringForDay: String {
        let calendar = Calendar.current
        let dateComponents = calendar.component(.day, from: self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal

        let day = numberFormatter.string(from: dateComponents as NSNumber)
        return day ?? "none"
    }
    
    var dayMonthYearString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return dateFormatter.string(from: self)
    }
    
    var hourMinuteString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("h:mm a")
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        return dateFormatter.string(from: self)
    }
    
}

extension TimeZone {
    init?(iso8601: String) {
        let tz = iso8601.dropFirst(21) // remove yyyy-MM-ddTHH:mm:ss part
        if tz == "Z" {
            self.init(secondsFromGMT: 0)
        } else if tz.count == 3 { // assume +/-HH
            if let hour = Int(tz) {
                self.init(secondsFromGMT: hour * 3600)
                return
            }
        } else if tz.count == 5 { // assume +/-HHMM
            if let hour = Int(tz.dropLast(2)), let min = Int(tz.dropFirst(3)) {
                self.init(secondsFromGMT: (hour * 60 + min) * 60)
                return
            }
        } else if tz.count == 6 { // assime +/-HH:MM
            let parts = tz.components(separatedBy: ":")
            if parts.count == 2 {
                if let hour = Int(parts[0]), let min = Int(parts[1]) {
                    self.init(secondsFromGMT: (hour * 60 + min) * 60)
                    return
                }
            }
        }

        return nil
    }
}

extension String {
    func convertISODate() -> Date? {
        let isoDate = self

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let date = dateFormatter.date(from:isoDate)
        return date
    }
    
    func convertISOToTimzeon() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let date = dateFormatter.date(from:self)
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.zzz"
        let output = String(dateFormatter.string(from: date!).suffix(4))
        if output == "CEST" || output == ".CET" {
            return "GMT"
        }
        return output
    }
}
