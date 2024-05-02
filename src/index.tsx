import React, { forwardRef, useMemo } from 'react';
import {
  Camera as VisionCamera,
  useFrameProcessor,
} from 'react-native-vision-camera';
import { useRunOnJS } from 'react-native-worklets-core';
import { createBarcodeScannerPlugin } from './scanBarcodes';
import type {
  BarcodeData,
  BarcodeScannerOptions,
  BarcodeScannerPlugin,
  CameraTypes,
  ForwardedRef,
  Frame,
  ReadonlyFrameProcessor,
} from './types';

export { scanBarcodes } from './scanBarcodes';
export * from './types';

/**
 * `Camera` is a component that wraps the {@link VisionCamera} from 'react-native-vision-camera'.
 * It uses the {@link useBarcodeScannerPlugin} hook to scan barcodes from the camera feed.
 *
 * @param device The device to use for the camera.
 * @param callback The function to call when a barcode is scanned.
 * @param options The options for the barcode scanner.
 * @param props The rest of the props to pass to the VisionCamera component.
 * @param ref The ref to forward to the VisionCamera component.
 *
 * @example
 * ```tsx
 * <Camera device={device} callback={handleBarcode} options={{ codeTypes: ['all'] }} />
 * ```
 */
export const Camera = forwardRef(function Camera(
  { device, callback, options, ...props }: CameraTypes,
  ref: ForwardedRef<any>
) {
  const { scanBarcodes } = useBarcodeScannerPlugin(options);

  const useWorklets = useRunOnJS(
    (data: BarcodeData): void => {
      callback(data);
    },
    [options]
  );

  const frameProcessor: ReadonlyFrameProcessor = useFrameProcessor(
    (frame: Frame) => {
      'worklet';
      const data: BarcodeData = scanBarcodes(frame);
      // @ts-ignore
      // eslint-disable-next-line react-hooks/rules-of-hooks
      useWorklets(data);
    },
    []
  );

  return (
    <>
      {!!device && (
        <VisionCamera
          ref={ref}
          device={device}
          pixelFormat="yuv"
          frameProcessor={frameProcessor}
          {...props}
        />
      )}
    </>
  );
});

/**
 * `useBarcodeScannerPlugin` is a hook that creates a barcode scanner plugin with the given options.
 *
 * @param options The options for the barcode scanner.
 *
 * @returns An object with a `scanBarcodes` function that can be used to scan barcodes from a given frame.
 *
 * @example
 * ```tsx
 * const { scanBarcodes } = useBarcodeScannerPlugin({ codeTypes: ['all'] });
 * ```
 */
export function useBarcodeScannerPlugin(
  options?: BarcodeScannerOptions
): BarcodeScannerPlugin {
  return useMemo(
    () => createBarcodeScannerPlugin(options ?? { codeTypes: ['all'] }),
    [options]
  );
}
