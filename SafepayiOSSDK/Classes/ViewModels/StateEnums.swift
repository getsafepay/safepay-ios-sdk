//
//  StateEnums.swift
//  SafepayiOSSDK

import Foundation


enum FetchPaymentState {
    case error(PaymentError) // error from BE
    case found(FetchPaymentResponse) //not found on BE
    case inProgress
    case inValidState //tracker state is not initial
    case missingRequestParameters
}


enum UserExistState {
    case initial
    case error(PaymentError) // error from BE
    case userExist
    case userDoesNotExist
    case loading
}



enum GetAddressMetaState {
    case initial
    case error(PaymentError)
    case success(AddressMeta)
    case inProgress
}

enum FindAddressState {
    case initial
    case error(PaymentError)
    case success(Address)
    case inProgress
}

enum ShopperLoginState: Equatable {
    case initial
    case error(PaymentError) // error from BE
    case noPaymentMethod //not found on BE
    case inProgress
    case paymentMethodsFound([PaymentMethod])
    case addNewPaymentMethod([PaymentMethod])
    
    // Implement Equatable conformance by overriding the == operator
    static func == (lhs: ShopperLoginState, rhs: ShopperLoginState) -> Bool {
       switch (lhs, rhs) {
       case (.inProgress, .inProgress), (.noPaymentMethod, .noPaymentMethod), (.initial, .initial), (.error, .error), (.paymentMethodsFound, .paymentMethodsFound), (.addNewPaymentMethod, .addNewPaymentMethod):
           return true
       default:
           return false
       }
    }
    
    func isShopperLoggedIn() -> Bool {
        return self == .noPaymentMethod || self == .paymentMethodsFound([]) || self == .addNewPaymentMethod([])
    }
    
    func getPaymentMethods() -> [PaymentMethod]? {
        if case let .addNewPaymentMethod(pm) = self {
            return pm
        }
        
        if case let .paymentMethodsFound(pm) = self {
            return pm
        }
        
        return nil
    }
}


enum PaymentStatus: Equatable {
    
    case initial
    case inProgress
    case cancelled
    case failed(PaymentError) // error from BE
    case success
    
    // Implement Equatable conformance by overriding the == operator
    static func == (lhs: PaymentStatus, rhs: PaymentStatus) -> Bool {
       switch (lhs, rhs) {
       case (.inProgress, .inProgress), (.success, .success), (.initial, .initial), (.cancelled, .cancelled):
           return true
       case let (.failed(reason1), .failed(reason2)):
           return reason1.formattedError() == reason2.formattedError()
       default:
           return false
       }
    }
}
