//
//  CardExpiryField.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation
import UIKit

class CardExpiryTextField: CustomTextField, UITextFieldDelegate {
    
    override func setupTextField() {
        super.setupTextField()
        self.keyboardType = .numberPad
        self.delegate = self
        self.placeholder = "Expiry MM/YY"
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc override func editingChanged() {
        self.formatExpiryDate()

        debouncer.call {
            self.validateExpiryDate()
        }
    }
    
    private func formatExpiryDate() {
        guard let text = self.text else { return }
        // Remove any non-digit characters
        var rawText = text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Limit to 4 digits (MMYY)
        if rawText.count > 4 {
            rawText = String(rawText.prefix(4))
        }
        
        // Apply MM/YY format
        if rawText.count >= 3 {
            let month = rawText.prefix(2)
            let year = rawText.suffix(from: rawText.index(rawText.startIndex, offsetBy: 2))
            self.text = "\(month)/\(year)"
        } else {
            self.text = rawText
        }
    }
    
    private func validateExpiryDate() {
        guard let text = self.text, !text.isEmpty else { return }
        
        let components = text.split(separator: "/")
        var isValid = false
        
        // Check if the format is correct and the month is valid
        if components.count == 2, let month = Int(components[0]), let year = Int(components[1]) {
            let currentYear = Calendar.current.component(.year, from: Date()) % 100 // Get last 2 digits of the current year
            let currentMonth = Calendar.current.component(.month, from: Date())
            
            // Check if the expiry date is valid and not in the past
            if (year > currentYear) || (year == currentYear && month >= currentMonth) {
                if month >= 1 && month <= 12 {
                    isValid = true
                }
            }
        }
        
        self.inputValid = isValid
       
    }
    
    // MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        
        // Allow deletion (backspace)
        if string.isEmpty { return true }
        
        // Only allow numbers and "/" separator
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacterSet.isSuperset(of: characterSet) {
            return false
        }
        
        // Check if the new string length is within the limit
        let newLength = currentText.count + string.count - range.length
        if newLength > 5 {
            return false
        }
        
        return true
    }
    
    // Additional validation to ensure the month is between 01 and 12
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateExpiryDate()
    }
}
