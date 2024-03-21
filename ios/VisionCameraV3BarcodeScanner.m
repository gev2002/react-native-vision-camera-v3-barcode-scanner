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
    NSMutableArray *data = [NSMutableArray array];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [barcodeScanner processImage:image
                          completion:^(NSArray<MLKBarcode *> *_Nullable barcodes,
                                       NSError *_Nullable error) {
            if (error != nil) {
                RCTResponseErrorBlock error;
                return;
            }
            if (barcodes.count > 0) {
                for (MLKBarcode *barcode in barcodes) {
                    NSMutableDictionary *obj = [[NSMutableDictionary alloc] init];

                    NSString *displayValue = barcode.displayValue;
                    obj[@"displayValue"] = displayValue;
                    NSString *rawValue = barcode.rawValue;
                    obj[@"rawValue"] = rawValue;
                    obj[@"left"] = @(CGRectGetMinX(barcode.frame));
                    obj[@"top"] = @(CGRectGetMinY(barcode.frame));
                    obj[@"right"] = @(CGRectGetMaxX(barcode.frame));
                    obj[@"bottom"] = @(CGRectGetMaxY(barcode.frame));
                    obj[@"width"] = @(barcode.frame.size.width);
                    obj[@"height"] = @(barcode.frame.size.height);

                    MLKBarcodeValueType valueType = barcode.valueType;

                    switch (valueType) {
                        case MLKBarcodeValueTypeWiFi:
                            obj[@"ssid"] = barcode.wifi.ssid;
                            obj[@"password"] = barcode.wifi.password;
                            break;
                        case MLKBarcodeValueTypeURL:
                            obj[@"url"] = barcode.URL.url;
                            obj[@"title"] = barcode.URL.title;
                            break;
                        default:
                            break;
                    }
                    [data addObject:obj];

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
