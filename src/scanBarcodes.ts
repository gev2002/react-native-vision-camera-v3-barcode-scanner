import type { Frame, FrameProcessorPlugin, ScanBarcodeOptions, BarcodeDataMap } from './types';
import { VisionCameraProxy } from 'react-native-vision-camera';
import { Platform } from 'react-native';

const plugin: FrameProcessorPlugin | undefined =
  VisionCameraProxy.initFrameProcessorPlugin('scanBarcodes');

const LINKING_ERROR: string =
  `The package 'react-native-vision-camera-v3-barcode-scanner' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

export function scanBarcodes(frame: Frame, options: ScanBarcodeOptions): BarcodeDataMap {
  'worklet';
  if (plugin == null) throw new Error(LINKING_ERROR);
  // @ts-ignore
  return options ? plugin.call(frame, options) : plugin.call(frame);
}
