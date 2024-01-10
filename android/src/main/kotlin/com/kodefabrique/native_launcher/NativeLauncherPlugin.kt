package com.kodefabrique.native_launcher

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** NativeLauncherPlugin */
class NativeLauncherPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "native_launcher")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val arguments = call.arguments as HashMap<*, *>
        if (call.method == "launchAppByDeeplink") {
            val deepLink = arguments["deeplink"] as? String
            val packageName = arguments["packageName"] as? String
            if (deepLink != null) {
                launchAppByDeeplink(deepLink, packageName) { error ->
                    if (error != null) {
                        result.error(
                            "DEEPLINK_ERROR",
                            "Error opening deeplink: ${error.message}",
                            null
                        )
                    } else {
                        result.success("Deeplink opened successfully")
                    }
                }
            } else {
                result.error("INVALID_DEEPLINK", "Invalid deeplink", null)
            }
        } else {
            result.notImplemented()
        }
    }

    private fun launchAppByDeeplink(
        deepLink: String,
        packageName: String?,
        callback: (error: Exception?) -> Unit
    ) {
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(deepLink))
            val packages = context.packageManager.queryIntentActivities(intent, 0)
                .let { activities ->
                    if (!packageName.isNullOrBlank()) {
                        activities.filter { it.activityInfo.packageName.contains(packageName) }
                    } else {
                        activities
                    }
                }
                .map {
                    Intent(
                        intent.action, intent.data
                    ).setPackage(it.activityInfo.packageName)
                }
            if (packages.isNotEmpty()) {
                val chooserIntent = Intent.createChooser(packages[0], "Open by deeplink")

                if (packages.size > 1) {
                    val newList = packages.subList(1, packages.size).toTypedArray()
                    chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, newList)
                }
                chooserIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(chooserIntent)
                callback(null)
            } else {
                callback(Exception("No suitable app found"))
            }
        } catch (e: Exception) {
            callback(e)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
