#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVInvokedUrlCommand.h>

#import "CameraSessionManager.h"
#import "CameraRenderController.h"
#import "TTMCaptureManager.h"

@interface CameraPreview : CDVPlugin <TakePictureDelegate,TTMCaptureManagerDelegate>

- (void) startCamera:(CDVInvokedUrlCommand*)command;
- (void) stopCamera:(CDVInvokedUrlCommand*)command;
- (void) getFacing:(CDVInvokedUrlCommand*)command;
- (void) showCamera:(CDVInvokedUrlCommand*)command;
- (void) hideCamera:(CDVInvokedUrlCommand*)command;
- (void) switchCamera:(CDVInvokedUrlCommand*)command;
- (void) setOnPictureTakenHandler:(CDVInvokedUrlCommand*)command;
- (void) setColorEffect:(CDVInvokedUrlCommand*)command;
- (void) setFlashLight:(CDVInvokedUrlCommand*)command;
- (void) generateFramesFromVideo:(CDVInvokedUrlCommand*) command;
- (void) invokeTakePicture:(CGFloat) maxWidth withHeight:(CGFloat) maxHeight;
- (void) invokeTakePicture;

- (void) processFramesFromVideo1:(CDVInvokedUrlCommand*) command;
- (void) processFramesFromVideo2:(CDVInvokedUrlCommand*) command;

- (void) extractAudio:(CDVInvokedUrlCommand*) command;
- (void) composeFrames:(CDVInvokedUrlCommand*) command;


@property (strong, nonatomic) NSString *processFrameCallbackId;
@property (strong, nonatomic) NSString *extractAudioCallbackId;

@property (nonatomic) TTMCaptureManager *sessionManager;
@property (nonatomic) UIView* previewView;
//@property (nonatomic) CameraRenderController *cameraRenderController;

@property (nonatomic) NSString *onPictureTakenHandlerId;
@property (nonatomic) NSString *onVideoCapturedHandlerId;
@property (nonatomic) NSString *onVideoCapturingStartedHandlerId;
@property (nonatomic) CGRect bounds;
@property (nonatomic) float desiredFPS;
@property (nonatomic) NSString* directoryPath;
@property (nonatomic) NSString* fileNamePrefix;
@property (nonatomic) dispatch_queue_t fileWriter;
@end
