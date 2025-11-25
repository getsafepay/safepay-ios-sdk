//
//  PasswordTextField.swift
//  SafepayiOSSDK
//
//  Created by [Your Name] on [Date].
//

import Foundation
import UIKit

class PasswordTextField: CustomTextField {

    private let eyeButton = UIButton(type: .custom)

    override func setupTextField() {
        super.setupTextField()
        self.isSecureTextEntry = true
        self.placeholder = "Password"
        self.keyboardType = .default
        self.rightViewMode = .always
        self.validator = PasswordValidator()

        // Configure the eye button
        setupEyeButton()
    }

    private func setupEyeButton() {
        let eyeImage = UIImage(systemName: "eye.fill") // Default eye icon
        let eyeSlashImage = UIImage(systemName: "eye.slash.fill") // Eye with slash (hidden state)
        
        eyeButton.setImage(eyeImage, for: .normal)
        eyeButton.setImage(eyeSlashImage, for: .selected)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        eyeButton.tintColor = Colors.blue

        // Create a container view
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        containerView.addSubview(eyeButton)
        
        // Set the size of the container view
        let containerWidth: CGFloat = 24  // Fixed width for the container view
        let containerHeight: CGFloat = 24
        containerView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
        self.rightView = containerView
        self.rightViewMode = .always
        
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eyeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            eyeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor), // Left padding
            eyeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16), // Right padding
            eyeButton.widthAnchor.constraint(equalToConstant: 24),  // Set the loader size if needed
            eyeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    @objc private func togglePasswordVisibility() {
        // Toggle the secure text entry mode
        self.isSecureTextEntry.toggle()
        eyeButton.isSelected.toggle() // Change button's image accordingly

        // Fix the bug where the text disappears on toggling secure text entry
        if let existingText = self.text {
            self.text = ""
            self.insertText(existingText)
        }
    }
}
