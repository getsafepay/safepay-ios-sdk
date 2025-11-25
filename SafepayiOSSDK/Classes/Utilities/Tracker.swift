import Foundation

// Enum to represent different states of the payment tracker
enum PaymentTrackerState: String {
    case trackerStarted = "TRACKER_STARTED"
    case trackerEnded = "TRACKER_ENDED"
    case trackerFailed = "TRACKER_FAILED"
    case trackerAuthorized = "TRACKER_AUTHORIZED"
    case trackerEnrolled = "TRACKER_ENROLLED"
    case trackerUnknown = "TRACKER_UNKNOWN"

    // Add more states as needed
}

// Class to manage the payment tracker state
class PaymentTracker {
    // Property to hold the current state
    private(set) var currentState: PaymentTrackerState
    let token: String
    
    // Initializer
    init(initialState: PaymentTrackerState, token: String) {
        self.currentState = initialState
        self.token = token
    }
    
    // Function to transition to a new state
    func transition(to newState: PaymentTrackerState) {
        // Here you can add any conditions or validations for state transitions
        self.currentState = newState
        print("Transitioned to state: \(currentState.rawValue)")
        performNextAction()
    }
    
    // Function to get a description of the current state
    func currentStateDescription() -> String {
        return "Current State: \(currentState.rawValue)"
    }
    
    func isResumableState() -> Bool {
        return currentState == .trackerStarted || currentState == .trackerAuthorized || currentState == .trackerEnrolled
    }
    
    // Function to perform next actions based on the current state
    private func performNextAction() {
        switch currentState {
        case .trackerStarted:
            startPayment()
        case .trackerEnded:
            endPayment()
        case .trackerEnrolled:
            endPayment()
        case .trackerFailed:
            handleFailure()
        case .trackerAuthorized:
            handleAuthorized()
        case .trackerUnknown:
            print("unknown state")
        }
    }
    
    // Example action methods
    private func startPayment() {
        print("Starting payment process...")
        // Add payment processing logic here
    }
    
    private func endPayment() {
        print("Ending payment process...")
        // Add logic to finalize payment here
    }
    
    private func handleAuthorized() {
        print("Handling payment failure...")
        // Add failure recovery logic here
    }
    
    private func handleFailure() {
        print("Handling payment failure...")
        // Add failure recovery logic here
    }
    
    private func handlePending() {
        print("Payment is pending...")
        // Add logic for pending state handling here
    }
}

// Example usage
//let paymentTracker = PaymentTracker(initialState: .trackerStarted)
//print(paymentTracker.currentStateDescription()) // Current State: TRACKER_STARTED
//
//paymentTracker.transition(to: .trackerEnded) // Transitioned to state: TRACKER_ENDED
//print(paymentTracker.currentStateDescription()) // Current State: TRACKER_ENDED
//
//paymentTracker.transition(to: .trackerFailed) // Transitioned to state: TRACKER_FAILED
//print(paymentTracker.currentStateDescription()) // Current State: TRACKER_FAILED
