package com.example.pishkhan_mobile

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pishkhan/external_links")
            .setMethodCallHandler { call, result ->
                if (call.method != "openRegistry") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://amlak.mrud.ir")))
                    result.success(null)
                } catch (_: ActivityNotFoundException) {
                    result.error("browser-unavailable", null, null)
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pishkhan/platform_share")
            .setMethodCallHandler { call, result ->
                if (call.method != "shareText") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val text = call.arguments as? String
                if (text == null) {
                    result.error("invalid-arguments", null, null)
                    return@setMethodCallHandler
                }
                try {
                    val intent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, text)
                    }
                    startActivity(Intent.createChooser(intent, null))
                    result.success(null)
                } catch (_: ActivityNotFoundException) {
                    result.error("share-unavailable", null, null)
                }
            }
    }
}
