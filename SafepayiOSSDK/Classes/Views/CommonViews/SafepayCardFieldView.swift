import UIKit

public enum SafepayCardFieldFocusField: String {
    case cardNumber = "CardNumber"
    case expiryDate = "ExpiryDate"
    case cvc = "Cvc"
}

public struct SafepayCardFieldDetails {
    public let last4: String?
    public let expiryMonth: Int?
    public let expiryYear: Int?
    public let brand: String?
    public let complete: Bool
    public let validNumber: String
    public let validExpiryDate: String
    public let validCVC: String
    public let number: String?
    public let cvc: String?
}

public final class SafepayCardFieldView: UIView, ValidityUpdateDelegate {
    public var cardChangeHandler: ((SafepayCardFieldDetails) -> Void)?
    public var focusChangeHandler: ((SafepayCardFieldFocusField?) -> Void)?
    public var dangerouslyGetFullCardDetails: Bool = false

    private let cardNumberField = CreditCardTextField()
    private let expiryField = CardExpiryTextField()
    private let cvcField = CVCTextField()

    private let verticalStack = UIStackView()
    private let rowStack = UIStackView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    public func focus() {
        cardNumberField.becomeFirstResponder()
    }

    public func blur() {
        endEditing(true)
    }

    public func clear() {
        cardNumberField.text = nil
        expiryField.text = nil
        cvcField.text = nil
        emitChange()
    }

    public func onValidityChanged(_ textField: UITextField, inputValid: Bool) {
        emitChange()
    }

    private func setupView() {
        cardNumberField.validityDelegate = self
        expiryField.validityDelegate = self
        cvcField.validityDelegate = self

        cardNumberField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        expiryField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        cvcField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        cardNumberField.addTarget(self, action: #selector(fieldDidBegin(_:)), for: .editingDidBegin)
        expiryField.addTarget(self, action: #selector(fieldDidBegin(_:)), for: .editingDidBegin)
        cvcField.addTarget(self, action: #selector(fieldDidBegin(_:)), for: .editingDidBegin)

        cardNumberField.addTarget(self, action: #selector(fieldDidEnd(_:)), for: .editingDidEnd)
        expiryField.addTarget(self, action: #selector(fieldDidEnd(_:)), for: .editingDidEnd)
        cvcField.addTarget(self, action: #selector(fieldDidEnd(_:)), for: .editingDidEnd)

        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.distribution = .fillEqually
        rowStack.addArrangedSubview(expiryField)
        rowStack.addArrangedSubview(cvcField)

        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.addArrangedSubview(cardNumberField)
        verticalStack.addArrangedSubview(rowStack)

        addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @objc private func textDidChange() {
        emitChange()
    }

    @objc private func fieldDidBegin(_ sender: UITextField) {
        if sender === cardNumberField {
            focusChangeHandler?(.cardNumber)
        } else if sender === expiryField {
            focusChangeHandler?(.expiryDate)
        } else if sender === cvcField {
            focusChangeHandler?(.cvc)
        }
    }

    @objc private func fieldDidEnd(_ sender: UITextField) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !(self.cardNumberField.isFirstResponder || self.expiryField.isFirstResponder || self.cvcField.isFirstResponder) {
                self.focusChangeHandler?(nil)
            }
        }
    }

    private func emitChange() {
        cardChangeHandler?(buildDetails(includeSensitiveData: dangerouslyGetFullCardDetails))
    }

    func currentCardDetails(includeSensitiveData: Bool = false) -> SafepayCardFieldDetails {
        buildDetails(includeSensitiveData: includeSensitiveData)
    }

    private func buildDetails(includeSensitiveData: Bool) -> SafepayCardFieldDetails {
        let numberText = cardNumberField.text ?? ""
        let cleanedNumber = numberText.replacingOccurrences(of: " ", with: "")
        let last4 = cleanedNumber.count >= 4 ? String(cleanedNumber.suffix(4)) : nil

        let (month, year) = parseExpiry(expiryField.text)

        let validNumber = validationState(for: cardNumberField, text: numberText)
        let validExpiry = validationState(for: expiryField, text: expiryField.text ?? "")
        let validCvc = validationState(for: cvcField, text: cvcField.text ?? "")

        let complete =
            validNumber == "Valid" &&
            validExpiry == "Valid" &&
            validCvc == "Valid"

        let brand = cardNumberField.cardProvider.description

        let number = includeSensitiveData ? cleanedNumber : nil
        let cvc = includeSensitiveData ? cvcField.text : nil

        return SafepayCardFieldDetails(
            last4: last4,
            expiryMonth: month,
            expiryYear: year,
            brand: brand,
            complete: complete,
            validNumber: validNumber,
            validExpiryDate: validExpiry,
            validCVC: validCvc,
            number: number,
            cvc: cvc
        )
    }

    private func validationState(for field: CustomTextField, text: String) -> String {
        if text.isEmpty {
            return "Incomplete"
        }
        return field.inputValid ? "Valid" : "Invalid"
    }

    private func parseExpiry(_ text: String?) -> (Int?, Int?) {
        guard let text = text, !text.isEmpty else { return (nil, nil) }
        let parts = text.split(separator: "/")
        guard parts.count == 2 else { return (nil, nil) }
        let month = Int(parts[0])
        var year = Int(parts[1])
        if let yearValue = year, yearValue < 100 {
            let currentYear = Calendar.current.component(.year, from: Date())
            let currentCentury = (currentYear / 100) * 100
            let currentTwoDigit = currentYear % 100
            year = yearValue < currentTwoDigit ? currentCentury + 100 + yearValue : currentCentury + yearValue
        }
        return (month, year)
    }
}
