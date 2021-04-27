//
//  PaddingTextField.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 26/04/2021.
//

import UIKit

class PaddingTextField: UITextField {
    var applyPadding: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private let padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return applyPadding ? bounds.inset(by: padding) : bounds
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return applyPadding ? bounds.inset(by: padding) : bounds
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return applyPadding ? bounds.inset(by: padding) : bounds
    }
    
    private func configure() {
        self.layer.cornerRadius = 24
        self.layer.masksToBounds = true
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.textColor = UIColor(red: 0.165, green: 0.18, blue: 0.263, alpha: 1)
        
        self.font = UIFont(name: "CircularStd-Medium", size: 24)
        
        self.textAlignment = .center
        self.keyboardType = .numberPad
        self.attributedPlaceholder = NSAttributedString(string: "No. of users",
                                                        attributes: [NSAttributedString.Key.foregroundColor: C.Color.grayText])
    }
    
    func changeFontSize(shrink: Bool) {
        self.font = shrink ? UIFont(name: "CircularStd-Medium", size: 17) : UIFont(name: "CircularStd-Medium", size: 24) 
    }
    
}
