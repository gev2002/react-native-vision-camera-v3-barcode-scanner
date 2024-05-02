package com.visioncamerav3barcodescanner

import android.media.Image
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UNKNOWN
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_ALL_FORMATS
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_128
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_39
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_93
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODABAR
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_DATA_MATRIX
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_13
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_8
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_ITF
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_QR_CODE
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UPC_A
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UPC_E
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_PDF417
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_AZTEC
import com.google.mlkit.vision.common.InputImage
import com.mrousavy.camera.frameprocessors.Frame
import com.mrousavy.camera.frameprocessors.FrameProcessorPlugin
import com.mrousavy.camera.frameprocessors.VisionCameraProxy

class VisionCameraV3BarcodeScannerModule(proxy : VisionCameraProxy, options: Map<String, Any>?): FrameProcessorPlugin() {
    private var optionsBuilder = BarcodeScannerOptions.Builder()

    init {
        this.setCodeTypes(options)
    }

    override fun callback(frame: Frame, arguments: Map<String, Any>?): Any {
        try {
            setCodeTypes(arguments)

            val scanner = BarcodeScanning.getClient(this.optionsBuilder.build())
            val mediaImage: Image = frame.image
            val image = InputImage.fromMediaImage(mediaImage, frame.imageProxy.imageInfo.rotationDegrees)
            val task: Task<List<Barcode>> = scanner.process(image)
            val barcodes: List<Barcode> = Tasks.await(task)
            val array = WritableNativeArray()

            for (barcode in barcodes) {
                val map = WritableNativeMap()
                val bounds = barcode.boundingBox

                if (bounds != null) {
                    map.putInt("width",bounds.width())
                    map.putInt("height",bounds.height())
                    map.putInt("top",bounds.top)
                    map.putInt("bottom",bounds.bottom)
                    map.putInt("left",bounds.left)
                    map.putInt("right",bounds.right)
                }

                val rawValue = barcode.rawValue
                map.putString("rawValue",rawValue)
                val valueType = barcode.valueType

                when (valueType) {
                    Barcode.TYPE_WIFI -> {
                        val ssid = barcode.wifi!!.ssid
                        map.putString("ssid",ssid)
                        val password = barcode.wifi!!.password
                        map.putString("password",password)
                    }
                    Barcode.TYPE_URL -> {
                        val title = barcode.url!!.title
                        map.putString("title",title)
                        val url = barcode.url!!.url
                        map.putString("url",url)
                    }
                }

                array.pushMap(map)
            }

            return array.toArrayList()
        } catch (e: Exception) {
            throw  Exception("Error processing barcode scanner: $e ")
        }
    }

    private fun setCodeTypes(rawArguments: Map<String, Any>?) {
        val codeTypes = rawArguments?.get("codeTypes") as? List<String> ?: listOf("all_formats")
        var formats = 0

        for (codeType in codeTypes) {
            formats = formats or when (codeType) {
                "unknown" -> FORMAT_UNKNOWN
                "all_formats" -> FORMAT_ALL_FORMATS
                "code_128" -> FORMAT_CODE_128
                "code_39" -> FORMAT_CODE_39
                "code_93" -> FORMAT_CODE_93
                "codabar" -> FORMAT_CODABAR
                "data_matrix" -> FORMAT_DATA_MATRIX
                "ean_13" -> FORMAT_EAN_13
                "ean_8" -> FORMAT_EAN_8
                "itf" -> FORMAT_ITF
                "qr_code" -> FORMAT_QR_CODE
                "upc_a" -> FORMAT_UPC_A
                "upc_e" -> FORMAT_UPC_E
                "pdf417" -> FORMAT_PDF417
                "aztec" -> FORMAT_AZTEC
                else -> 0
            }
        }

        this.optionsBuilder.setBarcodeFormats(formats)
    }
}
