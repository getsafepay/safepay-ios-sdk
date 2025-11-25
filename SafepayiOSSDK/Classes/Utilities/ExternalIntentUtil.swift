//
//  ExternalIntentUtil.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 12/30/24.
//

import Foundation
import UIKit

class ExternalIntentUtility {
    
    /// Opens a URL in Safari if it is valid.
    /// - Parameter urlString: The string representation of the URL.
    static func openLinkInSafari(_ urlString: String) {
        // Check if the URL string can be converted to a valid URL.
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        
        // Check if the application can open the URL.
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("Successfully opened URL: \(urlString)")
                } else {
                    print("Failed to open URL: \(urlString)")
                }
            }
        } else {
            print("Cannot open URL: \(urlString)")
        }
    }
}
