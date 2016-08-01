//
//  TTMCaptureManager.h
//  SlowMotionVideoRecorder
//  https://github.com/shu223/SlowMotionVideoRecorder
//
//  Created by shuichi on 12/17/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@import CoreMedia;


typedef NS_ENUM(NSUInteger, CameraType) {
    CameraTypeBack,
    CameraTypeFront,
};

typedef NS_ENUM(NSUInteger, OutputMode) {
    OutputModeVideoData,
    OutputModeMovieFile,
};


@protocol TTMCaptureManagerDelegate <NSObject>
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                                      error:(NSError *)error;
@end


@interface TTMCaptureManager : NSObject

@property (nonatomic, assign) id<TTMCaptureManagerDelegate> delegate;
@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, copy) void (^onBuffer)(CMSampleBufferRef sampleBuffer);
@property (nonatomic,assign) int screenShotCount;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) AVCaptureDeviceFormat *defaultFormat;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
// for video data output
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic,assign)  AVCaptureDevicePosition defaultCamera;

- (instancetype)initWithPreviewView:(UIView *)previewView
                preferredCameraType:(CameraType)cameraType
                         outputMode:(OutputMode)outputMode
                      previewBounds:(CGRect)bounds;
- (void)toggleContentsGravity;
- (void)resetFormat;
- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS;
- (void)startRecordingInDirectory:(NSString*)directoryPath AndFilePrefix:(NSString*)prefix;
- (void)stopRecording;
- (void)updateOrientationWithPreviewView:(UIView *)previewView;
- (void) switchCamera;

@end
