//
//  CardUtils.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation

// Enum for Card Providers
enum CardProvider {
    case visa, mastercard, amex, rupay, unionpay, unknown
    
    var description: String {
        switch self {
        case .visa:
            return "Visa"
        case .mastercard:
            return "MasterCard"
        case .amex:
            return "Amex"
        case .rupay:
            return "RuPay"
        case .unionpay:
            return "UnionPay"
        case .unknown:
            return "Unknown"
        }
    }
}

class CreditCardUtils {
    
    // Detect card provider based on card number
    static func detectCardProvider(from number: String) -> CardProvider {
        if number.hasPrefix("4") {
            return .visa
        } else if number.hasPrefix("51") || number.hasPrefix("52") || number.hasPrefix("53") || number.hasPrefix("54") || number.hasPrefix("55") {
            return .mastercard
        } else if number.hasPrefix("34") || number.hasPrefix("37") {
            return .amex
        } else if number.hasPrefix("60") || number.hasPrefix("65") || number.hasPrefix("508") { // Example RuPay patterns
            return .rupay
        } else if number.hasPrefix("62") || number.hasPrefix("81") { // UnionPay patterns
            return .unionpay
        } else {
            return .unknown
        }
    }
    
    // Format card number with spaces (4-4-4-4 by default)
    static func formatCardNumber(_ number: String) -> String {
        var formattedNumber = ""
        for (index, character) in number.enumerated() {
            if index % 4 == 0 && index > 0 {
                formattedNumber += " "
            }
            formattedNumber.append(character)
        }
        return formattedNumber
    }
}

class CardValidator {
    
    static func validateCardNumber(for provider: CardProvider, cardNumber: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: "\\s|-", with: "", options: .regularExpression)
        
        switch provider {
        case .visa:
            return isValidForVisa(cleanedCardNumber) && isValidLuhn(cleanedCardNumber)
        case .mastercard:
            return isValidForMasterCard(cleanedCardNumber) && isValidLuhn(cleanedCardNumber)
        case .amex:
            return isValidForAmex(cleanedCardNumber) && isValidLuhn(cleanedCardNumber)
        case .rupay:
            return isValidForRuPay(cleanedCardNumber) && isValidLuhn(cleanedCardNumber)
        case .unionpay:
            return isValidForUnionPay(cleanedCardNumber) // UnionPay does not always use Luhn
        case .unknown:
            return false
        }
    }
    
    // Visa: Starts with 4 and is 13 or 16 digits
    private static func isValidForVisa(_ cardNumber: String) -> Bool {
        let regex = "^4[0-9]{12}(?:[0-9]{3})?$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: cardNumber)
    }
    
    // MasterCard: Starts with 51-55, 2221-2720 and is 16 digits
    private static func isValidForMasterCard(_ cardNumber: String) -> Bool {
        let regex = "^(5[1-5][0-9]{14}|2(2[2-9][0-9]{12}|[3-6][0-9]{13}|7[01][0-9]{12}|720[0-9]{12}))$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: cardNumber)
    }
    
    // Amex: Starts with 34 or 37 and is 15 digits
    private static func isValidForAmex(_ cardNumber: String) -> Bool {
        let regex = "^3[47][0-9]{13}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: cardNumber)
    }
    
    // RuPay: Starts with 60, 65, or 81 and is typically 16 digits
    private static func isValidForRuPay(_ cardNumber: String) -> Bool {
        let regex = "^(60|65|81)[0-9]{14}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: cardNumber)
    }
    
    // UnionPay: Starts with 62 and is 16-19 digits
    private static func isValidForUnionPay(_ cardNumber: String) -> Bool {
        let regex = "^62[0-9]{14,17}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: cardNumber)
    }
    
    // Luhn Algorithm to check if the card number is valid
    static func isValidLuhn(_ cardNumber: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: "\\s|-", with: "", options: .regularExpression)
        var sum = 0
        let reversedDigits = cleanedCardNumber.reversed().map { String($0) }
        
        for (i, digit) in reversedDigits.enumerated() {
            guard let digitValue = Int(digit) else { return false }
            
            if i % 2 == 1 {
                // Double every second digit
                let doubledValue = digitValue * 2
                sum += doubledValue > 9 ? doubledValue - 9 : doubledValue
            } else {
                sum += digitValue
            }
        }
        return sum % 10 == 0
    }
}

