//
//  PaymentResult.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 11/14/24.
//

import Foundation

public enum PaymentResult {
    case success
    case cancelled
    case failed(PaymentError)
}
