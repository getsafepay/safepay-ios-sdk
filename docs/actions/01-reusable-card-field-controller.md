# 01 Reusable Card Field Controller

Status: implemented.

## What changed
Added a standalone `SafepayCardCaptureController` in `SafepayiOSSDK/Classes/Managers/SafepayCardCaptureController.swift`.

The controller:
- accepts `environment`, `authToken`, and `tracker`
- owns an embeddable `SafepayCardFieldView`
- exposes `validate()`, `fetchValidity()`, `submit()`, `clear()`, `focus()`, and `blur()`
- returns a native `SafepayCardCaptureResult` instead of forcing host code to read raw card data

## Supporting changes
Updated `SafepayiOSSDK/Classes/Views/CommonViews/SafepayCardFieldView.swift` so the SDK can read full card details internally through `currentCardDetails(includeSensitiveData:)` without exposing PAN/CVV through the public change callback by default.

Updated `SafepayiOSSDK/Classes/APIClient/APIClient.swift` so the SDK can construct environment-specific API clients outside the payment-sheet singleton path.

## Architectural outcome
The standalone card-capture flow no longer depends on `SafepayPaymentSheet` or `PaymentSheetController`. Host code can embed the card field directly in any `UIView` hierarchy and drive submission through the controller.
