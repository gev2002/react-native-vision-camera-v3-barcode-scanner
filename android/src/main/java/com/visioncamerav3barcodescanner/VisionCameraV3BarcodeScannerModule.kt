package com.visioncamerav3barcodescanner

import android.media.Image
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_ALL_FORMATS
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_AZTEC
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODABAR
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_128
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_39
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_93
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_DATA_MATRIX
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_ITF
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_PDF417
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_QR_CODE
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UPC_A
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UPC_E
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_8
import com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_13
import com.google.mlkit.vision.common.InputImage
import com.mrousavy.camera.frameprocessors.Frame
import com.mrousavy.camera.frameprocessors.FrameProcessorPlugin
import com.mrousavy.camera.frameprocessors.VisionCameraProxy

class VisionCameraV3BarcodeScannerModule(proxy : VisionCameraProxy, options: Map<String, Any>?): FrameProcessorPlugin() {

  override fun callback(frame: Frame, arguments: Map<String, Any>?): Any {
    try {
      val optionsBuilder = BarcodeScannerOptions.Builder()

      if (arguments?.get("code-128").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_CODE_128)
      else if (arguments?.get("code-39").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_CODE_39)
      else if (arguments?.get("code-93").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_CODE_93)
      else if (arguments?.get("codabar").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_CODABAR)
      else if (arguments?.get("ean-13").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_EAN_13)
      else if (arguments?.get("ean-8").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_EAN_8)
      else if (arguments?.get("itf").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_ITF)
      else if (arguments?.get("upc-e").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_UPC_E)
      else if (arguments?.get("upc-a").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_UPC_A)
      else if (arguments?.get("qr").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_QR_CODE)
      else if (arguments?.get("pdf-417").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_PDF417)
      else if (arguments?.get("aztec").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_AZTEC)
      else if (arguments?.get("data-matrix").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_DATA_MATRIX)
      else if (arguments?.get("all").toString().toBoolean()) optionsBuilder.setBarcodeFormats(FORMAT_ALL_FORMATS)
      else optionsBuilder.setBarcodeFormats(FORMAT_ALL_FORMATS)

      val scanner = BarcodeScanning.getClient(optionsBuilder.build())
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
}
