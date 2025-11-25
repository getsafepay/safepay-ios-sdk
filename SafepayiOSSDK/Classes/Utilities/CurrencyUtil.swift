// CurrencyUtil.swift

import Foundation

struct CurrencyUtil {
    // Mapping of ISO currency codes to their symbols
    private static let currencySymbols: [String: String] = [
        "USD": "$",    // Dollar
        "EUR": "€",    // Euro
        "GBP": "£",    // Pound
        "JPY": "¥",    // Yen
        "INR": "₹",    // Rupee
        "CAD": "$",    // Canadian Dollar
        "AUD": "$",    // Australian Dollar
        "CHF": "CHF",  // Swiss Franc
        "CNY": "¥",    // Yuan
        "KRW": "₩",    // Korean Won
        "PKR": "Rs",   // Pakistani Rupee
        "AED": "AED",  // UAE Dirham
        "SAR": "﷼",    // Saudi Riyal
        "KWD": "KD"    // Kuwaiti Dinar
    ]
    
    // Minor to major unit conversion factor with ISO currency codes as keys
    private static let minorToMajorFactors: [String: Int] = [
        "USD": 100,    // Dollar
        "EUR": 100,    // Euro
        "GBP": 100,    // Pound
        "JPY": 1,      // Yen (No minor units)
        "INR": 100,    // Rupee
        "CAD": 100,    // Canadian Dollar
        "AUD": 100,    // Australian Dollar
        "CHF": 100,    // Swiss Franc
        "CNY": 100,    // Yuan
        "KRW": 1,      // Korean Won (No minor units)
        "PKR": 100,    // Pakistani Rupee
        "AED": 100,    // UAE Dirham
        "SAR": 100,    // Saudi Riyal
        "KWD": 1000    // Kuwaiti Dinar (divided into 1000 fils)
    ]
    
    // Function to get the currency symbol using ISO code
    static func symbolFor(currencyCode: String) -> String? {
        return currencySymbols[currencyCode]
    }

    // Utility to convert minor to major denomination
    static func convertMinorToMajor(currencyCode: String, minorAmount: Int) -> String? {
        guard let factor = minorToMajorFactors[currencyCode] else {
            return nil
        }
        
        let majorAmount = Double(minorAmount) / Double(factor)
        let decimalPlaces = factor == 1 ? 0 : Int(log10(Double(factor)))
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        
        return formatter.string(from: NSNumber(value: majorAmount))
    }
}

//// Usage Example
//    // Converting 150,000 minor units (cents) of Dollars to major
//    if let majorDollarAmount = CurrencyUtil.convertMinorToMajor(currencyCode: "USD", minorAmount: 150000) {
//        print("150,000 cents in Dollar is \(majorDollarAmount)")  // Output: 1500.0
//    }
//
//    // Converting 150,000 minor units (paise) of Pakistani Rupee to major
//    if let majorRupeeAmount = CurrencyUtil.convertMinorToMajor(currencyCode: "PKR", minorAmount: 150000) {
//        print("150,000 paise in Pakistani Rupee is \(majorRupeeAmount)")  // Output: 1500.0
//    }
//
//    // Converting 150,000 minor units (fils) of Kuwaiti Dinar to major
//    if let majorDinarAmount = CurrencyUtil.convertMinorToMajor(currencyCode: "KWD", minorAmount: 150000) {
//        print("150,000 fils in Kuwaiti Dinar is \(majorDinarAmount)")  // Output: 150.0
//    }

