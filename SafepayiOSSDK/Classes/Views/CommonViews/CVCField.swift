//
//  CVCTextField.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation
import UIKit

class CVCTextField: CustomTextField, UITextFieldDelegate {
    
    override func setupTextField() {
        super.setupTextField()
        self.keyboardType = .numberPad
        self.delegate = self
        self.placeholder = "CVC"
        self.validator = CVCValidator()
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
        if newLength > 3 {
            return false
        }
        
        return true
    }
}
