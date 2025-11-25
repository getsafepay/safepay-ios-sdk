//
//  CCTextField.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation
import UIKit

class CreditCardTextField: CustomTextField, UITextFieldDelegate {

    // ImageView for card provider icon
    private var cardIconImageView: UIImageView!

    // Card provider detected
    var cardProvider: CardProvider = .unknown {
        didSet {
            updateCardIcon()
        }
    }

    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }

    // Setup TextField with card icon
    fileprivate func setupRightView() {
        // Set up the card icon image view
        let iconSize = CGSize(width: 44, height: 34) // Adjust this size as needed
        let rightPadding: CGFloat = 10 // Adjust this value to increase/decrease right padding
        
        cardIconImageView = UIImageView(frame: CGRect(origin: .zero, size: iconSize))
        cardIconImageView.contentMode = .scaleAspectFit
        
        // Create a container view for the icon to add padding
        let containerWidth = iconSize.width + rightPadding
        let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: containerWidth, height: iconSize.height)))
        containerView.addSubview(cardIconImageView)
        
        // Position the icon image view within the container
        cardIconImageView.frame.origin.x = 0 // Align to the left of the container
        cardIconImageView.center.y = containerView.center.y // Center vertically
        
        self.rightView = containerView
        self.rightViewMode = .always
    }
    
    override func setupTextField() {
        super.setupTextField()
        self.keyboardType = .numberPad
        self.delegate = self
        setupRightView()
    }

    // Handle changes in text field
    @objc override func editingChanged() {
        let text = self.text?.replacingOccurrences(of: " ", with: "") ?? ""
        
        self.cardProvider = CreditCardUtils.detectCardProvider(from: text)
        self.text = CreditCardUtils.formatCardNumber(text)
        
        debouncer.call {
            self.inputValid = CardValidator.validateCardNumber(for: self.cardProvider, cardNumber: text)
        }
    }

    // Update card icon based on detected provider
    private func updateCardIcon() {
        switch cardProvider {
        case .visa:
            cardIconImageView.image = UIImage.fromPod(named: "Visa")
        case .mastercard:
            cardIconImageView.image = UIImage.fromPod(named: "Mastercard")
        case .amex:
            cardIconImageView.image = UIImage.fromPod(named: "Amex")
        case .rupay:
            cardIconImageView.image = UIImage.fromPod(named: "chip")
        case .unionpay:
            cardIconImageView.image = UIImage.fromPod(named: "Unionpay")
        case .unknown:
            cardIconImageView.image = nil
        }
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
        if newLength > 19 { // length with formatting
            return false
        }
        
        return true
    }
}
