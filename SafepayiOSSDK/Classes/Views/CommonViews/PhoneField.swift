//
//  PhoneField.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation
import UIKit
import FlagPhoneNumber

class PhoneNumberTextField: FPNTextField, InputValidatable {
    var validityDelegate: ValidityUpdateDelegate?
    private var isActive: Bool?
    let debouncer = Debouncer()

    var inputValid = false {
        didSet {
            debouncer.call {
                self.setErrorState(self.inputValid)
                self.validityDelegate?.onValidityChanged(self, inputValid: self.inputValid)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }

    // Customizing the text field's appearance
    private func setupTextField() {
        let placeholderText = "Enter Your Mobile Number"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.fieldPlaceholderColor, // Placeholder color
            .font: UIFont.systemFont(ofSize: 15, weight: .regular) // Placeholder font
        ]
        self.keyboardType = .phonePad
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = Colors.fieldBorder.cgColor
        self.backgroundColor = Colors.fieldBackgroundColor
        self.textColor = Colors.fieldTextColor
        self.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        self.displayMode = .list // .picker by default
        self.flagButtonSize = CGSize(width: 50, height: 50)
        
        self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }

    // Method to handle error state with red border
    func setErrorState(_ inputValid: Bool) {
        if inputValid {
            self.layer.borderColor = (isActive ?? false) ? Colors.activeFieldBorder.cgColor : Colors.fieldBorder.cgColor
        } else {
            self.layer.borderColor = Colors.error.cgColor // Red error border color
        }
    }
    
    @objc open func editingDidBegin() {
        isActive = true
        self.layer.borderWidth = 2.0
        self.layer.borderColor =  Colors.activeFieldBorder.cgColor
    }
    
    @objc open func editingDidEnd() {
        isActive = false
        self.layer.borderWidth = 1.0
        self.layer.borderColor =  Colors.fieldBorder.cgColor
    }
}
