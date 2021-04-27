//
//  C.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 23/04/2021.
//

import UIKit

struct C {
    struct Color {
        static let purple = UIColor(red: 0.337, green: 0.149, blue: 0.957, alpha: 1)
        static let gray = UIColor(red: 0.914, green: 0.914, blue: 0.945, alpha: 1)
        static let skratchNavy = UIColor(red: 0.165, green: 0.18, blue: 0.263, alpha: 1)
        static let grayText = UIColor(red: 0.742, green: 0.742, blue: 0.742, alpha: 1)
        static let paleBlue = UIColor(red: 0.825, green: 0.831, blue: 0.891, alpha: 1)
        static let ultraLight = UIColor(red: 0.964, green: 0.964, blue: 0.964, alpha: 1)
    }
    
    struct Image {
        static let listSegmentedControlImage = UIImage(named: "listSegmentedControlImage")!
        static let mapSegmentedControlImage = UIImage(named: "mapSegmentedControlImage")!
        static let checkmark = UIImage(named: "checkmark")!
        static let ballonIcon = UIImage(named: "ballonIcon")!
        static let locationIcon = UIImage(named: "location")!
        static let phoneIcon = UIImage(named: "phoneIcon")!
        static let emailIcon = UIImage(named: "emailIcon")!
    }
    
    struct Font {
        static let CircularStdBook = "CircularStd-Book"
        static let CircularStdBlack = "CircularStd-Black"
        static let CircularStdMedium = "CircularStd-Medium"
        static let CircularStdBold = "CircularStd-Bold"
    }
}
