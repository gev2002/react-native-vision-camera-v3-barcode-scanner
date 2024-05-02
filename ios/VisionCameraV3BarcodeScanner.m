#import <MLKitBarcodeScanning/MLKitBarcodeScanning.h>
#import <MLKitBarcodeScanning/MLKBarcodeScannerOptions.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCamera/Frame.h>
#import <React/RCTBridgeModule.h>
@import MLKitVision;

@interface VisionCameraV3BarcodeScannerPlugin : FrameProcessorPlugin
@end

@implementation VisionCameraV3BarcodeScannerPlugin {
    MLKBarcodeScannerOptions *options;
}

- (instancetype _Nonnull)initWithProxy:(VisionCameraProxyHolder*)proxy
                           withOptions:(NSDictionary* _Nullable)options {
    self = [super initWithProxy:proxy withOptions:options];
    [self setCodeTypes:options];
    return self;
}

- (id _Nullable)callback:(Frame* _Nonnull)frame
           withArguments:(NSDictionary* _Nullable)arguments {
    if (arguments != nil && [arguments.allKeys containsObject:@"codeTypes"]) {
        [self setCodeTypes:arguments];
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

- (void)setCodeTypes:(NSDictionary* _Nullable)rawArguments {
    NSArray *codeTypes = rawArguments[@"codeTypes"] ?: @[@"all_formats"];
    MLKBarcodeFormat formats = MLKBarcodeFormatAll;

    for (NSString *codeType in codeTypes) {
        formats = formats | [self barcodeFormatForString:codeType];
    }

    options = [[MLKBarcodeScannerOptions alloc] initWithFormats:formats];
}

- (MLKBarcodeFormat)barcodeFormatForString:(NSString *)string {
    if ([string isEqualToString:@"unknown"]) {
        return MLKBarcodeFormatUnknown;
    } else if ([string isEqualToString:@"all_formats"]) {
        return MLKBarcodeFormatAll;
    } else if ([string isEqualToString:@"code_128"]) {
        return MLKBarcodeFormatCode128;
    } else if ([string isEqualToString:@"code_39"]) {
        return MLKBarcodeFormatCode39;
    } else if ([string isEqualToString:@"code_93"]) {
        return MLKBarcodeFormatCode93;
    } else if ([string isEqualToString:@"codabar"]) {
        return MLKBarcodeFormatCodaBar;
    } else if ([string isEqualToString:@"data_matrix"]) {
        return MLKBarcodeFormatDataMatrix;
    } else if ([string isEqualToString:@"ean_13"]) {
        return MLKBarcodeFormatEAN13;
    } else if ([string isEqualToString:@"ean_8"]) {
        return MLKBarcodeFormatEAN8;
    } else if ([string isEqualToString:@"itf"]) {
        return MLKBarcodeFormatITF;
    } else if ([string isEqualToString:@"qr_code"]) {
        return MLKBarcodeFormatQRCode;
    } else if ([string isEqualToString:@"upc_a"]) {
        return MLKBarcodeFormatUPCA;
    } else if ([string isEqualToString:@"upc_e"]) {
        return MLKBarcodeFormatUPCE;
    } else if ([string isEqualToString:@"pdf417"]) {
        return MLKBarcodeFormatPDF417;
    } else if ([string isEqualToString:@"aztec"]) {
        return MLKBarcodeFormatAztec;
    } else {
        return 0;
    }
}

VISION_EXPORT_FRAME_PROCESSOR(VisionCameraV3BarcodeScannerPlugin, scanBarcodes)

@end
