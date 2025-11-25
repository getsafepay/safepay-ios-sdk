//
//  PayButton.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation
import UIKit

class PayButton: UIButton {
    private var loader: CustomIndicatorView?
    var loading: Bool = false {
        didSet {
            setLoadingState(loading)
        }
    }

    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    // Setup button properties
    private func setupButton() {
        // Height
        self.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        // Font and title properties
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.setTitle("Pay Now", for: .normal)
        
        // Corner radius (optional, makes the button look better)
        self.layer.cornerRadius = 10
        
        // Set colors for enabled and disabled states
        setButtonState(isEnabled: self.isEnabled)
        
        loader = CustomIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height:30),color: UIColor.white,width: 2.0)
        loader?.stopAnimating()
        // Add the loader to the button
        loader?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loader!)

        // Add constraints to center the loader within the button
        NSLayoutConstraint.activate([
            loader!.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -15),
            loader!.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -15)
        ])
        
        let lock = UIImageView(image: UIImage(systemName: "lock.fill"))
        lock.tintColor = UIColor.white.withAlphaComponent(0.7)
        lock.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lock)
      
        // Add constraints to center the loader within the button
        NSLayoutConstraint.activate([
            lock.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14),
            lock.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            lock.heightAnchor.constraint(equalToConstant: 26),
            lock.widthAnchor.constraint(equalToConstant: 26)
        ])
    }

    // Override to update appearance when enabled state changes
    override var isEnabled: Bool {
        didSet {
            setButtonState(isEnabled: isEnabled)
        }
    }

    private func setLoadingState(_ loading: Bool) {
        if loading {
            self.isUserInteractionEnabled = false
            setTitleColor(Colors.blue, for: .normal)
            loader?.startAnimating()
        } else {
            self.isUserInteractionEnabled = true
            setTitleColor(UIColor.white, for: .normal)
            loader?.stopAnimating()
        }
    }
    
    // Method to configure the button based on its state
    private func setButtonState(isEnabled: Bool) {
        if isEnabled {
            self.backgroundColor = Colors.blue // Enabled state color
        } else {
            self.backgroundColor = Colors.disable // Disabled state color
        }
        
        // Optional: Change text color if needed
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(UIColor(hex: "#555555"), for: .disabled)
    }
}
