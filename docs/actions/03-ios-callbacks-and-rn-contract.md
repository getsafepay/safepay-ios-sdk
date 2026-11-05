# 03 iOS Callbacks And RN Contract

Status: partially implemented in the iOS SDK.

## What the SDK exposes now
The iOS SDK now exposes a stable imperative surface through `SafepayCardCaptureController`:
- `validate`
- `fetchValidity`
- `clear`
- `focus`
- `blur`
- `submit`

`submit()` returns a native `SafepayCardCaptureResult` that is shaped for the RN bridge to convert into:
- `onValidated`
- `onError`
- `onProceedToAuthentication`

The iOS SDK also exposes `ErrorResponse.code`, `ErrorResponse.message`, and `ErrorResponse.errorMessage` publicly now, so the RN bridge can forward backend setup failures without collapsing everything into a generic localized error.

## What is still left for the RN bridge
The RN bridge still needs to:
- hold a controller instance per mounted native card-capture view
- translate native `submit()` results into React Native events
- expose the same command surface on the JS component

## Scope boundary that stayed the same
This iOS work still stops at payer-auth setup. It does not run DDC, present Cardinal UI, or finalize authorization.
