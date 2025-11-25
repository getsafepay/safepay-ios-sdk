import Foundation
import SwiftUI
import Combine

public class SafepayPaymentSheet {
    private var configuration: SafepayConfiguration
    private var cancellables = Set<AnyCancellable>() // To store subscriptions
    
    
    public init(configuration: SafepayConfiguration) {
        self.configuration = configuration
#if DEBUG
        Constants.currentEnvironment = .development
#else
        Constants.currentEnvironment = configuration.sandbox ? .sandbox : .production
#endif
    }
    
    
    public func present(from: UIViewController, completion: @escaping (PaymentResult) -> Void) {
        guard configuration.isValid() else {
            completion(PaymentResult.failed(PaymentError.invalidConfiguration()))
            debugPrint("Error: SafepayPaymentSheet not initialized. Call tracker token is empty first.")
            return
        }
        
        DispatchQueue.main.async {
            let viewModel = PaymentViewModel(payerAuthRepository: PayerAuthRepository(sandbox: self.configuration.sandbox) ,configuration: self.configuration)
            if let controller = PaymentSheetController.initWithNib(viewModel: viewModel) {
                
                controller.modalPresentationStyle = .overCurrentContext
                from.present(controller, animated: true, completion: nil)
                
                viewModel.$paymentStatus
                    .sink { paymentStatus in
                        
                        DispatchQueue.main.async {
                            switch paymentStatus {
                            case .initial, .inProgress:
                                debugPrint("do nothing")
                                break
                            case .failed(let error):
                                debugPrint("show error on sheet and pass it result")
                                completion(.failed(error))
                                break
                            case .cancelled:
                                debugPrint("payment cancelled")
                                completion(.cancelled)
                                break
                            case .success:
                                controller.dismiss(animated: true) {
                                    debugPrint("show success with completion")
                                    completion(.success)
                                    self.showSuccessSheet(from: from)
                                }
                                break
                            }
                        }
                        
                    }.store(in: &self.cancellables)
                
            }
        }
    }
    
    
    func showSuccessSheet(from: UIViewController) {
        guard let success = PaymentSuccessController.initWithNib(), configuration.showSuccessSheet else {
            return
        }
        
        from.present(success, animated: true)
    }
    
}
