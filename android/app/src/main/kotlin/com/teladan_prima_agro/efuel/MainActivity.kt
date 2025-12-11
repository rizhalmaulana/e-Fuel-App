package com.teladan_prima_agro.efuel

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream

import android.content.Intent
import android.provider.Settings
import android.os.Build
import android.content.ContentValues
import android.provider.MediaStore
import android.os.Environment
import androidx.core.content.ContextCompat
import android.Manifest
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "nfc_settings"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNfcSettings" -> {
                    try {
                        // Class Intent dan Settings sekarang sudah dikenali karena ada import di atas
                        startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            startActivity(Intent(Settings.ACTION_WIRELESS_SETTINGS))
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", "Could not open settings", null)
                        }
                    }
                }

                "saveJsonFile" -> {
                    val fileName = call.argument<String>("fileName")
                    val jsonData = call.argument<String>("jsonData")

                    if (fileName == null || jsonData == null) {
                        result.error("INVALID_ARGUMENT", "Data tidak lengkap", null)
                        return@setMethodCallHandler
                    }

                    // Class Build sekarang sudah dikenali
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        saveToMediaStore(fileName, jsonData, result)
                    } else {
                        saveToLegacyStorage(fileName, jsonData, result)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun saveToMediaStore(fileName: String, jsonData: String, result: MethodChannel.Result) {
        try {
            // ContentValues dan MediaStore sekarang sudah dikenali
            val contentValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, "application/json")
                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS + "/kongsiSPB")
            }

            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)

            if (uri != null) {
                val outputStream: OutputStream? = resolver.openOutputStream(uri)
                outputStream?.use {
                    it.write(jsonData.toByteArray())
                }
                result.success(uri.toString())
            } else {
                result.error("MEDIASTORE_ERROR", "Gagal membuat URI MediaStore", null)
            }
        } catch (e: Exception) {
            result.error("IO_ERROR_Q", "Gagal menulis file (Q+): ${e.message}", null)
        }
    }

    private fun saveToLegacyStorage(fileName: String, jsonData: String, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
            != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "Izin penyimpanan belum diberikan", null)
            return
        }

        try {
            val root = Environment.getExternalStorageDirectory()

            val dir = File(root, "kongsiSPB")
            if (!dir.exists()) {
                val created = dir.mkdirs()
                if (!created) {
                    result.error("DIR_ERROR", "Gagal membuat folder kongsiSPB", null)
                    return
                }
            }

            val file = File(dir, fileName)

            val fos = FileOutputStream(file)
            fos.write(jsonData.toByteArray())
            fos.close()

            result.success(file.absolutePath)

        } catch (e: IOException) {
            result.error("IO_ERROR_LEGACY", "Gagal menulis file (Legacy): ${e.message}", null)
        }
    }
}