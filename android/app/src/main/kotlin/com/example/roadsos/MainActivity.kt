package com.example.roadsos

import android.Manifest
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Bundle
import android.telephony.SmsManager
import android.util.Log

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "roadsos/sms"

    private val SMS_PERMISSION_REQUEST = 1001

    private var pendingResult: MethodChannel.Result? = null
    private var pendingPhoneNumber: String? = null
    private var pendingMessage: String? = null

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "sendSMS") {

                val phoneNumber =
                    call.argument<String>("phoneNumber")

                val message =
                    call.argument<String>("message")

                if (phoneNumber.isNullOrEmpty() ||
                    message.isNullOrEmpty()
                ) {
                    result.error(
                        "INVALID_ARGUMENT",
                        "Phone number or message is empty",
                        null
                    )
                    return@setMethodCallHandler
                }

                if (checkSelfPermission(
                        Manifest.permission.SEND_SMS
                    ) != PackageManager.PERMISSION_GRANTED
                ) {

                    pendingResult = result
                    pendingPhoneNumber = phoneNumber
                    pendingMessage = message

                    requestPermissions(
                        arrayOf(
                            Manifest.permission.SEND_SMS
                        ),
                        SMS_PERMISSION_REQUEST
                    )

                } else {

                    sendSmsDirectly(
                        phoneNumber,
                        message,
                        result
                    )
                }

            } else {
                result.notImplemented()
            }
        }
    }

    private fun sendSmsDirectly(
    phoneNumber: String,
    message: String,
    result: MethodChannel.Result
) {

    try {

        val subscriptionManager =
            getSystemService(
                android.content.Context.TELEPHONY_SUBSCRIPTION_SERVICE
            ) as android.telephony.SubscriptionManager

        val subscriptions =
            subscriptionManager.activeSubscriptionInfoList

        if (subscriptions.isNullOrEmpty()) {

            Log.e(
                "RoadSOS",
                "❌ No active SIM subscription found"
            )

            result.error(
                "NO_SIM",
                "No active SIM found",
                null
            )

            return
        }

        val subscriptionId =
            subscriptions[0].subscriptionId

        Log.d(
            "RoadSOS",
            "📱 Using subscription ID: $subscriptionId"
        )

        val smsManager =
            SmsManager.getSmsManagerForSubscriptionId(
                subscriptionId
            )

        // IMPORTANT:
        // Split the message into SMS-sized parts.
        val parts =
            smsManager.divideMessage(message)

        Log.d(
            "RoadSOS",
            "📨 SMS parts required: ${parts.size}"
        )

        val sentIntents =
            ArrayList<PendingIntent>()

        val deliveredIntents =
            ArrayList<PendingIntent>()

        for (i in parts.indices) {

            val sentAction =
                "ROADSOS_SMS_SENT_${phoneNumber}_$i"

            val deliveredAction =
                "ROADSOS_SMS_DELIVERED_${phoneNumber}_$i"

            val sentIntent =
                PendingIntent.getBroadcast(
                    this,
                    phoneNumber.hashCode() + i,
                    Intent(sentAction),
                    PendingIntent.FLAG_UPDATE_CURRENT or
                            PendingIntent.FLAG_IMMUTABLE
                )

            val deliveredIntent =
                PendingIntent.getBroadcast(
                    this,
                    phoneNumber.hashCode() + 1000 + i,
                    Intent(deliveredAction),
                    PendingIntent.FLAG_UPDATE_CURRENT or
                            PendingIntent.FLAG_IMMUTABLE
                )

            sentIntents.add(sentIntent)
            deliveredIntents.add(deliveredIntent)

            registerSmsPartReceivers(
                phoneNumber,
                i,
                parts.size
            )
        }

        smsManager.sendMultipartTextMessage(
            phoneNumber,
            null,
            parts,
            sentIntents,
            deliveredIntents
        )

        Log.d(
            "RoadSOS",
            "📤 Multipart SMS submitted to Android for $phoneNumber"
        )

        // Android has accepted the request.
        result.success(true)

    } catch (e: Exception) {

        Log.e(
            "RoadSOS",
            "❌ SMS exception: ${e.message}"
        )

        result.error(
            "SMS_EXCEPTION",
            e.message,
            null
        )
    }
}

private fun registerSmsPartReceivers(
    phoneNumber: String,
    partNumber: Int,
    totalParts: Int
) {

    val sentAction =
        "ROADSOS_SMS_SENT_${phoneNumber}_$partNumber"

    val deliveredAction =
        "ROADSOS_SMS_DELIVERED_${phoneNumber}_$partNumber"


    // SENT receiver
    val sentReceiver =
        object : BroadcastReceiver() {

            override fun onReceive(
                context: Context?,
                intent: Intent?
            ) {

                if (resultCode == RESULT_OK) {

                    Log.d(
                        "RoadSOS",
                        "✅ SMS PART ${partNumber + 1}/$totalParts SENT to $phoneNumber"
                    )

                } else {

                    val errorCode =
                        intent?.getIntExtra(
                            "errorCode",
                            -1
                        )

                    val noDefault =
                        intent?.getBooleanExtra(
                            "noDefault",
                            false
                        )

                    Log.e(
                        "RoadSOS",
                        "❌ SMS PART ${partNumber + 1}/$totalParts FAILED"
                    )

                    Log.e(
                        "RoadSOS",
                        "Result code: $resultCode"
                    )

                    Log.e(
                        "RoadSOS",
                        "Radio error code: $errorCode"
                    )

                    Log.e(
                        "RoadSOS",
                        "No default subscription: $noDefault"
                    )
                }

                try {
                    unregisterReceiver(this)
                } catch (_: Exception) {
                }
            }
        }


    // DELIVERED receiver
    val deliveredReceiver =
        object : BroadcastReceiver() {

            override fun onReceive(
                context: Context?,
                intent: Intent?
            ) {

                if (resultCode == RESULT_OK) {

                    Log.d(
                        "RoadSOS",
                        "📩 SMS PART ${partNumber + 1}/$totalParts DELIVERED to $phoneNumber"
                    )

                } else {

                    Log.e(
                        "RoadSOS",
                        "❌ SMS PART ${partNumber + 1}/$totalParts DELIVERY FAILED"
                    )
                }

                try {
                    unregisterReceiver(this)
                } catch (_: Exception) {
                }
            }
        }


    registerReceiver(
        sentReceiver,
        IntentFilter(sentAction),
        Context.RECEIVER_EXPORTED
    )

    registerReceiver(
        deliveredReceiver,
        IntentFilter(deliveredAction),
        Context.RECEIVER_EXPORTED
    )
}

    private fun registerSmsReceivers(
        phoneNumber: String,
        result: MethodChannel.Result
    ) {

        val sentAction =
            "ROADSOS_SMS_SENT_$phoneNumber"

        val deliveredAction =
            "ROADSOS_SMS_DELIVERED_$phoneNumber"

        val sentReceiver =
            object : BroadcastReceiver() {

                override fun onReceive(
                    context: Context?,
                    intent: Intent?
                ) {

                    val code = resultCode

                    if (code == RESULT_OK) {

                        Log.d(
                            "RoadSOS",
                            "✅ SMS SENT successfully to $phoneNumber"
                        )

                    } else {

                        val errorCode =
                            intent?.getIntExtra(
                                "errorCode",
                                -1
                            )

                        Log.e(
                            "RoadSOS",
                            "❌ SMS SEND FAILED to $phoneNumber"
                        )

                        Log.e(
                            "RoadSOS",
                            "Result code: $code"
                        )

                        Log.e(
                            "RoadSOS",
                            "Radio error code: $errorCode"
                        )
                    }

                    try {
                        unregisterReceiver(this)
                    } catch (_: Exception) {
                    }
                }
            }

        val deliveredReceiver =
            object : BroadcastReceiver() {

                override fun onReceive(
                    context: Context?,
                    intent: Intent?
                ) {

                    val code = resultCode

                    if (code == RESULT_OK) {

                        Log.d(
                            "RoadSOS",
                            "📩 SMS DELIVERED to $phoneNumber"
                        )

                    } else {

                        Log.e(
                            "RoadSOS",
                            "❌ SMS DELIVERY FAILED to $phoneNumber"
                        )

                        Log.e(
                            "RoadSOS",
                            "Delivery result: $code"
                        )
                    }

                    try {
                        unregisterReceiver(this)
                    } catch (_: Exception) {
                    }
                }
            }

        registerReceiver(
            sentReceiver,
            IntentFilter(sentAction),
            Context.RECEIVER_EXPORTED
        )

        registerReceiver(
            deliveredReceiver,
            IntentFilter(deliveredAction),
            Context.RECEIVER_EXPORTED
        )

        // We tell Flutter that Android accepted
        // the SMS request.
        result.success(true)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {

        super.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )

        if (requestCode ==
            SMS_PERMISSION_REQUEST
        ) {

            if (grantResults.isNotEmpty() &&
                grantResults[0] ==
                PackageManager.PERMISSION_GRANTED
            ) {

                val result =
                    pendingResult

                val phone =
                    pendingPhoneNumber

                val message =
                    pendingMessage

                pendingResult = null
                pendingPhoneNumber = null
                pendingMessage = null

                if (result != null &&
                    phone != null &&
                    message != null
                ) {

                    sendSmsDirectly(
                        phone,
                        message,
                        result
                    )
                }

            } else {

                pendingResult?.error(
                    "PERMISSION_DENIED",
                    "SMS permission denied",
                    null
                )

                pendingResult = null
                pendingPhoneNumber = null
                pendingMessage = null
            }
        }
    }
}