//
//  Debouncer.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 10/7/24.
//

import Foundation

class Debouncer {
    private var timer: Timer?
    private let delay: TimeInterval

    // Initialization with delay time
    init(delay: TimeInterval = 0.7) {
        self.delay = delay
    }

    // Call this method with the closure to debounce
    func call(_ action: @escaping () -> Void) {
        // Invalidate the previous timer (if any)
        timer?.invalidate()

        // Start a new timer with the specified delay
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            action()
        }
    }
}
