import { Platform } from 'react-native';
import { VisionCameraProxy } from 'react-native-vision-camera';
import type {
  BarcodeData,
  BarcodeScannerOptions,
  BarcodeScannerPlugin,
  Frame,
  FrameProcessorPlugin,
} from './types';

const LINKING_ERROR: string =
  `The package 'react-native-vision-camera-v3-barcode-scanner' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

/**
 * Creates a barcode scanner plugin with the given options.
 *
 * @param options The options for the barcode scanner.
 *
 * @throws {Error} If the frame processor plugin is not initialized.
 *
 * @returns An object with a `scanBarcodes` function that can be used to scan barcodes from a given frame.
 *
 * @example
 * ```ts
 * const barcodeScannerPlugin = createBarcodeScannerPlugin({ codeTypes: ['all_formats'] });
 * const frameProcessor = useFrameProcessor((frame) => {
 *   'worklet'
 *   runAsync(frame, () => {
 *     'worklet'
 *     const data = barcodeScannerPlugin.scanBarcodes(frame)
 *     console.log(data)
 *   })
 * }, [])
 * ```
 */
export function createBarcodeScannerPlugin(
  options: BarcodeScannerOptions
): BarcodeScannerPlugin {
  const plugin: FrameProcessorPlugin | undefined =
    VisionCameraProxy.initFrameProcessorPlugin('scanBarcodes', { ...options });

  if (!plugin) throw new Error(LINKING_ERROR);

  return {
    scanBarcodes: (frame: Frame): BarcodeData => {
      'worklet';
      return plugin.call(frame) as unknown as BarcodeData;
    },
  };
}

const plugin: FrameProcessorPlugin | undefined =
  VisionCameraProxy.initFrameProcessorPlugin('scanBarcodes');

/**
 * Scans barcodes from a given frame.
 *
 * Note: Use {@link createBarcodeScannerPlugin} instead.
 *
 * @param frame The frame to scan for barcodes.
 * @param options The options for the barcode scanner.
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
 *     const data = scanBarcodes(frame, { codeTypes: ['all_formats'] })
 *     console.log(data)
 *   })
 * }, [])
 * ```
 */
export function scanBarcodes(
  frame: Frame,
  options: BarcodeScannerOptions
): BarcodeData {
  'worklet';
  if (plugin == null) throw new Error(LINKING_ERROR);

  // @ts-ignore
  return options ? plugin.call(frame, options) : plugin.call(frame);
}
