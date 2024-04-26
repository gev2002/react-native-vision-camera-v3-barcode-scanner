import type { CameraProps } from 'react-native-vision-camera';
export type {
  Frame,
  ReadonlyFrameProcessor,
  FrameProcessorPlugin,
} from 'react-native-vision-camera';
import type { Frame } from 'react-native-vision-camera';
export type { ForwardedRef } from 'react';

type BarCodeType = Readonly<{
  aztec: any;
  code128: any;
  code39: any;
  code39mod43: any;
  code93: any;
  ean13: any;
  ean8: any;
  pdf417: any;
  qr: any;
  upc_e: any;
  interleaved2of5: any;
  itf14: any;
  datamatrix: any;
  all: any;
}>;

export type ScanBarcodeOptions = Array<keyof BarCodeType>;

export type Barcode = {
  bottom: number;
  height: number;
  left: number;
  rawValue: string;
  right: number;
  top: number;
  width: number;
};

export type BarcodeData = {
  [key: number]: Barcode;
};

export type CameraTypes = {
  callback: (data: BarcodeData) => void;
  options: ScanBarcodeOptions;
} & CameraProps;

export type BarcodeScannerPlugin = {
  scanBarcodes: (frame: Frame) => Barcode;
};
