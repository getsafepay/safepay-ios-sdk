import UIKit
import Foundation

extension UIImage {
    static func fromPod(named imageName: String) -> UIImage? {
        let podBundle = Bundle(for: PaymentSheetController.self)
        if let resourceBundleURL = podBundle.url(forResource: "SafepayiOSSDK", withExtension: "bundle") {
            if let resourceBundle = Bundle(url: resourceBundleURL) {
                return UIImage(named: imageName, in: resourceBundle, compatibleWith: nil)
            }
        } else {
            print("Resource bundle not found")
        }

        return nil
    }
}
