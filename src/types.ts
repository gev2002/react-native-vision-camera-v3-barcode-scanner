import type { CameraProps, Frame } from 'react-native-vision-camera';

export type { ForwardedRef } from 'react';
export type {
  Frame,
  FrameProcessorPlugin,
  ReadonlyFrameProcessor,
} from 'react-native-vision-camera';

export type CodeType =
  | 'aztec'
  | 'code128'
  | 'code39'
  | 'code39mod43'
  | 'code93'
  | 'ean13'
  | 'ean8'
  | 'pdf417'
  | 'qr'
  | 'upc_e'
  | 'interleaved2of5'
  | 'itf14'
  | 'datamatrix'
  | 'all';

export type BarcodeScannerOptions = {
  codeTypes: CodeType[];
};

export type BarcodeInnerData = {
  bottom: number;
  height: number;
  left: number;
  rawValue: string;
  right: number;
  top: number;
  width: number;
};

export type BarcodeData = {
  [key: number]: BarcodeInnerData;
};

export type CameraTypes = {
  callback: (data: BarcodeData) => void;
  options: BarcodeScannerOptions;
} & CameraProps;

export type BarcodeScannerPlugin = {
  scanBarcodes: (frame: Frame) => BarcodeData;
};
