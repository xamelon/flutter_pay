import PassKit

class PaymentNetworkHelper {

    static func decodePaymentNetwork(_ paymentNetwork: String) -> PKPaymentNetwork? {
        switch(paymentNetwork) {
        case "VISA":
            return .visa
        case "MASTERCARD":
            return .masterCard
        case "AMERICANEXPRESS":
            return .amex
        case "INTERAC":
            if #available(iOS 9.2, *) { return .interac }
            return nil
        case "DISCOVER":
            if #available(iOS 9.0, *) { return .discover }
            return nil
        case "JCB":
            if #available(iOS 10.1, *) { return .JCB }
            return nil
        case "MAESTRO":
            if #available(iOS 12.0, *) { return .maestro }
            return nil
        case "ELECTRON":
            if #available(iOS 12.0, *) { return .electron }
            return nil
        case "CARTESBANCARRIES":
            if #available(iOS 10.3, *) { return .carteBancaire }
            else if #available(iOS 11.0, *) { return .carteBancaires }
            else if #available(iOS 11.2, *) { return .cartesBancaires }
            return nil
        case "UNIONPAY":
            if #available(iOS 9.2, *) { return .chinaUnionPay }
            return nil
        case "EFTPOS":
            if #available(iOS 12.0, *) { return .eftpos}
            return nil
        case "ELO":
            if #available(iOS 12.1.1, *) { return .elo }
            return nil
        case "IDCREDIT":
            if #available(iOS 10.3, *) { return .idCredit }
            return nil
        case "MADA":
            if #available(iOS 12.1.1, *) { return .mada }
            return nil
        case "PRIVATELABEL":
            if #available(iOS 9.0, *) { return .privateLabel }
            return nil
        case "QUICPAY":
            if #available(iOS 10.3, *) { return .quicPay }
            return nil
        case "SUICA":
            if #available(iOS 10.1, *) { return .suica }
            return nil
        case "VPAY":
            if #available(iOS 12.0, *) { return .vPay }
            return nil
        default:
            return nil
        }
    }
    
}
