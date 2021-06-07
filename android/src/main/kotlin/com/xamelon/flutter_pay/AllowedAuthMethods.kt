package com.xamelon.flutter_pay

fun decodeAuthMethods(name: String): String? {
    return when (name) {
        "PAN_ONLY" -> "PAN_ONLY"
        "CRYPTOGRAM_3DS" -> "CRYPTOGRAM_3DS"
        else -> null
    }
}

var availableAuthMethods: List<String> = listOf("PAN_ONLY", "CRYPTOGRAM_3DS")
