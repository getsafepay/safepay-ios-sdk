import Foundation

struct BillingInfo: Encodable {
    let street1: String
    let street2: String?
    let city: String
    let state: String?
    let postalCode: String?
    let country: String

    enum CodingKeys: String, CodingKey {
        case street1 = "street_1"
        case street2 = "street_2"
        case city, state
        case postalCode = "postal_code"
        case country
    }
    
    // Helper method to get formatted address
    func getFormattedAddress() -> String {
        return "\(street1), \(city), \(country)"
    }
}
