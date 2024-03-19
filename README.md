
The frame processor plugin for scanning barcodes using Google ML Kit library for react-native-vision-camera with high performance.
# 🚨 Required Modules

react-native-vision-camera => 3.9.0 <br />
react-native-worklets-core = 0.4.0

## 💻 Installation

```sh
npm install react-native-vision-camera-v3-barcode-scanner
yarn add react-native-vision-camera-v3-barcode-scanner
```
## 👷Features
    Easy To Use.
    Works Just Writing few lines of Code.
    Works With React Native Vision Camera.
    Works for Both Cameras.
    Works Fast.
    Works With Android 🤖 and IOS.📱
    Writen With Objective-C and Kotlin.

## 💡 Usage

```js
import { Camera } from 'react-native-vision-camera-v3-barcode-scanner';

const [barcodes,setBarcodes] = useState(null)

console.log(barcodes)

<Camera
  options={{
    codeType: "all",
    }}
  style={StyleSheet.absoluteFill}
  device={device}
  callback={(data) => setBarcodes(data)}
  {...props}
/>
```


---

## ⚙️ Options

| Name |  Type    |  Values  | Default |
| :---:   | :---: | :---: |  :---: |
| codeType | String  | all, code-39, code-93, codabar, ean-13, ean-8, itf, upc-e, upc-a, qr, pdf-417, aztec, data-matrix, code-128 | all |















