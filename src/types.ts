import type { CameraProps, Frame } from 'react-native-vision-camera';

export type { ForwardedRef } from 'react';
export type {
  Frame,
  FrameProcessorPlugin,
  ReadonlyFrameProcessor,
} from 'react-native-vision-camera';

/**
 * CodeTypes from Google's MLkit
 *
 * @example
 * ```
 * "unknown" -> FORMAT_UNKNOWN
 * "all_formats" -> FORMAT_ALL_FORMATS
 * "code_128" -> FORMAT_CODE_128
 * "code_39" -> FORMAT_CODE_39
 * "code_93" -> FORMAT_CODE_93
 * "codabar" -> FORMAT_CODABAR
 * "data_matrix" -> FORMAT_DATA_MATRIX
 * "ean_13" -> FORMAT_EAN_13
 * "ean_8" -> FORMAT_EAN_8
 * "itf" -> FORMAT_ITF
 * "qr_code" -> FORMAT_QR_CODE
 * "upc_a" -> FORMAT_UPC_A
 * "upc_e" -> FORMAT_UPC_E
 * "pdf417" -> FORMAT_PDF417
 * "aztec" -> FORMAT_AZTEC
 * ```
 */
export type CodeType =
  | 'unknown'
  | 'all_formats'
  | 'code_128'
  | 'code_39'
  | 'code_93'
  | 'codabar'
  | 'data_matrix'
  | 'ean_13'
  | 'ean_8'
  | 'itf'
  | 'qr_code'
  | 'upc_a'
  | 'upc_e'
  | 'pdf417'
  | 'aztec';

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
  /**
   * Scans barcodes from a given frame.
   *
   * @param frame The frame to scan for barcodes.
   *
   * @throws {Error} If the frame processor plugin is not initialized.
   *
   * @returns The scanned barcode data.
   *
   * @example
   * ```ts
   * const frameProcessor = useFrameProcessor((frame) => {
   *   'worklet'
   *   runAsync(frame, () => {
   *     'worklet'
   *     const data = scanBarcodes(frame)
   *     console.log(data)
   *   })
   * }, [])
   * ```
   */
  scanBarcodes: (frame: Frame) => BarcodeData;
};
