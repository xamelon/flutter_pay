import Flutter
import UIKit
import PassKit

enum Method : String {
    case canMakePayment = "canMakePayment"
    case requestPayment = "requestPayment"
}

@available(iOS 10.0, *)
public class SwiftFlutterPayPlugin: NSObject, FlutterPlugin {
    
    let paymentAuthorizationController = PKPaymentAuthorizationController()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_pay", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterPayPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let method = Method(rawValue: call.method) else {
        return
    }
    
    switch method {
    case .canMakePayment:
        canMakePayment(result: result)
        break;
    case .requestPayment:
        requestPayment(arguments: call.arguments, result: result)
        break;
    }
  }
    
    func canMakePayment(arguments: Any? = nil, result: @escaping FlutterResult) {
        let canMakePayment = PKPaymentAuthorizationController.canMakePayments()
        result(canMakePayment)
    }
    
    func requestPayment(arguments: Any? = nil, result: @escaping FlutterResult) {
        guard let params = arguments as? [String: Any],
                let merchantID = params["merchantIdentifier"] as? String,
                let currency = params["currency"] as? String,
                let countryCode = params["countryCode"] as? String,
                let items = params["items"] as? [[String: String]] else {
            return;
        }
        
        var paymentItems = [PKPaymentSummaryItem]()
        items.forEach { item in
            let itemTitle = item["name"]
            let itemPrice = item["price"]
            let itemDecimalPrice = NSDecimalNumber(string: itemPrice)
            let item = PKPaymentSummaryItem(label: itemTitle ?? "", amount: itemDecimalPrice)
            paymentItems.append(item)
        }
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentItems
        paymentRequest.merchantIdentifier = merchantID
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = countryCode
        paymentRequest.currencyCode = currency
        
        let paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController.present(completion: nil)
    }
}
