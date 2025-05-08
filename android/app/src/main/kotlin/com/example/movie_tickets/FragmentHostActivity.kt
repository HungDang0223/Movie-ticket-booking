package com.example.movie_tickets

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import vn.zalopay.sdk.Environment
import vn.zalopay.sdk.ZaloPayError
import vn.zalopay.sdk.ZaloPaySDK
import vn.zalopay.sdk.listeners.PayOrderListener

class FragmentHostActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ZaloPaySDK.init(2554, Environment.SANDBOX); // Merchant AppID
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("newIntent", intent.toString())
        ZaloPaySDK.getInstance().onResult(intent)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    val channelPayOrder = "flutter.native/channelPayOrder"
    
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelPayOrder)
        .setMethodCallHandler { call, result ->
            when (call.method) {
                "startFragmentHostActivity" -> {
                    val intent = Intent(this, FragmentHostActivity::class.java)
                    startActivity(intent)
                    result.success("Activity Started")
                }
                "payOrder" -> {
                    val tagSuccess = "[OnPaymentSucceeded]"
                    val tagError = "[onPaymentError]"
                    val tagCanel = "[onPaymentCancel]"
                    val token = call.argument<String>("zptoken")

                    if (token != null) {
                        ZaloPaySDK.getInstance().payOrder(
                            this@FragmentHostActivity, token, "demozpdk://app",
                            object : PayOrderListener {
                                override fun onPaymentCanceled(zpTransToken: String?, appTransID: String?) {
                                    Log.d(tagCanel, "[TransactionId]: $zpTransToken, [appTransID]: $appTransID")
                                    result.success("User Canceled")
                                }

                                override fun onPaymentError(zaloPayErrorCode: ZaloPayError?, zpTransToken: String?, appTransID: String?) {
                                    Log.d(tagError, "[zaloPayErrorCode]: $zaloPayErrorCode, [zpTransToken]: $zpTransToken, [appTransID]: $appTransID")
                                    result.success("Payment failed")
                                }

                                override fun onPaymentSucceeded(transactionId: String, transToken: String, appTransID: String?) {
                                    Log.d(tagSuccess, "[TransactionId]: $transactionId, [TransToken]: $transToken, [appTransID]: $appTransID")
                                    result.success("Payment Success")
                                }
                            }
                        )
                    } else {
                        result.error("INVALID_ARGUMENT", "Missing zptoken", null)
                    }
                }
                else -> {
                    Log.d("[METHOD CALLER]", "Method Not Implemented")
                    result.notImplemented()
                }
            }
        }
}

}
