package com.example.pishkhan_mobile

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import android.app.Activity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var documentResult: MethodChannel.Result? = null
    private val documentRequestCode = 8241

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != documentRequestCode) return
        val result = documentResult ?: return
        documentResult = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        try {
            var name = "destinations.xls"
            contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) name = cursor.getString(0)
            }
            val bytes = contentResolver.openInputStream(uri)?.use { stream ->
                val output = java.io.ByteArrayOutputStream()
                val buffer = ByteArray(4096)
                var count = stream.read(buffer)
                while (count != -1 && output.size() <= 102400) {
                    output.write(buffer, 0, count)
                    count = stream.read(buffer)
                }
                output.toByteArray() }
            if (bytes == null || bytes.size > 102400) {
                result.error("file-invalid", null, null)
            } else {
                result.success(mapOf("name" to name, "bytes" to bytes))
            }
        } catch (_: Exception) {
            result.error("file-unavailable", null, null)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pishkhan/document_picker")
            .setMethodCallHandler { call, result ->
                if (call.method != "pickSpreadsheet") {
                    result.notImplemented()
                } else if (documentResult != null) {
                    result.error("picker-busy", null, null)
                } else {
                    documentResult = result
                    try {
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "application/vnd.ms-excel"
                        }
                        startActivityForResult(intent, documentRequestCode)
                    } catch (_: ActivityNotFoundException) {
                        documentResult = null
                        result.error("picker-unavailable", null, null)
                    }
                }
            }
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
