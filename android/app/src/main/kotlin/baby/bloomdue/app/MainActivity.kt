package baby.bloomdue.app

import android.content.Intent
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "baby.bloomdue.app/installer",
        ).setMethodCallHandler { call, result ->
            if (call.method == "installApk") {
                val filePath = call.argument<String>("path")
                if (filePath == null) {
                    result.error("NO_PATH", "File path is required", null)
                    return@setMethodCallHandler
                }
                try {
                    val file = File(filePath)
                    if (!file.exists()) {
                        result.error("NO_FILE", "APK file missing: $filePath", null)
                        return@setMethodCallHandler
                    }
                    val uri = FileProvider.getUriForFile(
                        this,
                        "${applicationContext.packageName}.fileprovider",
                        file,
                    )
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        setDataAndType(uri, "application/vnd.android.package-archive")
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    result.success(true)
                    // Avoid a stale process sitting in recents after update.
                    finishAffinity()
                } catch (e: Exception) {
                    result.error("INSTALL_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
