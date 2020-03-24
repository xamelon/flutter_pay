//
//  PaymentNetwork.swift
//  appmetrica_sdk
//
//  Created by Body Block on 24/03/2020.
//

import PassKit

extension PKPaymentNetwork {
    
    static func create(withFlutterPaymentNetwork paymentNetwork: String) -> PKPaymentNetwork? {
        switch paymentNetwork {
        case "Visa":
            return .visa
        case "Mastercard":
            return .masterCard
        default:
            return nil
        }
    }
    
}
