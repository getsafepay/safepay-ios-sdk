import Foundation

struct Validator {

     static func validateCard(card: Card) -> Bool {
        var cardErrors = [String: String]()
         
        if card.firstName.isEmpty {
             cardErrors["firstName"] = "First name is required"
        }
         
        if card.lastName.isEmpty {
             cardErrors["lastName"] = "Last name is required"
        }

        if !isValidCardNumber(card.cardNumber) {
            cardErrors["cardNumber"] = "Invalid card number"
        }
        if !isValidExpiryDate(month: card.expiryMonth, year: card.expiryYear) {
            cardErrors["expiry"] = "Invalid expiry date"
        }
        if !isValidCVC(card.cvc) {
            cardErrors["cvc"] = "Invalid CVC"
        }

        return cardErrors.isEmpty
    }

    static func validateBillingInfo(billing: BillingInfo) -> Bool {
        var billingErrors = [String: String]()
        
        if billing.country.isEmpty {
            billingErrors["country"] = "Country is required"
        }
        if billing.city.isEmpty {
            billingErrors["city"] = "City is required"
        }
        if billing.street1.isEmpty {
            billingErrors["address"] = "Address is required"
        }

        return billingErrors.isEmpty
    }

    // Helper validation methods
    static func isValidCardNumber(_ number: String) -> Bool {
        // Implement card number validation logic
        return number.count >= 13 && number.count <= 19
    }

    static func isValidExpiryDate(month: String, year: String) -> Bool {
        // Implement expiry date validation logic
        return true // Placeholder
    }

    static func isValidCVC(_ cvc: String) -> Bool {
        // Implement CVC validation logic
        return cvc.count >= 3 && cvc.count <= 4
    }
}

struct EmailValidator: InputValidator {
    func validate(input: String) -> Bool {
        return EmailValidator.validate(input)
    }
    
    static func validate(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct NameValidator: InputValidator {
    func validate(input: String) -> Bool {
        return NameValidator.validate(input)
    }

    static func validate(_ name: String) -> Bool {
        let nameRegEx = "^[A-Za-z\\s]{2,}$"
        let namePred = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        return namePred.evaluate(with: name)
    }
}

struct CityValidator: InputValidator {
    func validate(input: String) -> Bool {
        return CityValidator.validate(input)
    }

    static func validate(_ city: String) -> Bool {
        let cityRegEx = "^[A-Za-z\\s]{2,}$"
        let cityPred = NSPredicate(format: "SELF MATCHES %@", cityRegEx)
        return cityPred.evaluate(with: city)
    }
}

struct PasswordValidator: InputValidator {
    func validate(input: String) -> Bool {
        return PasswordValidator.validate(input)
    }

    static func validate(_ password: String) -> Bool {
        return password.count >= 8 && password.count <= 44
    }
}


struct StreetAddressValidator: InputValidator {
    func validate(input: String) -> Bool {
        return StreetAddressValidator.validate(input)
    }

    static func validate(_ address: String) -> Bool {
        let addressRegEx = "^[A-Za-z0-9\\s,.#-]{5,}$"
        let addressPred = NSPredicate(format: "SELF MATCHES %@", addressRegEx)
        return addressPred.evaluate(with: address)
    }
}

struct CVCValidator: InputValidator {
    func validate(input: String) -> Bool {
        return CVCValidator.validate(input)
    }

    static func validate(_ cvc: String) -> Bool {
        let regex = "^[0-9]{\(3)}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: cvc)
    }
}
