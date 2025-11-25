//
//  SafepayConfiguration.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 11/14/24.
//

import Foundation

public class SafepayConfiguration {
    public let trackerToken: String
    public let sandbox: Bool
    public let timeBasedToken: String
    public let addressToken: String?
    public let showSuccessSheet: Bool
    
    public init(trackerToken: String, sandbox: Bool = false, timeBasedToken: String, showSuccessSheet: Bool = false, addressToken: String? = nil) {
        self.trackerToken = trackerToken
        self.timeBasedToken = timeBasedToken
        self.addressToken = addressToken
        self.sandbox = sandbox
        self.showSuccessSheet = showSuccessSheet
    }
    
    func isValid() -> Bool {
        return !timeBasedToken.isEmpty && !trackerToken.isEmpty
    }
}
