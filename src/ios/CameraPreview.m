#import <AssetsLibrary/AssetsLibrary.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVInvokedUrlCommand.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraPreview.h"
#import <math.h>

@implementation CameraPreview

static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
};

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

- (void) startCamera:(CDVInvokedUrlCommand*)command {
    
    CDVPluginResult *pluginResult;
    
    if (self.sessionManager != nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera already started!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    if (command.arguments.count > 5) {
        CGFloat x = (CGFloat)[command.arguments[0] floatValue] + self.webView.frame.origin.x;
        CGFloat y = (CGFloat)[command.arguments[1] floatValue] + self.webView.frame.origin.y;
        CGFloat width = (CGFloat)[command.arguments[2] floatValue];
        CGFloat height = (CGFloat)[command.arguments[3] floatValue];
        NSString *defaultCamera = command.arguments[4];
        CGFloat desiredFPS = [command.arguments[5] floatValue];
        CGRect bounds=CGRectMake(x, y, width, height);
        self.previewView=[[UIView alloc]initWithFrame:bounds];
        //self.fileNamePrefix=fileNamePrefix;
        self.bounds=bounds;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //self.directoryPath=directoryPath;
        [self.viewController.view addSubview:self.previewView];
        [self.viewController.view bringSubviewToFront:self.previewView];
        if ([defaultCamera isEqual: @"front"]) {
            self.sessionManager= [[TTMCaptureManager alloc]initWithPreviewView:self.previewView preferredCameraType:CameraTypeFront outputMode:OutputModeMovieFile previewBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        } else {
            self.sessionManager= [[TTMCaptureManager alloc]initWithPreviewView:self.previewView preferredCameraType:CameraTypeBack outputMode:OutputModeMovieFile previewBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        }
        
        
        self.sessionManager.delegate=self;
        [self.sessionManager switchFormatWithDesiredFPS:desiredFPS];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid number of parameters"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) stopCamera:(CDVInvokedUrlCommand*)command {
    NSLog(@"stopCamera");
    if(self.sessionManager != nil){
        [self.previewView removeFromSuperview];
        
        self.previewView = nil;
        
        [self.sessionManager.captureSession stopRunning];
        self.sessionManager = nil;
        
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"camera stopped"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }else{
        
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }
}

- (void) hideCamera:(CDVInvokedUrlCommand*)command {
    NSLog(@"hideCamera");
    CDVPluginResult *pluginResult;
    
    if (self.previewView != nil) {
        [self.previewView setHidden:YES];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) showCamera:(CDVInvokedUrlCommand*)command {
    NSLog(@"showCamera");
    CDVPluginResult *pluginResult;
    
    if (self.previewView != nil) {
        [self.previewView setHidden:NO];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) switchCamera:(CDVInvokedUrlCommand*)command {
    NSLog(@"switchCamera");
    CDVPluginResult *pluginResult;
    
    if (self.sessionManager != nil) {
        [self.sessionManager switchCamera];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) startRecording:(CDVInvokedUrlCommand*)command {
    NSLog(@"startRecording");
    __block CDVPluginResult *pluginResult;
    if(command.arguments.count >1){
        NSString* directoryPath = command.arguments[0];
        NSString* fileNamePrefix = command.arguments[1];
        
        self.directoryPath=directoryPath;
        self.fileNamePrefix=fileNamePrefix;
        if (self.sessionManager != NULL) {
            // REC START
            if (!self.sessionManager.isRecording) {
                
                
                
                [self.sessionManager startRecordingInDirectory:self.directoryPath AndFilePrefix:self.fileNamePrefix];//WithCallback:^{
                _onVideoCapturingStartedHandlerId=command.callbackId;
                //                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Camera recording started"];
                //                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                //}];
            }
            // Error callbacks
            else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera already recording"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
            
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }
}

- (void) stopRecording:(CDVInvokedUrlCommand*)command {
    NSLog(@"stopRecording");
    CDVPluginResult *pluginResult;
    
    if (self.sessionManager != NULL) {
        // REC START
        if (self.sessionManager.isRecording) {
            
            
            self.onVideoCapturedHandlerId=command.callbackId;
            
            [self.sessionManager stopRecording];
            
        }
        // Error callbacks
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera is not recording"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}
#pragma mark - Private


- (void)saveRecordedFile:(NSURL *)recordedFile {
    
    NSLog(@"saved File %@",recordedFile.absoluteString);
}




// ==============================================================================


-(void) setOnPictureTakenHandler:(CDVInvokedUrlCommand*)command {
    NSLog(@"setOnPictureTakenHandler");
    self.onPictureTakenHandlerId = command.callbackId;
}


-(void) setFlashLight:(CDVInvokedUrlCommand *)command {
    
    NSLog(@"setFlashLight...");
    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
    {
        
        BOOL needToActivate = (BOOL)[command.arguments[0] boolValue];
        BOOL success = [flashLight lockForConfiguration:nil];
        
        
        if (success)
        {
            if (needToActivate == FALSE)
            {
                [flashLight setTorchMode:AVCaptureTorchModeOff];
                NSLog(@"setFlashLight FALSE");
            }
            else
            {
                [flashLight setTorchMode:AVCaptureTorchModeOn];
                NSLog(@"setFlashLight TRUE");
            }
            [flashLight unlockForConfiguration];
        }
    }
}

-(void) setColorEffect:(CDVInvokedUrlCommand*)command {
    NSLog(@"setColorEffect");
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    NSString *filterName = command.arguments[0];
    
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void) invokeTakePicture {
    [self invokeTakePicture:0.0 withHeight:0.0];
}
- (void) invokeTakePicture:(CGFloat) maxWidth withHeight:(CGFloat) maxHeight {
    
}

-(void)generateFramesFromVideo:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* result=nil;
    if(command.arguments.count >3){
        NSString* filePath=command.arguments[0];
        AVURLAsset * asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:filePath ] options:nil];
        
        float fps=[command.arguments[1] floatValue];
        NSString* directoryPath=command.arguments[2];
        NSString* fileNamePrefix=command.arguments[3];
        
        float durationInSeconds = CMTimeGetSeconds(asset.duration);
        NSUInteger requiredNumberOfFrames=(durationInSeconds*fps);
        
        
        
        
        NSLog(@" file to load is: %@",filePath);
        
        
        NSMutableArray* filePaths=[[NSMutableArray alloc]init];
        
        
        [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:
         ^{
             dispatch_queue_t writerQueue= dispatch_queue_create("screenshots.writer.queue", DISPATCH_QUEUE_SERIAL);
             if(!_fileWriter)_fileWriter= dispatch_queue_create("screenshots.filewriter.queue", DISPATCH_QUEUE_SERIAL);
             
             dispatch_async(writerQueue,
                            ^{
                                AVAssetTrack * videoTrack = nil;
                                NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
                                if ([tracks count] == 1)
                                {
                                    videoTrack = [tracks objectAtIndex:0];
                                    
                                    
                                    CGAffineTransform txf       = [videoTrack preferredTransform];
                                    CGFloat videoAngleInDegree  = RadiansToDegrees(atan2(txf.b, txf.a));
                                    
                                    UIImageOrientation orientation = UIImageOrientationRight;
                                    switch ((int)videoAngleInDegree) {
                                        case 0:
                                            orientation = UIImageOrientationRight;
                                            break;
                                        case 90:
                                            orientation = UIImageOrientationUp;
                                            break;
                                        case 180:
                                            orientation = UIImageOrientationLeft;
                                            break;
                                        case -90:
                                            orientation	= UIImageOrientationDown;
                                            break;
                                        default:
                                            orientation = UIImageOrientationRight;
                                            break;
                                    }
                                    
                                    NSError * error = nil;
                                    
                                    // _movieReader is a member variable
                                    AVAssetReader *movieReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
                                    if (error)
                                        NSLog(@"_movieReader fail!\n");
                                    
                                    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
                                    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
                                    NSDictionary* videoSettings =
                                    [NSDictionary dictionaryWithObject:value forKey:key];
                                    
                                    [movieReader addOutput:[AVAssetReaderTrackOutput
                                                            assetReaderTrackOutputWithTrack:videoTrack
                                                            outputSettings:videoSettings]];
                                    [movieReader startReading];
                                    int index=0;
                                    
                                    if (![[NSFileManager defaultManager] fileExistsAtPath:[directoryPath stringByAppendingString:@"tmpImages/"]]){
                                        [[NSFileManager defaultManager] createDirectoryAtPath:[directoryPath stringByAppendingString:@"tmpImages/"] withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
                                    }else{
                                        [[NSFileManager defaultManager] removeItemAtPath:[directoryPath stringByAppendingString:@"tmpImages/"] error:&error];
                                        [[NSFileManager defaultManager] createDirectoryAtPath:[directoryPath stringByAppendingString:@"tmpImages/"] withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
                                    }
                                    if(error){
                                        NSLog(@"tmpImages directory %@ creation error: %@",[directoryPath stringByAppendingString:@"tmpImages/"] ,error.localizedDescription);
                                    }
                                    while ([movieReader status] == AVAssetReaderStatusReading)
                                    {
                                        AVAssetReaderOutput * output = [movieReader.outputs objectAtIndex:0];
                                        
                                        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
                                        
                                        if (sampleBuffer)
                                        {
                                            
                                            
                                            NSString* filename= [NSString stringWithFormat:@"tmpImages/%@_%04d.png",fileNamePrefix,index];
                                            NSURL *fileURL = [NSURL fileURLWithPath:[directoryPath stringByAppendingPathComponent:filename]];
                                            
                                            [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo orientation:orientation imageIndex:index fileURL:fileURL];
                                            index++;
                                            [filePaths addObject:fileURL.path];
                                            NSLog(@"%@",fileURL.absoluteString);
                                            CFRelease(sampleBuffer);
                                        }
                                        
                                    }
                                    NSUInteger framesInVideo=[filePaths count];
                                    
                                    NSUInteger numberOfFramesToBeIgnore = framesInVideo-requiredNumberOfFrames;
                                    float nthFrameToIgnore = framesInVideo*1.0/numberOfFramesToBeIgnore;
                                    NSMutableArray* filePathsRequired=[[NSMutableArray alloc]init];
                                    int t=0;
                                    
                                    
                                    
                                    float step=(framesInVideo-1)/(requiredNumberOfFrames-1);       //set step size
                                    
                                    
                                    //
                                    int i=0;
                                    
                                    for(NSString* filePath in filePaths){
                                        NSLog(@" modulus %f",fmod(t,nthFrameToIgnore));
                                        if( (int)(step*i) != t){
                                            NSError* error;
                                            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                                            if (!success) {
                                                NSLog(@"Error removing file at path: %@", error.localizedDescription);
                                            }
                                        }else{
                                            NSError *error = nil;
                                            NSString* filename= [NSString stringWithFormat:@"%@_%04lu.png",fileNamePrefix,(unsigned long)[filePathsRequired count]];
                                            NSURL *fileURL = [NSURL fileURLWithPath:[directoryPath stringByAppendingPathComponent:filename]];
                                            NSURL *oldURL = [NSURL fileURLWithPath:filePath];
                                            [[NSFileManager defaultManager] moveItemAtURL:oldURL toURL:fileURL error:&error];
                                            if (error) {
                                                NSLog(@"Error writing to file at path: %@", error.localizedDescription);
                                            }
                                            NSLog(@"%@",fileURL.absoluteString);
                                            
                                            [filePathsRequired addObject:fileURL.absoluteString];
                                            i++;
                                        }
                                        t++;
                                    }
                                    CDVPluginResult* result= [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:filePathsRequired];
                                    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                                    
                                    
                                }else{
                                    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Video Track not found in video"];
                                    [self.commandDelegate sendPluginResult:result callbackId:self.onVideoCapturedHandlerId];
                                    
                                }
                            });
         }];
        
        
    }else{
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid arguments for generating frames"];
        [self.commandDelegate sendPluginResult:result callbackId:self.onVideoCapturedHandlerId];
        
    }
}

-(float) round:(float)num toSignificantFigures:(int)n {
    if(num == 0) {
        return 0;
    }
    
    double d = ceil(log10(num < 0 ? -num: num));
    int power = n - (int) d;
    
    double magnitude = pow(10, power);
    long shifted = round(num*magnitude);
    return shifted/magnitude;
}

- (void) writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType orientation:(UIImageOrientation)orientation imageIndex:(int)index fileURL:(NSURL*)fileURL
{
    
    @autoreleasepool {
        
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        CGRect bounds ;
        long double rotation=0.0;
        switch (orientation) {
            case UIImageOrientationRight:
            case UIImageOrientationLeft:
                bounds= CGRectMake(self.bounds.origin.x*screenScale, self.bounds.origin.y*screenScale, self.bounds.size.width*screenScale, self.bounds.size.height*screenScale);
                rotation=0.0;
                break;
            case UIImageOrientationUp:
                rotation=-M_PI_2;
                
                bounds= CGRectMake(self.bounds.origin.y*screenScale, self.bounds.origin.x*screenScale, self.bounds.size.height*screenScale, self.bounds.size.width*screenScale);
                break;
            case UIImageOrientationDown:
                rotation=M_PI_2;
                
                bounds= CGRectMake(self.bounds.origin.y*screenScale, self.bounds.origin.x*screenScale, self.bounds.size.height*screenScale, self.bounds.size.width*screenScale);
                break;
            default:
                rotation=0.0;
                break;
        }
        
        CGFloat scaleHeight = bounds.size.height/image.extent.size.height;
        CGFloat scaleWidth = bounds.size.width/image.extent.size.width;
        
        NSLog(@"image width:%f height:%f",image.extent.size.width,image.extent.size.height);
        CGFloat scale, x, y;
        if (scaleHeight < scaleWidth) {
            scale = scaleWidth;
            x = 0;
            y = ((scale * image.extent.size.height) - bounds.size.height ) / 2;
        } else {
            scale = scaleHeight;
            x = ((scale * image.extent.size.width) - bounds.size.width )/ 2;
            y = 0;
        }
        CIImage *transformedImage=nil;
        //transform and scale
        CGAffineTransform xscale = CGAffineTransformMakeScale(scale, scale);
        CGAffineTransform xlate = CGAffineTransformMakeTranslation(-x, -y);
        CGAffineTransform xform =  CGAffineTransformConcat(xscale, xlate);
        
        CIFilter *centerFilter = [CIFilter filterWithName:@"CIAffineTransform"  keysAndValues:
                                  kCIInputImageKey, image,
                                  kCIInputTransformKey, [NSValue valueWithBytes:&xform objCType:@encode(CGAffineTransform)],
                                  nil];
        
        transformedImage = [centerFilter outputImage];
        NSLog(@"transformedImage x:%f y:%f width:%f height:%f",transformedImage.extent.origin.x,transformedImage.extent.origin.y,transformedImage.extent.size.width,transformedImage.extent.size.height);
        
        
        CIImage *croppedImage=nil;
        // crop
        croppedImage=[transformedImage imageByCroppingToRect:CGRectMake((transformedImage.extent.size.width-bounds.size.width)/2.0 +transformedImage.extent.origin.x,
                                                                        (transformedImage.extent.size.width-bounds.size.width)/2.0 +transformedImage.extent.origin.y,
                                                                        bounds.size.width, bounds.size.height)];
        //rotating to correct orientation
        croppedImage =[croppedImage imageByApplyingTransform:CGAffineTransformMakeRotation(rotation)];
        
        NSLog(@"croppedImage width:%f height:%f",croppedImage.extent.size.width,croppedImage.extent.size.height);
        
        
        CIContext *context = [CIContext contextWithOptions:nil];
        
        CGImageRef cgiimage;
        
        
        
        if(croppedImage)
            cgiimage = [context createCGImage:croppedImage fromRect:croppedImage.extent];
        else if(transformedImage)
            cgiimage = [context createCGImage:transformedImage fromRect:transformedImage.extent];
        else
            cgiimage = [context createCGImage:image fromRect:image.extent];
        UIImage* uiImage = [UIImage imageWithCGImage:cgiimage];
        
        CGImageRelease(cgiimage);
        [UIImagePNGRepresentation(uiImage) writeToURL:fileURL atomically:YES];
        NSLog(@"image url: %@",fileURL.absoluteString);
        
    }
    
    
}
// =============================================================================
#pragma mark - TTMCaptureManagerDeleagte

- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error {
    
    //LOG_CURRENT_METHOD;
    CDVPluginResult *pluginResult=nil;
    if (error) {
        NSLog(@"error:%@", error);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_onVideoCapturedHandlerId!=nil?_onVideoCapturedHandlerId:_onVideoCapturingStartedHandlerId];
        
        return;
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:outputFileURL.absoluteString];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_onVideoCapturedHandlerId!=nil?_onVideoCapturedHandlerId:_onVideoCapturingStartedHandlerId];
    
    
    
}


@end
