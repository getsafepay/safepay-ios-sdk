import UIKit

// Custom TextField with error state
class CustomTextField: UITextField, InputValidatable {
    var inputValid = false {
        didSet {
            setErrorState(inputValid)
            validityDelegate?.onValidityChanged(self, inputValid: inputValid)
        }
    }
    
    var validator: InputValidator?
    var validityDelegate: ValidityUpdateDelegate?
    private var isActive: Bool?
    let debouncer = Debouncer()

    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    // Setup text field properties
    func setupTextField() {
        // Set height
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Font and text color
        self.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        self.textColor = UIColor.black
        
        // Corner radius and border color
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1.0
        self.layer.borderColor = Colors.fieldBorder.cgColor // Normal state border color
        self.backgroundColor = Colors.fieldBackgroundColor
        self.textColor = Colors.fieldTextColor
        
        // Set placeholder with custom color and font size
        let placeholderText = "Enter text"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.fieldPlaceholderColor, // Placeholder color
            .font: UIFont.systemFont(ofSize: 15, weight: .regular) // Placeholder font
        ]
        self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)


        // Add padding to the text field
        self.setLeftPaddingPoints(10)
        self.setRightPaddingPoints(10)
        autocorrectionType = .no
    }
    
    // Method to handle error state with red border
    func setErrorState(_ inputValid: Bool) {
        if inputValid {
            self.layer.borderColor = (isActive ?? false) ? Colors.activeFieldBorder.cgColor : Colors.fieldBorder.cgColor // Normal state border color
        } else {
            self.layer.borderColor = Colors.error.cgColor // Red error border color
        }
    }
    
    @objc open func editingChanged() {
        debouncer.call {
            self.validateInput()
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
        self.layer.borderColor = (!inputValid && !(text?.isEmpty ?? true)) ? Colors.error.cgColor : Colors.fieldBorder.cgColor
    }
    
    open func validateInput() {
        guard let text = self.text else {
            return
        }
        
        // Use the injected validator to validate the input
        let isValid = validator?.validate(input: text) ?? false
        self.inputValid = isValid
    }
}

// Extension for adding padding to UITextField
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

protocol InputValidator {
    func validate(input: String) -> Bool
}

protocol ValidityUpdateDelegate {
    func onValidityChanged(_ textField: UITextField, inputValid: Bool)
}

protocol InputValidatable {
    var inputValid: Bool {
        get set
    }
}
