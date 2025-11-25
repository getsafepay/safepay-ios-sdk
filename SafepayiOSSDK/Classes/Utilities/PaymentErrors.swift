//
//  Errors.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 10/18/24.
//

import Foundation

import Foundation

// Custom Error class
public class PaymentError: Error {
    // Properties
    var code: String?
    var message: String
    
    // Initializer
    init(code: String? = nil, message: String) {
        self.code = code
        self.message = message
    }
    
    // Function to get a formatted error description
    func formattedError() -> String {
        return "Error: \(code ?? "") \(message)"
    }
    
    static func generalPaymentError() -> PaymentError {
        return PaymentError(code: nil, message: "An unexpected error occurred while processing your payment. Please try again or contact support for assistance.")
    }
    
    static func invalidConfiguration() -> PaymentError {
        return PaymentError(code: nil, message: "Looks like required parameters are missing, please check tracker configurations and try again.")
    }
    
    static func timeBasedTokenExpired() -> PaymentError {
        return PaymentError(code: nil, message: "Looks like a required parameters \"Timebased token\" is expired or invalid, please check tracker configurations and try again.")
    }
    
    static func dataMissing() -> PaymentError {
        return PaymentError(code: nil, message: "Some of the required data is missing, Please check and try again.")
    }
    
    
    static func cardError() -> PaymentError {
        return PaymentError(code: nil, message: "There was a problem authenticating your payment. Please use a different card.")
    }
    
    static func invalidTrackerState() -> PaymentError {
        return PaymentError(code: "PT-1001", message: "It appears that your payment tracker has already been started or completed. Please contact support.")
    }
}

