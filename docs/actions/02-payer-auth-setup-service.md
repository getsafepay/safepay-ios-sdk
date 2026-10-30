# 02 Payer Auth Setup Service

Status: implemented for direct setup; tracker preflight/reset not yet implemented.

## What changed
Moved the `PAYER_AUTH_SETUP` request into `SafepayCardCaptureController.submit()`.

`submit()` now:
1. reads full card details from `SafepayCardFieldView` inside the SDK
2. validates completeness before building the payload
3. calls `PaymentRepository.payerAuthenticationSetup(...)` with `entry_mode = raw`
4. maps the backend response into `SafepayCardCaptureResult`

## Result shape
The controller now returns:
- `accessToken`
- `deviceDataCollectionURL`
- `paymentMethod`
- `cardinalJWT`

## Security outcome
PAN/CVV stay inside native code. They are read from the card field only long enough to create the request payload and are not emitted through the public field-change callback.

## Remaining gap
Tracker usability/reset was not implemented in this pass. The SDK did not have a standalone reset path exposed yet, so this controller currently relies on the backend `PAYER_AUTH_SETUP` response to reject invalid tracker state. That follow-up still needs dedicated native API coverage.
