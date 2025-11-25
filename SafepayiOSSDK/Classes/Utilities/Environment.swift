import Foundation

enum Environment {
    case development
    case sandbox
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://dev.api.getsafepay.com"
        case .sandbox:
            return "https://sandbox.api.getsafepay.com"
        case .production:
            return "https://sandbox.api.getsafepay.com"
        }
    }
}

