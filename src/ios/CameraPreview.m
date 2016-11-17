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
    
    if (command.arguments.count > 1) {
        NSString *defaultCamera = command.arguments[0];
        CGFloat desiredFPS = [command.arguments[1] floatValue];
        self.desiredFPS=desiredFPS;
        CGRect bounds=self.viewController.view.frame;
        self.previewView=[[UIView alloc]initWithFrame:self.viewController.view.frame];
        //self.fileNamePrefix=fileNamePrefix;
        self.bounds=bounds;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //self.directoryPath=directoryPath;
        [self.webView.superview addSubview:self.previewView];
        [self.webView.superview bringSubviewToFront:self.previewView];
        [self.webView setOpaque: false];
        [self.webView setBackgroundColor: [UIColor clearColor]];
        [self.webView.scrollView setOpaque:false];
        [self.webView.scrollView setBackgroundColor:[UIColor clearColor]];
        
        for(UIView* childView in self.webView.subviews){
            [childView setOpaque:false];
            [childView setBackgroundColor:[UIColor clearColor]];
            //            for(UIView* childsChildView in childView.subviews){
            //                [childsChildView setOpaque:false];
            //                [childsChildView setBackgroundColor:[UIColor clearColor]];
            //
            //            }
        }
      //  [self.webView.superview bringSubviewToFront:self.webView];
        if ([defaultCamera isEqual: @"user"]) {
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

-(void)getFacing:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* result;
    if(self.sessionManager){
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:self.sessionManager.videoDevice.position==AVCaptureDevicePositionBack?@"environment":@"user"];
    }else{
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started yet"];
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
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
        if(self.sessionManager.isRecording){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera is recording currently"];
        }else{
            [self.sessionManager switchCamera];
            [self.sessionManager switchFormatWithDesiredFPS:self.desiredFPS];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:self.sessionManager.videoDevice.position==AVCaptureDevicePositionBack?@"environment":@"user"];
        }
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
    if(!_fileWriter)_fileWriter= dispatch_queue_create("screenshots.filewriter.queue", DISPATCH_QUEUE_SERIAL);
    CDVPluginResult* result=nil;
    if(command.arguments.count >4){
        NSString* filePath=command.arguments[0];
        AVURLAsset * asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:filePath ] options:nil];
        
        float fps=[command.arguments[1] floatValue];
        NSString* directoryPathWithFileProtocol=command.arguments[2];
        NSString* directoryPath= [directoryPathWithFileProtocol stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSString* fileNamePrefix=command.arguments[3];
        CGFloat quality = (CGFloat)[command.arguments[4] floatValue];
        
        float width=[command.arguments[5] floatValue];
        //__block float width=0;
        float durationInSeconds = CMTimeGetSeconds(asset.duration);
        NSUInteger requiredNumberOfFrames=(durationInSeconds*fps);
        
        
        
        
        NSLog(@" file to load is: %@",filePath);
        
        NSDate *today = [NSDate date];
        
        //Create the dateformatter object
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        //Set the required date format
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        //Get the string date
        NSString *dateString = [dateFormatter stringFromDate:today];
        
        //Display on the console
        NSLog(@"start time %@",dateString);
        
        
        NSMutableArray* filePaths=[[NSMutableArray alloc]init];
        
        
        [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:
         ^{
             dispatch_queue_t writerQueue= dispatch_queue_create("screenshots.writer.queue", DISPATCH_QUEUE_SERIAL);
             
             dispatch_async(writerQueue,
                            ^{
                                AVAssetTrack * videoTrack = nil;
                                NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
                                
                                if ([tracks count] == 1)
                                {
                                    videoTrack = [tracks objectAtIndex:0];
                                    //                                    float aspectRatio= [videoTrack naturalSize].width/[videoTrack naturalSize].height;
                                    //                                    width = aspectRatio*height;
                                    
                                    CGFloat scale = width/[videoTrack naturalSize].width;
                                    
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
                                    long double rotation=0.0;
                                    switch (orientation) {
                                        case UIImageOrientationRight:
                                        case UIImageOrientationLeft:
                                        rotation=0.0;
                                        break;
                                        case UIImageOrientationUp:
                                        rotation=-M_PI_2;
                                        break;
                                        case UIImageOrientationDown:
                                        rotation=M_PI_2;
                                        break;
                                        default:
                                        rotation=0.0;
                                        break;
                                    }
                                    
                                    while ([movieReader status] == AVAssetReaderStatusReading)
                                    {
                                        AVAssetReaderOutput * output = [movieReader.outputs objectAtIndex:0];
                                        
                                        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
                                        
                                        if (sampleBuffer)
                                        {
                                            
                                            
                                            //                                            NSString* filename= [NSString stringWithFormat:@"tmpImages/%@_%04d.jpeg",fileNamePrefix,index];
                                            //                                            NSString* filePath=[directoryPath stringByAppendingPathComponent:filename];
                                            //                                            filePath=[filePath stringByReplacingOccurrencesOfString:@"file:"
                                            //                                                                                    withString:@""];
                                            //NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                                            
                                            @autoreleasepool {
                                                
                                                
                                                CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
                                                CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
                                                //CGFloat screenScale = [[UIScreen mainScreen] scale];
                                                //        //rotating to correct orientation
                                                CIImage* rotatedImage =[image imageByApplyingTransform:CGAffineTransformMakeRotation(rotation)];
                                                
                                                
                                                
                                                CIFilter *resizeFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
                                                [resizeFilter setValue:rotatedImage forKey:@"inputImage"];
                                                [resizeFilter setValue:[NSNumber numberWithFloat:1.0f] forKey:@"inputAspectRatio"];
                                                [resizeFilter setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
                                                
                                                CIImage* croppedImage = resizeFilter.outputImage;
                                                
                                                
                                                CIContext *context = [CIContext contextWithOptions:nil];
                                                
                                                CGImageRef cgiimage;
                                                
                                                
                                                cgiimage = [context createCGImage:croppedImage fromRect:croppedImage.extent];
                                                UIImage* uiImage = [UIImage imageWithCGImage:cgiimage];
                                                
                                                CGImageRelease(cgiimage);
                                                
                                                //[self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo orientation:orientation imageIndex:index fileURL:fileURL quality:quality];
                                                index++;
                                                
                                                [filePaths addObject:[UIImageJPEGRepresentation(uiImage, quality) base64EncodedStringWithOptions:0]];
                                            }
                                            
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
                                        //NSLog(@" modulus %f",fmod(t,nthFrameToIgnore));
                                        if( (int)(step*i) != t){
                                            
                                            //                                            NSError* error;
                                            //                                            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                                            //                                            if (!success) {
                                            //                                                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                                            //                                                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                                            //                                                NSLog(@"Error removing file at path: %@", error.localizedDescription);
                                            //                                                return ;
                                            //                                            }
                                        }else{
                                            NSError *error = nil;
                                            //                                            NSString* filename= [NSString stringWithFormat:@"%@_%04lu.jpeg",fileNamePrefix,(unsigned long)[filePathsRequired count]];
                                            //                                            NSString *fileURL =[directoryPath stringByAppendingPathComponent:filename];
                                            //                                            NSString *oldURL = filePath;
                                            //                                            [[NSFileManager defaultManager] moveItemAtPath:oldURL toPath:fileURL error:&error];
                                            if (error) {
                                                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                                                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                                                NSLog(@"Error writing to file at path: %@", error.localizedDescription);
                                                return ;
                                            }
                                            //                                            NSLog(@"%@",fileURL);
                                            
                                            [filePathsRequired addObject:filePath];
                                            i++;
                                        }
                                        t++;
                                    }
                                    [filePaths removeAllObjects];
                                    NSLog(@" file to load is: %@",filePath);
                                    
                                    NSDate *today = [NSDate date];
                                    
                                    //Create the dateformatter object
                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                    
                                    //Set the required date format
                                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                    
                                    //Get the string date
                                    NSString *dateString = [dateFormatter stringFromDate:today];
                                    
                                    //Display on the console
                                    NSLog(@"stop time %@",dateString);
                                    
                                    
                                    CDVPluginResult* result= [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:filePathsRequired];
                                    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                                    
                                    
                                }else{
                                    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Video Track not found in video"];
                                    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                                    
                                }
                            });
         }];
        
        
    }else{
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid arguments for generating frames"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
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

- (void) writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType orientation:(UIImageOrientation)orientation imageIndex:(int)index fileURL:(NSURL*)fileURL  quality:(float)quality
{
    
    @autoreleasepool {
        
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        //CGFloat screenScale = [[UIScreen mainScreen] scale];
        long double rotation=0.0;
        switch (orientation) {
            case UIImageOrientationRight:
            case UIImageOrientationLeft:
            rotation=0.0;
            break;
            case UIImageOrientationUp:
            rotation=-M_PI_2;
            break;
            case UIImageOrientationDown:
            rotation=M_PI_2;
            break;
            default:
            rotation=0.0;
            break;
        }
        //        //rotating to correct orientation
        image =[image imageByApplyingTransform:CGAffineTransformMakeRotation(rotation)];
        
        
        
        CIContext *context = [CIContext contextWithOptions:nil];
        
        CGImageRef cgiimage;
        
        
        cgiimage = [context createCGImage:image fromRect:image.extent];
        UIImage* uiImage = [UIImage imageWithCGImage:cgiimage];
        
        CGImageRelease(cgiimage);
        [UIImageJPEGRepresentation(uiImage, 0.9) writeToURL:fileURL atomically:YES];
        //[UIImagePNGRepresentation(uiImage) writeToURL:fileURL atomically:YES];
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
