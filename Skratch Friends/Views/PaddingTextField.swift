//
//  PaddingTextField.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 26/04/2021.
//

import UIKit

class PaddingTextField: UITextField {
    var applyPadding: Bool = false

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
}
