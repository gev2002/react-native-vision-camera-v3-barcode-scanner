import React, { forwardRef, type ForwardedRef } from 'react';
import {
  Camera as VisionCamera,
  useFrameProcessor,
} from 'react-native-vision-camera';
import { useRunInJS } from 'react-native-worklets-core';
import { scanBarcodes } from './scanBarcodes';
import type {
  CameraTypes,
  Frame,
  ReadonlyFrameProcessor,
  BarcodeDataMap,
} from './types';

export { scanBarcodes } from './scanBarcodes';
export type { BarcodeData, BarcodeDataMap } from './types';

export const Camera = forwardRef(function Camera(
  props: CameraTypes,
  ref: ForwardedRef<any>
) {
  const { callback, device, options } = props;
  // @ts-ignore
  const useWorklets = useRunInJS((data: BarcodeDataMap): void => {
    callback(data);
  }, []);
  const frameProcessor: ReadonlyFrameProcessor = useFrameProcessor(
    (frame: Frame): void => {
      'worklet';
      // @ts-ignore
      const data = scanBarcodes(frame, options);
      // @ts-ignore
      // eslint-disable-next-line react-hooks/rules-of-hooks
      useWorklets(data);
    },
    []
  );
  return (
    !!device && (
      <VisionCamera ref={ref} frameProcessor={frameProcessor} {...props} />
    )
  );
});
