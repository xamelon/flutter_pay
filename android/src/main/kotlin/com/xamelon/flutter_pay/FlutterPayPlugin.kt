package com.xamelon.flutter_pay

import android.app.Activity
import android.app.Instrumentation
import android.content.Context
import android.content.Intent
import android.os.Environment
import androidx.annotation.NonNull;
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.wallet.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.json.JSONArray
import org.json.JSONObject
import java.util.*

/** FlutterPayPlugin */
public class FlutterPayPlugin: FlutterPlugin, MethodCallHandler, PluginRegistry.ActivityResultListener, ActivityAware {

  private lateinit  var googlePayClient: PaymentsClient
  private lateinit var activity: Activity

  private final val LOAD_PAYMENT_DATA_REQUEST_CODE = 991

  private var lastResult: Result? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_pay")
    channel.setMethodCallHandler(this)
  }

  private fun createPaymentsClient() {
    val walletOptions = Wallet.WalletOptions.Builder()
            .setEnvironment(WalletConstants.ENVIRONMENT_PRODUCTION)
            .setTheme(WalletConstants.THEME_LIGHT)
            .build()
    this.googlePayClient = Wallet.getPaymentsClient(this.activity, walletOptions)
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_pay")
      var plugin = FlutterPayPlugin()
      channel.setMethodCallHandler(plugin)
      registrar.addActivityResultListener(plugin)
      plugin.activity = registrar.activity()
      plugin.createPaymentsClient()
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    this.lastResult = result
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if(call.method == "canMakePayments") {
      canMakePayments(result)
    } else if(call.method == "requestPayment") {
      val args = call.arguments as? Map<String, Any>
      if(args is Map) {
        requestPayment(args)
      }
    } else {
      result.notImplemented()
    }
  }

  private fun getBaseRequest(): JSONObject {
    return JSONObject()
            .put("apiVersion", 2)
            .put("apiVersionMinor", 0)
  }

  private fun getGatewayJsonTokenizationType(gateway: String, merchantID: String): JSONObject {
    return JSONObject().put("type", "PAYMENT_GATEWAY")
            .put("parameters", JSONObject()
                    .put("gateway", gateway)
                    .put("gatewayMerchantId", merchantID))
  }

  private fun getAllowedCardSystems(): JSONArray {
    return JSONArray()
            .put("MASTERCARD")
            .put("VISA")
  }

  private fun getAllowedCardAuthMethods(): JSONArray {
    return JSONArray()
            .put("CRYPTOGRAM_3DS")
  }

  private fun getBaseCardPaymentMethod(): JSONObject {
    val cardPaymentMethod = JSONObject().put("type","CARD");

    val params = JSONObject()
            .put("allowedAuthMethods", getAllowedCardAuthMethods())
            .put("allowedCardNetworks", getAllowedCardSystems())

    cardPaymentMethod.put("parameters", params)
    return cardPaymentMethod
  }

  private fun getCardPaymentMethod(gateway: String, merchantID: String): JSONObject {
    val cardPaymentMethod = getBaseCardPaymentMethod()
    val tokenizationOptions = getGatewayJsonTokenizationType(gateway, merchantID)
    cardPaymentMethod.put("tokenizationSpecification", tokenizationOptions)
    return cardPaymentMethod
  }

  private fun getTransactionInfo(totalPrice: Double, currencyCode: String, countryCode: String): JSONObject {
    return JSONObject()
            .put("totalPrice", totalPrice.toString())
            .put("totalPriceStatus", "FINAL")
            .put("countryCode", countryCode)
            .put("currencyCode", currencyCode)
  }

  private fun requestPayment(args: Map<String, Any>) {
    var gateway = args["gateway"] as? String
    var merchantID = args["merchantIdentifier"] as? String
    var currencyCode = args["currencyCode"] as? String
    var countryCode = args["countryCode"] as? String
    var merchantName = args["merchantName"] as? String
    var items = args["items"] as? List<Map<String, String>>

    var totalPrice: Double = 0.0
    if(items != null) {
      items.forEach {
        val price = it["price"]?.toDouble()
        if(price != null) {
          totalPrice += price
        }
      }
    }

    if(totalPrice <= 0.0) {
      this.lastResult?.error("com.xammelon.flutterPay.zeroPrice", "Invalid price", "Total price cannot be zero or less than zero")
      return
    }
    if(gateway == null || merchantID == null || currencyCode == null || countryCode == null || merchantName == null) {
      this.lastResult?.error("com.xamelon.flutterPay.invalidParameters", "Invalid parameters", "Invalid parameters")
      return
    }

    var merchantInfo = JSONObject().put("merchantName", merchantName)

    var paymentRequestJson = getBaseRequest()
            .put("merchantInfo", merchantInfo)
            .put("emailRequired", false)
            .put("transactionInfo", getTransactionInfo(totalPrice, currencyCode, countryCode))
            .put("allowedPaymentMethods", JSONArray().put(getCardPaymentMethod(gateway, merchantID)))

    var paymentDataRequest = PaymentDataRequest.fromJson(paymentRequestJson.toString(4))
    var request = PaymentDataRequest.newBuilder()
            .setPhoneNumberRequired(false)
            .setEmailRequired(false)

    var paymentJson = paymentDataRequest.toJson()
    print("phone required: ${paymentDataRequest.isPhoneNumberRequired}\n")
    print("Payment data request: ${paymentDataRequest.toJson()}")

    if(paymentDataRequest != null) {
      var task = googlePayClient
              .loadPaymentData(paymentDataRequest)
              .addOnCompleteListener {
                try {
                  print("${it.getResult(ApiException::class.java)}")
                } catch(e: ApiException) {
                  e.printStackTrace()
                  print(e.statusCode)
                }
              }
      AutoResolveHelper.resolveTask(task, this.activity, LOAD_PAYMENT_DATA_REQUEST_CODE)
    }

  }

  private fun canMakePayments(result: Result) {
    val isReadyToPayRequest = IsReadyToPayRequest.newBuilder()
            .addAllowedPaymentMethod(WalletConstants.PAYMENT_METHOD_CARD)
            .addAllowedPaymentMethod(WalletConstants.PAYMENT_METHOD_TOKENIZATION_TYPE_PAYMENT_GATEWAY)
            .build()
    val task = googlePayClient.isReadyToPay(isReadyToPayRequest)
    task.addOnCompleteListener {
      try {
        if(it.getResult(ApiException::class.java) == true) {
          result.success(true)
        } else {
          result.success(false)
        }
      } catch(e: ApiException) {
        e.printStackTrace()
        result.success(false)
      }
    }
  }

  private fun canMakePaymentsWithActiveCard(result: Result) {
    val isReadyToPayRequest = IsReadyToPayRequest.newBuilder()
            .addAllowedPaymentMethod(WalletConstants.PAYMENT_METHOD_CARD)
            .setExistingPaymentMethodRequired(true)
            .addAllowedPaymentMethod(WalletConstants.PAYMENT_METHOD_TOKENIZATION_TYPE_PAYMENT_GATEWAY)
            .build()
    val task = googlePayClient.isReadyToPay(isReadyToPayRequest)
    task.addOnCompleteListener {
      try {
        if(it.getResult(ApiException::class.java) == true) {
          result.success(true)
        } else {
          result.success(false)
        }
      } catch(e: ApiException) {
        e.printStackTrace()
        result.success(false)
      }
    }
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }


  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if(requestCode == LOAD_PAYMENT_DATA_REQUEST_CODE) {
      if(resultCode == Activity.RESULT_OK) {
        if(data != null) {
          var paymentData = PaymentData.getFromIntent(data)
          print("Payment data: ${paymentData?.toJson()}")

          if(paymentData != null) {
            val paymentDataString = paymentData.toJson()
            val paymentDataJSONObject = JSONObject(paymentDataString)
            val paymentMethodData = paymentDataJSONObject["paymentMethodData"] as? JSONObject
            if(paymentMethodData != null) {
              val tokenizationData = paymentMethodData["tokenizationData"] as? JSONObject
              if (tokenizationData != null) {
                val token = tokenizationData["token"] as? String
                if (token != null) {
                  var response: Map<String, String> = mapOf("token" to token, "error" to "")
                  this.lastResult?.success(response)
                }
              }
            }
          }

        }

      } else if(resultCode == Activity.RESULT_CANCELED) {
        this.lastResult?.error("com.flutter_pay.userCancelledError", "User cancelled the payment", null);
      }
      this.lastResult = null
    }
    return false
  }


  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
    binding.addActivityResultListener(this)
    createPaymentsClient()
  }

  override fun onDetachedFromActivity() {

  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.activity = binding.activity
    binding.addActivityResultListener(this)
    createPaymentsClient()
  }
}
