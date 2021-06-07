package com.xamelon.flutter_pay

fun decodePaymentNetwork(name: String): String? {
    return when (name) {
        "VISA" -> "VISA"
        "MASTERCARD" -> "MASTERCARD"
        "DISCOVER" -> "DISCOVER"
        "JCB" -> "JCB"
        "AMERICANEXPRESS" -> "AMEX"
        else -> null
    }
}

var availablePaymentNetworks: List<String> = listOf("VISA", "MASTERCARD", "DISCOVER", "JCB", "AMEX")
