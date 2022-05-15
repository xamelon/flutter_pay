package com.xamelon.flutter_pay

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
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

/** FlutterPayPlugin */
class FlutterPayPlugin : FlutterPlugin, MethodCallHandler, PluginRegistry.ActivityResultListener, ActivityAware {

    private lateinit var googlePayClient: PaymentsClient
    private lateinit var activity: Activity
    private var environment = WalletConstants.ENVIRONMENT_PRODUCTION

    private val LOAD_PAYMENT_DATA_REQUEST_CODE = 991

    private var lastResult: Result? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_pay")
        channel.setMethodCallHandler(this)
    }

    private fun createPaymentsClient() {
        val walletOptions = Wallet.WalletOptions.Builder()
                .setEnvironment(environment)
                .setTheme(WalletConstants.THEME_LIGHT)
                .build()
        this.googlePayClient = Wallet.getPaymentsClient(this.activity, walletOptions)
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_pay")
            val plugin = FlutterPayPlugin()
            channel.setMethodCallHandler(plugin)
            registrar.addActivityResultListener(plugin)
            plugin.activity = registrar.activity()!!
            plugin.createPaymentsClient()
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        this.lastResult = result

        val args = call.arguments as? Map<String, Any>
        val method = call.method as String
        if (args !is Map<String, Any> && (method == "canMakePaymentsWithActiveCard" || method == "requestPayment" || method == "switchEnvironment" )) {
            this.lastResult?.error("invalidParameters", "Invalid parameters", "Invalid parameters")
            return
        } 

        when (method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "canMakePayments" -> canMakePayments(result)
            "canMakePaymentsWithActiveCard" -> canMakePaymentsWithActiveCard(call.arguments as Map<String, Any>, result)
            "requestPayment" -> requestPayment(call.arguments as Map<String, Any>)
            "switchEnvironment" -> switchEnvironment(call.arguments as Map<String, Any>, result)
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun switchEnvironment(args: Map<String, Any>, result: Result) {
        val isTestEnvironment = args["isTestEnvironment"] as? Boolean
        if (isTestEnvironment != null) {
            environment = if (isTestEnvironment) {
                WalletConstants.ENVIRONMENT_TEST
            } else {
                WalletConstants.ENVIRONMENT_PRODUCTION
            }
            print("Is test Environment: $isTestEnvironment\n")
            createPaymentsClient()
        }
        result.success(true)
    }

    private fun getBaseRequest(): JSONObject {
        return JSONObject()
                .put("apiVersion", 2)
                .put("apiVersionMinor", 0)
    }

    private fun getGatewayJsonTokenizationType(gatewayName: String, gatewayMerchantID: String): JSONObject {
        return JSONObject().put("type", "PAYMENT_GATEWAY")
                .put("parameters", JSONObject()
                        .put("gateway", gatewayName)
                        .put("gatewayMerchantId", gatewayMerchantID))
    }

    private fun getAllowedCardSystems(): JSONArray {
        return JSONArray()
                .put("MASTERCARD")
                .put("VISA")
                .put("AMEX")
                .put("DISCOVER")
                .put("INTERAC")
                .put("JCB")
    }

    private fun getAllowedCardAuthMethods(): JSONArray {
        return JSONArray()
                .put("PAN_ONLY")
                .put("CRYPTOGRAM_3DS")
    }

    private fun getBaseCardPaymentMethod(allowedPaymentNetworks: List<String>? = null, allowedAuthMethods: List<String>? = null): JSONObject {
        val cardPaymentMethod = JSONObject().put("type", "CARD")

        val cardNetworks: JSONArray = if (allowedPaymentNetworks == null) {
            getAllowedCardSystems()
        } else {
            JSONArray(allowedPaymentNetworks)
        }

        val authMethods: JSONArray = if (allowedAuthMethods == null) {
            getAllowedCardAuthMethods()
        } else {
            JSONArray(allowedAuthMethods)
        }

        print("getBaseCardPaymentMethod, authMethods: ${authMethods}\n")

        val params = JSONObject()
                .put("allowedAuthMethods", authMethods)
                .put("allowedCardNetworks", cardNetworks)

        cardPaymentMethod.put("parameters", params)
        return cardPaymentMethod
    }

    private fun getCardPaymentMethod(gatewayName: String, gatewayMerchantID: String, allowedPaymentNetworks: List<String>? = null, allowedAuthMethods: List<String>? = null): JSONObject {
        val cardPaymentMethod = getBaseCardPaymentMethod(allowedPaymentNetworks, allowedAuthMethods)
        val tokenizationOptions = getGatewayJsonTokenizationType(gatewayName, gatewayMerchantID)
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
        val items = args["items"] as? List<Map<String, String>>
        val allowedPaymentNetworks = args["allowedPaymentNetworks"] as List<String>
        val allowedAuthMethods = args["allowedAuthMethods"] as List<String>
        val currencyCode = args["currencyCode"] as? String
        val countryCode = args["countryCode"] as? String
        val emailRequired = args["emailRequired"] as? Boolean
        val gatewayName = args["gatewayName"] as? String
        val gatewayMerchantID = args["gatewayMerchantId"] as? String
        val merchantId = args["merchantId"] as? String
        val merchantName = args["merchantName"] as? String

        var totalPrice = 0.0
        items?.forEach {
            val price = it["price"]?.toDouble()
            if (price != null) {
                totalPrice += price
            }
        }

        val paymentNetworks: List<String> = if (allowedPaymentNetworks.count() > 0) {
            allowedPaymentNetworks.mapNotNull { decodePaymentNetwork(it) }
        } else {
            availablePaymentNetworks
        }

        val authMethods: List<String> = if (allowedAuthMethods.count() > 0) {
            allowedAuthMethods.mapNotNull { decodeAuthMethods(it) }
        } else {
            availableAuthMethods
        }
        print("requestPayment, authMethods: ${authMethods}\n")

        if (totalPrice <= 0.0) {
            this.lastResult?.error("zeroPrice", "Invalid price", "Total price cannot be zero or less than zero")
            return
        }
        if (gatewayName == null || gatewayMerchantID == null || currencyCode == null || countryCode == null) {
            this.lastResult?.error("invalidParameters", "Invalid parameters", "Invalid parameters")
            return
        }

        var merchantInfo = JSONObject()
                .putOpt("merchantName", merchantName)
                .putOpt("merchantId", merchantId)

        if (merchantInfo.length() == 0) merchantInfo = null

        val paymentRequestJson = getBaseRequest()
                .putOpt("merchantInfo", merchantInfo)
                .put("emailRequired", emailRequired)
                .put("transactionInfo", getTransactionInfo(totalPrice, currencyCode, countryCode))
                .put("allowedPaymentMethods", JSONArray().put(getCardPaymentMethod(gatewayName, gatewayMerchantID, paymentNetworks, authMethods)))

        val paymentDataRequest = PaymentDataRequest.fromJson(paymentRequestJson.toString(4))

        print("phone required: ${paymentDataRequest.isPhoneNumberRequired}\n")
        print("Payment data request: ${paymentDataRequest.toJson()}\n")

        if (paymentDataRequest != null) {
            val task = googlePayClient
                    .loadPaymentData(paymentDataRequest)
                    .addOnCompleteListener {
                        try {
                            print("${it.getResult(ApiException::class.java)}")
                        } catch (e: ApiException) {

                            print("Tortik:  ${e.message}\n")
                        }
                    }
            AutoResolveHelper.resolveTask(task, this.activity, LOAD_PAYMENT_DATA_REQUEST_CODE)
        }

    }

    private fun canMakePayments(result: Result) {
        val baseRequest = getBaseRequest()
        baseRequest.put("allowedPaymentMethods", JSONArray().put(getBaseCardPaymentMethod()))

        val isReadyToPayRequest = IsReadyToPayRequest.fromJson(baseRequest.toString(4))

        val task = googlePayClient.isReadyToPay(isReadyToPayRequest)
        task.addOnCompleteListener {
            try {
                if (it.getResult(ApiException::class.java) == true) {
                    result.success(true)
                } else {
                    result.success(false)
                }
            } catch (e: ApiException) {
                e.printStackTrace()
                result.success(false)
            }
        }
    }

    private fun canMakePaymentsWithActiveCard(args: Map<String, Any>, result: Result) {
        val rawPaymentNetworks = args["paymentNetworks"] as? List<String>
        var paymentNetworks = rawPaymentNetworks?.mapNotNull { decodePaymentNetwork(it) }
        if (paymentNetworks?.count() == 0) {
            paymentNetworks = availablePaymentNetworks
        }
        val baseRequest = getBaseRequest()
        baseRequest.put("allowedPaymentMethods", JSONArray().put(getBaseCardPaymentMethod(paymentNetworks)))
        baseRequest.put("existingPaymentMethodRequired", true)

        val isReadyToPayRequest = IsReadyToPayRequest.fromJson(baseRequest.toString(4))

        val task = googlePayClient.isReadyToPay(isReadyToPayRequest)
        task.addOnCompleteListener {
            try {
                if (it.getResult(ApiException::class.java) == true) {
                    result.success(true)
                } else {
                    result.success(false)
                }
            } catch (e: ApiException) {
                e.printStackTrace()
                result.success(false)
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == LOAD_PAYMENT_DATA_REQUEST_CODE) {
            print("Result code: $resultCode\n")
            if (resultCode == Activity.RESULT_OK) {
                if (data != null) {
                    val paymentData = PaymentData.getFromIntent(data)
                    print("Payment data: ${paymentData?.toJson()}\n")

                    if (paymentData != null) {
                        val paymentDataString = paymentData.toJson()
                        val paymentDataJSONObject = JSONObject(paymentDataString)
                        val paymentMethodData = paymentDataJSONObject["paymentMethodData"] as? JSONObject
                        if (paymentMethodData != null) {
                            val tokenizationData = paymentMethodData["tokenizationData"] as? JSONObject
                            if (tokenizationData != null) {
                                val token = tokenizationData["token"] as? String
                                if (token != null) {
                                    val response: Map<String, String> = mapOf("token" to token)
                                    this.lastResult?.success(response)
                                }
                            }
                        }
                    }
                }

            } else if (resultCode == Activity.RESULT_CANCELED) {
                print("Activity.RESULT_CANCELED")
                this.lastResult?.error("userCancelledError", "User cancelled the payment", null)
            } else if (resultCode == AutoResolveHelper.RESULT_ERROR) {
                val status = AutoResolveHelper.getStatusFromIntent(data);
                print("AutoResolveHelper.RESULT_ERROR")
                print("Status: ${status?.toString()}")
                this.lastResult?.error("paymentError", "Google Pay returned payment error", null)
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

    override fun onDetachedFromActivity() {}

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activity = binding.activity
        binding.addActivityResultListener(this)
        createPaymentsClient()
    }
}
