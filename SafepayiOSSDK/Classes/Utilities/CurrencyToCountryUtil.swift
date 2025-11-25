// CurrencyToCountryUtil.swift

import Foundation

struct CurrencyToCountryUtil {
    // Mapping of currency ISO codes to countries and their ISO 3166-1 alpha-2 country codes
    private static let currencyToCountry: [String: (country: String, code: String)] = [
        "USD": ("United States", "US"),
        "EUR": ("European Union", "EU"),
        "GBP": ("United Kingdom", "GB"),
        "JPY": ("Japan", "JP"),
        "INR": ("India", "IN"),
        "CAD": ("Canada", "CA"),
        "AUD": ("Australia", "AU"),
        "CHF": ("Switzerland", "CH"),
        "CNY": ("China", "CN"),
        "KRW": ("South Korea", "KR"),
        "PKR": ("Pakistan", "PK"),
        "AED": ("United Arab Emirates", "AE"),
        "SAR": ("Saudi Arabia", "SA"),
        "KWD": ("Kuwait", "KW")
    ]
    
    // Function to get the country name and code from the currency ISO code with a default fallback to USA
    static func countryAndCode(currencyCode: String) -> (country: String, code: String) {
        return currencyToCountry[currencyCode] ?? ("United States", "US") // Default to USA
    }
}

// Usage Example
//
//    let dollarCountryInfo = CurrencyToCountryUtil.countryAndCode(currencyCode: "USD")
//    print("Currency: USD -> Country: \(dollarCountryInfo.country), Code: \(dollarCountryInfo.code)")
//    // Output: Country: United States, Code: US
//
//    let pakistaniRupeeCountryInfo = CurrencyToCountryUtil.countryAndCode(currencyCode: "PKR")
//    print("Currency: PKR -> Country: \(pakistaniRupeeCountryInfo.country), Code: \(pakistaniRupeeCountryInfo.code)")
//    // Output: Country: Pakistan, Code: PK
//
//    let unknownCurrencyCountryInfo = CurrencyToCountryUtil.countryAndCode(currencyCode: "XYZ")
//    print("Currency: XYZ -> Country: \(unknownCurrencyCountryInfo.country), Code: \(unknownCurrencyCountryInfo.code)")
