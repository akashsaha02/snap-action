package com.snapaction.snapaction

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.net.wifi.WifiNetworkSuggestion
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.CalendarContract
import android.provider.ContactsContract
import android.provider.OpenableColumns
import android.provider.Settings
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

/**
 * Hosts the `snapaction/platform` channel:
 *  - Incoming ACTION_SEND / ACTION_SEND_MULTIPLE image shares, copied into the
 *    app cache on a background thread so content URIs can be read after the
 *    temporary grant expires.
 *  - Calendar and contact insert intents, which open the system editor and
 *    therefore need no calendar or contacts permission.
 *  - Saving exports and opening backups through the system document picker,
 *    so no storage permission is needed.
 *  - FLAG_SECURE, which hides the app content in recent apps.
 */
class MainActivity : FlutterFragmentActivity() {
    private var channel: MethodChannel? = null
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    /** Shares that arrived before Dart asked for them. */
    private val pendingUris = mutableListOf<Uri>()
    private var dartListening = false

    private var pendingDocument: PendingDocument? = null
    private val documentLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
            onDocumentResult(it.resultCode, it.data)
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // A share intent restored from recents or after process death has
        // already been handled; never import it twice.
        val fromHistory = intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0
        val alreadyHandled = savedInstanceState?.getBoolean(KEY_HANDLED) == true
        if (!fromHistory && !alreadyHandled) {
            pendingUris.addAll(consumeShare(intent))
        } else {
            consumeShare(intent)
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putBoolean(KEY_HANDLED, true)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val uris = consumeShare(intent)
        if (uris.isEmpty()) return
        if (dartListening) {
            copyAsync(uris) { files -> channel?.invokeMethod("onShare", files) }
        } else {
            pendingUris.addAll(uris)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler { call, result -> handle(call, result) }
        }
    }

    override fun onDestroy() {
        channel?.setMethodCallHandler(null)
        io.shutdown()
        super.onDestroy()
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "takePendingShares" -> {
                dartListening = true
                val uris = pendingUris.toList()
                pendingUris.clear()
                copyAsync(uris) { files -> result.success(files) }
            }
            "insertCalendarEvent" -> launch(result) {
                Intent(Intent.ACTION_INSERT).apply {
                    data = CalendarContract.Events.CONTENT_URI
                    putExtra(CalendarContract.Events.TITLE, call.argument<String>("title"))
                    call.argument<String>("description")?.let {
                        putExtra(CalendarContract.Events.DESCRIPTION, it)
                    }
                    call.argument<String>("location")?.let {
                        putExtra(CalendarContract.Events.EVENT_LOCATION, it)
                    }
                    call.argument<Number>("beginMillis")?.let {
                        putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, it.toLong())
                    }
                    call.argument<Number>("endMillis")?.let {
                        putExtra(CalendarContract.EXTRA_EVENT_END_TIME, it.toLong())
                    }
                    putExtra(
                        CalendarContract.EXTRA_EVENT_ALL_DAY,
                        call.argument<Boolean>("allDay") ?: false,
                    )
                }
            }
            "addWifiNetwork" -> addWifiNetwork(call, result)
            "openWifiSettings" -> launch(result) { Intent(Settings.ACTION_WIFI_SETTINGS) }
            "insertContact" -> launch(result) {
                Intent(ContactsContract.Intents.Insert.ACTION).apply {
                    type = ContactsContract.RawContacts.CONTENT_TYPE
                    call.argument<String>("name")?.let {
                        putExtra(ContactsContract.Intents.Insert.NAME, it)
                    }
                    call.argument<String>("phone")?.let {
                        putExtra(ContactsContract.Intents.Insert.PHONE, it)
                    }
                    call.argument<String>("email")?.let {
                        putExtra(ContactsContract.Intents.Insert.EMAIL, it)
                    }
                }
            }
            "saveDocument" -> {
                val path = call.argument<String>("path")
                val name = call.argument<String>("name")
                val mime = call.argument<String>("mime") ?: "application/octet-stream"
                if (path == null || name == null || pendingDocument != null) {
                    result.success(false)
                    return
                }
                pendingDocument = PendingDocument(result, save = File(path))
                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = mime
                    putExtra(Intent.EXTRA_TITLE, name)
                }
                startDocumentActivity(intent)
            }
            "openDocument" -> {
                if (pendingDocument != null) {
                    result.success(null)
                    return
                }
                pendingDocument = PendingDocument(result, save = null)
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "*/*"
                    putExtra(
                        Intent.EXTRA_MIME_TYPES,
                        arrayOf("application/zip", "application/x-zip-compressed", "application/octet-stream"),
                    )
                }
                startDocumentActivity(intent)
            }
            "setSecure" -> {
                if (call.argument<Boolean>("secure") == true) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun startDocumentActivity(intent: Intent) {
        try {
            documentLauncher.launch(intent)
        } catch (e: ActivityNotFoundException) {
            val pending = pendingDocument
            pendingDocument = null
            pending?.result?.success(if (pending.save != null) false else mapOf("error" to "no_app"))
        }
    }

    /** Copies between the chosen document and app-private files off the UI thread. */
    private fun onDocumentResult(resultCode: Int, data: Intent?) {
        val pending = pendingDocument ?: return
        pendingDocument = null
        val uri = data?.data
        if (resultCode != RESULT_OK || uri == null) {
            pending.result.success(if (pending.save != null) false else null)
            return
        }
        io.execute {
            val reply: Any? = if (pending.save != null) {
                try {
                    contentResolver.openOutputStream(uri, "wt").use { out ->
                        if (out == null) throw java.io.IOException("No output stream")
                        pending.save.inputStream().use { it.copyTo(out, 64 * 1024) }
                    }
                    true
                } catch (e: Exception) {
                    false
                }
            } else {
                copyBackup(uri)
            }
            main.post { pending.result.success(reply) }
        }
    }

    private fun copyBackup(uri: Uri): Map<String, Any?> {
        val dir = File(cacheDir, "restore").apply {
            deleteRecursively()
            mkdirs()
        }
        val target = File(dir, "backup.zip")
        return try {
            var total = 0L
            contentResolver.openInputStream(uri).use { input ->
                if (input == null) return mapOf("error" to "inaccessible")
                target.outputStream().use { output ->
                    val buffer = ByteArray(64 * 1024)
                    while (true) {
                        val read = input.read(buffer)
                        if (read < 0) break
                        total += read
                        if (total > MAX_BACKUP_BYTES) {
                            output.close()
                            target.delete()
                            return mapOf("error" to "too_large")
                        }
                        output.write(buffer, 0, read)
                    }
                }
            }
            mapOf("path" to target.absolutePath, "name" to displayName(uri))
        } catch (e: SecurityException) {
            mapOf("error" to "inaccessible")
        } catch (e: java.io.IOException) {
            val noSpace = e.message?.contains("ENOSPC") == true
            mapOf("error" to if (noSpace) "no_space" else "inaccessible")
        }
    }

    private class PendingDocument(val result: MethodChannel.Result, val save: File?)

    /**
     * Android 11+: the system asks the user whether to save the network. No
     * Wi-Fi permission is needed, and nothing connects without that consent.
     * Returns false when unsupported, so the caller can fall back to copying.
     */
    private fun addWifiNetwork(call: MethodCall, result: MethodChannel.Result) {
        val ssid = call.argument<String>("ssid")
        val password = call.argument<String>("password")
        if (ssid.isNullOrBlank() || Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.success(false)
            return
        }
        try {
            val builder = WifiNetworkSuggestion.Builder().setSsid(ssid)
            if (!password.isNullOrEmpty()) builder.setWpa2Passphrase(password)
            val intent = Intent(Settings.ACTION_WIFI_ADD_NETWORKS).apply {
                putParcelableArrayListExtra(
                    Settings.EXTRA_WIFI_NETWORK_LIST,
                    arrayListOf(builder.build()),
                )
            }
            startActivity(intent)
            result.success(true)
        } catch (e: IllegalArgumentException) {
            // For example a WPA2 passphrase shorter than 8 characters.
            result.success(false)
        } catch (e: ActivityNotFoundException) {
            result.success(false)
        }
    }

    private fun launch(result: MethodChannel.Result, build: () -> Intent) {
        try {
            startActivity(build())
            result.success(true)
        } catch (e: ActivityNotFoundException) {
            result.success(false)
        }
    }

    /** Extracts image URIs from a share intent and neutralises the intent. */
    private fun consumeShare(intent: Intent?): List<Uri> {
        if (intent == null) return emptyList()
        val uris = when (intent.action) {
            Intent.ACTION_SEND -> listOfNotNull(intent.streamExtra())
            Intent.ACTION_SEND_MULTIPLE -> intent.streamListExtra()
            else -> emptyList()
        }
        if (uris.isNotEmpty()) {
            intent.action = Intent.ACTION_MAIN
            intent.removeExtra(Intent.EXTRA_STREAM)
        }
        return uris
    }

    @Suppress("DEPRECATION")
    private fun Intent.streamExtra(): Uri? =
        if (Build.VERSION.SDK_INT >= 33) {
            getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            getParcelableExtra(Intent.EXTRA_STREAM)
        }

    @Suppress("DEPRECATION")
    private fun Intent.streamListExtra(): List<Uri> =
        (if (Build.VERSION.SDK_INT >= 33) {
            getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            getParcelableArrayListExtra(Intent.EXTRA_STREAM)
        })?.filterNotNull() ?: emptyList()

    private fun copyAsync(uris: List<Uri>, done: (List<Map<String, Any?>>) -> Unit) {
        if (uris.isEmpty()) {
            done(emptyList())
            return
        }
        io.execute {
            val dir = File(cacheDir, "shared_imports").apply { mkdirs() }
            val out = uris.mapIndexed { index, uri -> copyOne(uri, dir, index) }
            main.post { done(out) }
        }
    }

    private fun copyOne(uri: Uri, dir: File, index: Int): Map<String, Any?> {
        val name = displayName(uri)
        return try {
            val mime = contentResolver.getType(uri)
            if (mime != null && !mime.startsWith("image/")) {
                return mapOf("name" to name, "error" to "unsupported")
            }
            val target = File(dir, "${System.currentTimeMillis()}_$index.bin")
            var total = 0L
            contentResolver.openInputStream(uri).use { input ->
                if (input == null) return mapOf("name" to name, "error" to "inaccessible")
                target.outputStream().use { output ->
                    val buffer = ByteArray(64 * 1024)
                    while (true) {
                        val read = input.read(buffer)
                        if (read < 0) break
                        total += read
                        if (total > MAX_BYTES) {
                            output.close()
                            target.delete()
                            return mapOf("name" to name, "error" to "too_large")
                        }
                        output.write(buffer, 0, read)
                    }
                }
            }
            mapOf("path" to target.absolutePath, "name" to name, "mime" to mime)
        } catch (e: SecurityException) {
            mapOf("name" to name, "error" to "inaccessible")
        } catch (e: java.io.IOException) {
            val noSpace = e.message?.contains("ENOSPC") == true
            mapOf("name" to name, "error" to if (noSpace) "no_space" else "inaccessible")
        }
    }

    private fun displayName(uri: Uri): String? = try {
        contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { c -> if (c.moveToFirst()) c.getString(0) else null }
    } catch (e: Exception) {
        null
    }

    companion object {
        private const val CHANNEL = "snapaction/platform"
        private const val KEY_HANDLED = "snapaction_share_handled"
        private const val MAX_BYTES = 40L * 1024 * 1024
        private const val MAX_BACKUP_BYTES = 2L * 1024 * 1024 * 1024
    }
}
