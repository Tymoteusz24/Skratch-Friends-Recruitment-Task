//
//  UIView+Extension.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 26/04/2021.
//

import UIKit


extension UIView {
    func setupShadow() {
        let layer = self.layer
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: bounds.width/2).cgPath
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.black.cgColor
        
    }
}
