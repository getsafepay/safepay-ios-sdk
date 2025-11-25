import Foundation

class Card {
    var firstName: String
    var lastName: String
    var cardNumber: String
    var expiryMonth: String
    var expiryYear: String
    var cvc: String
    
    init(cardNumber: String, expiryMonth: String, expiryYear: String, cvc: String, firstName: String, lastName: String) {
        self.cardNumber = cardNumber
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cvc = cvc
        self.firstName = firstName
        self.lastName = lastName
    }
    
    init(cardNumber: String, expiry: String, cvc: String, firstName: String, lastName: String) {

        self.cardNumber = cardNumber
        self.cvc = cvc
        self.firstName = firstName
        self.lastName = lastName
        (self.expiryMonth, self.expiryYear) = Card.parseExpiry(expiry)
    }
    
    static func parseExpiry(_ expiry: String) -> (String, String) {
        let components = expiry.components(separatedBy: "/")
        guard components.count == 2,
              let month = components.first,
              let year = components.last,
              month.count == 2 else {
            return ("", "")
        }
        
        let monthString = month
        var yearString = year
        
        // Handle both YY and YYYY formats
        if year.count == 2 {
            let currentYear = Calendar.current.component(.year, from: Date())
            let currentCentury = currentYear - (currentYear % 100)
            if let intYear = Int(year), let fullYear = Int("\(currentCentury + intYear)") {
                yearString = String(fullYear)
            } else {
                return ("", "")
            }
        } else if year.count != 4 {
            return ("", "")
        }
        
        return (monthString, yearString)
    }
    
    // Helper method to get full name
    func getFullName() -> String {
        return "\(firstName) \(lastName)"
    }
    
    // Helper method to get expiry as MM/YY
    func getExpiryString() -> String {
        return "\(expiryMonth)/\(expiryYear)"
    }
    
    // Helper method to get masked card number
    func getMaskedCardNumber() -> String {
        guard cardNumber.count >= 4 else { return cardNumber }
        let lastFourDigits = String(cardNumber.suffix(4))
        return "•••• •••• •••• \(lastFourDigits)"
    }
}
