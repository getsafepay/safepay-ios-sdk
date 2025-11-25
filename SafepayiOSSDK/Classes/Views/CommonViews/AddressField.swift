//
//  AddressField.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 11/13/24.
//

import Foundation

class AddressField: CustomTextField, UITextFieldDelegate {
    var required: Bool = true
    var selectedOption: Option? {
        didSet {
            guard let _option = selectedOption else {
                text = ""
                return
            }
            
            text = _option.name
        }
    }
    
    var optionValueOrText: String? {
        if addressComponent?.hasOptions ?? false {
            return selectedOption?.id
        }
        
        return text
    }
    
    var addressComponent: AddressComponent? {
        didSet {
            setupOptions()
        }
    }
    
    override var isHidden: Bool {
        didSet {
            if required {
                super.isHidden = isHidden
            } else {
                super.isHidden = true
            }
        }
    }
    
    private func setupOptions() {
        if addressComponent == nil {
            required = false
            self.rightView?.isHidden = true
            self.text = ""
            return
        }
        
        required = true
        let hasOptions = (addressComponent?.hasOptions ?? false)
        placeholder = addressComponent?.name
        self.rightView?.isHidden = !hasOptions
        selectedOption = addressComponent?.options?.first
        
        if selectedOption == nil {
            inputValid = false
            setErrorState(true)
        } else {
            self.validateInput()
        }
    }
    
    private func showOptionsView() {
        guard let options = addressComponent?.options else {
            return
        }
        
        let optionsVC = OptionsViewController()
        optionsVC.options = options
        optionsVC.title = "Select \(addressComponent?.name ?? "")"
        optionsVC.modalPresentationStyle = .formSheet
        optionsVC.isModalInPresentation = false
        optionsVC.didSelectOption = { selectedOption in
            self.selectedOption = selectedOption
            self.validateInput()
            print("Selected option: \(selectedOption.name)")
        }
        
        if let topController = UIApplication.topViewController() {
               topController.present(optionsVC, animated: true, completion: nil)
        }
    }
    
    // Customizing the text field's appearance
    override func setupTextField() {
        super.setupTextField()
        self.delegate = self
        self.isUserInteractionEnabled = true
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard addressComponent?.hasOptions ?? false else {
            return true
        }
        
        showOptionsView()
        return false
    }

}
