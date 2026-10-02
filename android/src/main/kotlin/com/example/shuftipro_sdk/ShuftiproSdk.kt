package com.example.shuftipro_sdk

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.sp.shuftipro_sdk.models.Shuftipro
import com.sp.shuftipro_sdk.listener.ShuftiVerifyListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.util.*
import kotlin.collections.HashMap

/** KycPlugin */
class ShuftiproSdk: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var activity: Activity
  private lateinit var applicationContext: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.package_sample/sendAndroid")
    channel.setMethodCallHandler(this)
    applicationContext = flutterPluginBinding.applicationContext

  }
/*
* This method is initiated when a call from bridging class is made
* This function then modifies the data type of received parameters and calls the sdk
* The response received in this method is then forwarded to bridging class
* */
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    if (call.method == "sendRequest") {

      val shuftipro = Shuftipro.getInstance()

      val  authobj= call.argument<HashMap<String, Objects>>("AuthObj")
      val AuthKeys = JSONObject(authobj as Map<String, Any>)

      val  configobj= call.argument<HashMap<String,Objects>>("ConfigObj")
      val ConfigObject = JSONObject(configobj as Map<String, Any>)
	    ConfigObject.put("platform","flutter")
	    ConfigObject.put("flutter_version","1.0.23")

      val obj = call.argument<HashMap<String,Objects>>("RequestObj")
      val gson = Gson()
      val requestObj = JSONObject(gson.toJson(obj).toString())

      var replySent = false
      if (requestObj != null) {
        shuftipro.shuftiproVerification(requestObj, AuthKeys, ConfigObject, activity,
          object : ShuftiVerifyListener {
            override fun verificationStatus(responseSet: Map<String, Any>) {
              if (!replySent) {
                replySent = true
                try {
                  val m2: Map<String, Any> = responseSet
                  result.success(JSONObject(m2).toString())
                } catch (e: Exception) {
                  e.printStackTrace()
                }
              } else {
                // Optional: log ignored second call
                Log.w("ShuftiSDK", "Reply already submitted. Ignoring second response.")
              }
            }
          }
        )
      }
    } else if (call.method == "registerRequest") {

      val clientId = call.argument<String>("clientIdObj")
      val customerID = call.argument<String>("customerIdObj")

      val  configobj= call.argument<HashMap<String,Objects>>("ConfigObj")
      val ConfigObject = JSONObject(configobj as Map<String, Any>)

      if (clientId != null && customerID != null) {
        val configobj = call.argument<HashMap<String, Objects>>("ConfigObj")
        val ConfigObject = JSONObject(configobj as Map<String, Any>)

        val shuftiPro = Shuftipro.getInstance()
        shuftiPro.register(clientId, customerID, ConfigObject, applicationContext, object : ShuftiVerifyListener {
          override fun verificationStatus(responseSet: Map<String, Any>) {
            val m2: Map<String, Any> = responseSet
            result.success(JSONObject(m2).toString())
          }
        })
      } else {
        result.error("NULL_ARGUMENT", "clientId or customerID is null", null)
      }
    }
    else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
   // TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
   // TODO("Not yet implemented")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity;
  }

  override fun onDetachedFromActivityForConfigChanges() {
   // TODO("Not yet implemented")
  }
}
