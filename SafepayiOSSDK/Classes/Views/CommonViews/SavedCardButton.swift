//
//  CustomButton.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation
import UIKit

class SavedCardButton: UIButton {
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // Setup button properties
    private func setupButton() {
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.widthAnchor.constraint(equalToConstant: 200).isActive = true
        self.backgroundColor = Colors.lightBlue
        self.setTitleColor(Colors.blue, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        self.layer.cornerRadius = 10
        
        // Adding shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1  // Adjust for darkness (0 to 1)
        self.layer.shadowOffset = CGSize(width: 2, height: 2) // Position of shadow
        self.layer.shadowRadius = 5  // Blur effect

        self.layer.masksToBounds = false  // Ensure shadow is visible outside bounds
    }
}
