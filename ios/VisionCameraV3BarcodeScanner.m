#import <MLKitBarcodeScanning/MLKitBarcodeScanning.h>
#import <MLKitBarcodeScanning/MLKBarcodeScannerOptions.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCamera/VisionCameraProxy.h>
#import <VisionCamera/Frame.h>
@import MLKitVision;

@interface VisionCameraV3BarcodeScannerPlugin : FrameProcessorPlugin
@end

@implementation VisionCameraV3BarcodeScannerPlugin {
    MLKBarcodeScannerOptions *options;
}

- (instancetype _Nonnull)initWithProxy:(VisionCameraProxyHolder*)proxy
                           withOptions:(NSDictionary* _Nullable)options {
    self = [super initWithProxy:proxy withOptions:options];

    return self;
}

- (id _Nullable)callback:(Frame* _Nonnull)frame
           withArguments:(NSDictionary* _Nullable)arguments {
    options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatAll)];

    if (arguments != nil && [arguments.allKeys containsObject:@"codeType"]) {
        NSString *codeType = arguments[@"codeType"];
        if ([codeType  isEqual: @"code-128"]) {
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatCode128)];
        } else if ([codeType  isEqual: @"code-39"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatCode39)];
        } else if ([codeType  isEqual: @"code-93"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatCode93)];
        } else if ([codeType  isEqual: @"codabar"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatCodaBar)];
        } else if ([codeType  isEqual: @"ean-13"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatEAN13)];
        } else if ([codeType  isEqual: @"ean-8"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatEAN8)];
        } else if ([codeType  isEqual: @"itf"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatITF)];
        } else if ([codeType  isEqual: @"upc-e"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatUPCE)];
        } else if ([codeType  isEqual: @"upc-a"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatUPCA)];
        } else if ([codeType  isEqual: @"qr"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatQRCode)];
        } else if ([codeType  isEqual: @"pdf-417"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatPDF417)];
        } else if ([codeType  isEqual: @"aztec"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatAztec)];
        } else if ([codeType isEqual:@"all"]){
            options = [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormatAll)];
        }
    }

    MLKBarcodeScanner *barcodeScanner = [MLKBarcodeScanner barcodeScannerWithOptions:options];

    CMSampleBufferRef buffer = frame.buffer;
    UIImageOrientation orientation = frame.orientation;
    MLKVisionImage *image = [[MLKVisionImage alloc] initWithBuffer:buffer];
    image.orientation = orientation;
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [barcodeScanner processImage:image
                          completion:^(NSArray<MLKBarcode *> *_Nullable barcodes,
                                       NSError *_Nullable error) {
            if (error != nil) {
                [NSException raise:@"Error processing Barcodes Scanner" format:@"%@",error];
            }
            if (barcodes.count > 0) {
                for (MLKBarcode *barcode in barcodes) {
                    NSArray *corners = barcode.cornerPoints;
                    NSString *displayValue = barcode.displayValue;
                    data[@"displayValue"] = displayValue;
                    NSString *rawValue = barcode.rawValue;
                    data[@"rawValue"] = rawValue;
                    data[@"left"] = @(CGRectGetMinX(barcode.frame));
                    data[@"top"] = @(CGRectGetMinY(barcode.frame));
                    data[@"right"] = @(CGRectGetMaxX(barcode.frame));
                    data[@"bottom"] = @(CGRectGetMaxY(barcode.frame));
                    data[@"width"] = @(barcode.frame.size.width);
                    data[@"height"] = @(barcode.frame.size.height);

                    MLKBarcodeValueType valueType = barcode.valueType;

                    switch (valueType) {
                        case MLKBarcodeValueTypeWiFi:
                            data[@"ssid"] = barcode.wifi.ssid;
                            data[@"password"] = barcode.wifi.password;
                            break;
                        case MLKBarcodeValueTypeURL:
                            data[@"url"] = barcode.URL.url;
                            data[@"title"] = barcode.URL.title;
                            break;
                        default:
                            break;
                    }
                }
            }

            dispatch_group_leave(dispatchGroup);
        }];
    });

    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);
    return data;
}

VISION_EXPORT_FRAME_PROCESSOR(VisionCameraV3BarcodeScannerPlugin, scanBarcodes)

@end
