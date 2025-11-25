//
//  PayerAuthRepository.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 10/2/24.
//

import Foundation
import CardinalMobile

class PayerAuthRepository {
    let sandbox: Bool
    private var session : CardinalSession?
   
    init(sandbox: Bool) {
        self.sandbox = sandbox
        initCardinalSession()
    }
    
    //Setup can be called in viewDidLoad
    func initCardinalSession() {
        session = CardinalSession()
        let config = CardinalSessionConfiguration()
        config.deploymentEnvironment = sandbox ? .staging : .production
        config.uiType = .both
        
        let yourCustomUi = UiCustomization()
        //Set various customizations here. See "iOS UI Customization" documentation for detail.
        config.uiCustomization = yourCustomUi
        
        config.renderType = [CardinalSessionRenderTypeOTP]
        session?.configure(config)
    }
    
    func setupCardinalSession(jwtString: String, didComplete: @escaping CardinalSessionSetupDidCompleteHandler, didValidate: @escaping CardinalSessionSetupDidValidateHandler) {
        guard let _session = session else{
            return
        }
        
        _session.setup(jwtString: jwtString, completed: didComplete, validated: didValidate)
    }
    
    func continueValidate(_ transactionID: String, payload: String, validationDelegate :CardinalValidationDelegate ) {
        guard let _session = session else{
            return
        }
        
        _session.continueWith(transactionId: transactionID, payload: payload, validationDelegate: validationDelegate)
    }
    
   
    
}
