//
//  PhoneField.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation
import UIKit
import FlagPhoneNumber

class EmailField: CustomTextField {
   
    let loader: CustomIndicatorView = CustomIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24), color: Colors.blue, width: 2.0)
    var isLoading: Bool = false {
        didSet{
            isLoading ?  loader.startAnimating() : loader.stopAnimating()
        }
    }

    // Customizing the text field's appearance
    override func setupTextField() {
        super.setupTextField()
       
        // Create a container view
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        containerView.addSubview(loader)

        // Set the size of the container view
        let containerWidth: CGFloat = 24  // Fixed width for the container view
        let containerHeight: CGFloat = 24
        containerView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
        self.rightView = containerView
        self.rightViewMode = .always
        
        // Constraints for the UIImageView
        loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loader.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            loader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor), // Left padding
            loader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16), // Right padding
            loader.widthAnchor.constraint(equalToConstant: 24),  // Set the loader size if needed
            loader.heightAnchor.constraint(equalToConstant: 24)
        ])
        loader.stopAnimating()
        // Set the container view as the rightView
     
    }

}
