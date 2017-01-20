var argscheck = require('cordova/argscheck'),
utils = require('cordova/utils'),
exec = require('cordova/exec');

var PLUGIN_NAME = "CameraPreview";

var CameraPreview = function() {};

CameraPreview.setOnPictureTakenHandler = function(onPictureTaken) {
    exec(onPictureTaken, onPictureTaken, PLUGIN_NAME, "setOnPictureTakenHandler", []);
};

//@param rect {x: 0, y: 0, width: 100, height:100}
//@param defaultCamera "front" | "back"
CameraPreview.startCamera = function(defaultCamera, desiredFps) {
    if (typeof(alpha) === 'undefined') alpha = 1;
    exec(null, null, PLUGIN_NAME, "startCamera", [defaultCamera, desiredFps]);
};
CameraPreview.stopCamera = function(stopHandler) {
    exec(stopHandler, stopHandler, PLUGIN_NAME, "stopCamera", []);
};
//@param size {maxWidth: 100, maxHeight:100}
CameraPreview.startRecording = function(directoryPath,uniqueFileNamePrefix,startRecordingSuccessCallback,startRecordingFailedCallback) {
    exec(startRecordingSuccessCallback, startRecordingFailedCallback, PLUGIN_NAME, "startRecording", [directoryPath,uniqueFileNamePrefix]);
};

CameraPreview.stopRecording = function(stopRecordingHandler,stopRecordingFailedCallback) {
    exec(stopRecordingHandler, stopRecordingFailedCallback, PLUGIN_NAME, "stopRecording", []);
};

CameraPreview.getFacing = function(cameraFacingCallback,cameraFacingErrorCallback) {
    exec(cameraFacingCallback, cameraFacingErrorCallback, PLUGIN_NAME, "getFacing", []);
};


CameraPreview.switchCamera = function() {
    exec(null, null, PLUGIN_NAME, "switchCamera", []);
};

CameraPreview.hide = function() {
    exec(null, null, PLUGIN_NAME, "hideCamera", []);
};

CameraPreview.show = function() {
    exec(null, null, PLUGIN_NAME, "showCamera", []);
};

CameraPreview.setFlashLight = function(flashBool) {
    exec(null, null, PLUGIN_NAME, "setFlashLight", [flashBool]);
};

CameraPreview.setTorchLight = function(torchBool) {
    exec(null, null, PLUGIN_NAME, "setTorchLight", [torchBool]);
};

CameraPreview.disable = function(disable) {
    exec(null, null, PLUGIN_NAME, "disable", [disable]);
};

CameraPreview.generateFramesFromVideo = function(fps,video,directoryPath,uniqueFileNamePrefix,quality,width,frameGeneratedCallBack,frameGenerationFailedCallback) {
    exec(frameGeneratedCallBack, frameGenerationFailedCallback, PLUGIN_NAME, "generateFramesFromVideo", [video,fps,directoryPath,uniqueFileNamePrefix,quality,width]);
};

CameraPreview.processFramesFromVideo1 = function(fps,video,directoryPath,uniqueFileNamePrefix,quality,width,frameGeneratedCallBack,frameGenerationFailedCallback) {
 exec(frameGeneratedCallBack, frameGenerationFailedCallback, PLUGIN_NAME, "processFramesFromVideo1", [video,fps,directoryPath,uniqueFileNamePrefix,quality,width]);
};

CameraPreview.processFramesFromVideo2 = function(fps,video,directoryPath,uniqueFileNamePrefix,quality,width,frameGeneratedCallBack,frameGenerationFailedCallback) {
 exec(frameGeneratedCallBack, frameGenerationFailedCallback, PLUGIN_NAME, "processFramesFromVideo2", [video,fps,directoryPath,uniqueFileNamePrefix,quality,width]);
};

CameraPreview.extractAudio = function(videoPath, outputPath,successCallback,failCallback) {
 exec(successCallback, failCallback, PLUGIN_NAME, "extractAudio", [videoPath,outputPath]);
};

CameraPreview.composeFrames = function(frames, audioPath,outputPath,successCallback,failCallback) {
 exec(successCallback, failCallback, PLUGIN_NAME, "composeFrames", [frames,audioPath, outputPath]);
};


module.exports = CameraPreview;
