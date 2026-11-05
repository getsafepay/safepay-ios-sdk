# SafepayiOSSDK

[![CI Status](https://img.shields.io/travis/Irfan Gul/SafepayiOSSDK.svg?style=flat)](https://travis-ci.org/Irfan Gul/SafepayiOSSDK)
[![Version](https://img.shields.io/cocoapods/v/SafepayiOSSDK.svg?style=flat)](https://cocoapods.org/pods/SafepayiOSSDK)
[![License](https://img.shields.io/cocoapods/l/SafepayiOSSDK.svg?style=flat)](https://cocoapods.org/pods/SafepayiOSSDK)
[![Platform](https://img.shields.io/cocoapods/p/SafepayiOSSDK.svg?style=flat)](https://cocoapods.org/pods/SafepayiOSSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 13.0 or later
- Swift 5

## Installation

Install with [CocoaPods](https://cocoapods.org) from this repository:

```ruby
pod 'SafepayiOSSDK', :git => 'https://github.com/getsafepay/safepay-ios-sdk.git', :branch => 'main'
```

The `SafepayiOSSDK` version on CocoaPods trunk predates card capture.

## Card capture

`SafepayCardCaptureController` provides a native card number, expiry and CVC input (`cardFieldView`) and sends the card to Safepay when you call `submit()`. Card data never leaves the SDK except in that request.

You need a payment tracker and a time-based token (TBT) for it, both created on your server. Use the environment the tracker was created in.

```swift
import SafepayiOSSDK

final class CheckoutViewController: UIViewController {
    private var cardCapture: SafepayCardCaptureController!

    func configure(tracker: String, tbt: String) {
        cardCapture = SafepayCardCaptureController(
            configuration: SafepayCardCaptureConfiguration(
                environment: .sandbox, // .development, .sandbox or .production
                authToken: tbt,
                tracker: tracker
            )
        )

        let cardField = cardCapture.cardFieldView
        cardField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardField)
        NSLayoutConstraint.activate([
            cardField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            cardField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            cardField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cardField.heightAnchor.constraint(equalToConstant: 120),
        ])

        cardField.cardChangeHandler = { details in
            // details.complete, details.brand, details.last4, details.validNumber, ...
        }
    }

    func pay() {
        guard cardCapture.validate() else { return }

        Task {
            do {
                let result = try await cardCapture.submit()
                // result.paymentMethod: the saved card (token, brand, last four, ...)
                // result.accessToken and result.deviceDataCollectionURL: inputs to 3-D Secure
            } catch let error as PaymentError {
                print(error.code ?? "", error.message)
            } catch let error as ErrorResponse {
                print(error.code ?? "", error.errorMessage)
            }
        }
    }
}
```

`SafepayCardCaptureController` also has `fetchValidity()`, `focus()`, `blur()` and `clear()`.

`SafepayCardFieldView` can also be used on its own when you only need the input and its validation state. The card number and CVC are never exposed to your app, which keeps raw card data out of it.

For React Native, use [`@sfpy/react-native`](https://github.com/getsafepay/sfpy-react-native), which wraps this controller.

## Author

Irfan Gul, irfangul92@gmail.com

## License

SafepayiOSSDK is available under the MIT license. See the LICENSE file for more info.
