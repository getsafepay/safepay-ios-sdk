//
//  PhoneField.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation
import UIKit
import FlagPhoneNumber

class CountryField: CustomTextField {
    
    public var country: FPNCountryCode?
    
    override var text: String? {
        didSet {
            validateInput()
        }
    }

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupTextField()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupTextField()
//    }

    // Customizing the text field's appearance
    override func setupTextField() {
        super.setupTextField()
        self.isUserInteractionEnabled = false
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = Colors.fieldBorder.cgColor
        self.font = UIFont.systemFont(ofSize: 15, weight: .regular)

        if let arrowDownImage = UIImage(systemName: "chevron.down") {
            // Create a container view
            let containerView = UIView()
            containerView.backgroundColor = UIColor.clear  // Optional: Set background color for debugging
            
            // Create the UIImageView
            let imageView = UIImageView(image: arrowDownImage)
            imageView.tintColor = .gray  // Optionally set a tint color
            
            // Add UIImageView to the container view
            containerView.addSubview(imageView)
            
            // Set the size of the container view
            let containerWidth: CGFloat = 40  // Fixed width for the container view
            let containerHeight: CGFloat = self.frame.height
            containerView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
            
            // Constraints for the UIImageView
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10), // Left padding
                imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10) // Right padding
            ])
            
            // Set the container view as the rightView
            self.rightView = containerView
            self.rightViewMode = .always
        }
    }

}
