package com.xamelon.flutter_pay

fun decodePaymentNetwork(name: String): String? {
    when(name) {
        "VISA" -> return "VISA"
        "MASTERCARD" -> return "MASTERCARD"
        "DISCOVER" -> return "DISCOVER"
        "JCB" -> return "JCB"
        "AMEX" -> return "AMEX"
        else -> {
            return null
        }
    }
}

var availablePaymentNetworks: List<String> = listOf("VISA", "MASTERCARD", "DISCOVER", "JCB", "AMEX")
