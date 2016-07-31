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
CameraPreview.startCamera = function(rect, defaultCamera, desiredFps) {
    if (typeof(alpha) === 'undefined') alpha = 1;
    exec(null, null, PLUGIN_NAME, "startCamera", [rect.x, rect.y, rect.width, rect.height, defaultCamera, desiredFps]);
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

CameraPreview.generateFramesFromVideo = function(fps,video,frameGeneratedCallBack,frameGenerationFailedCallback) {
    exec(frameGeneratedCallBack, frameGenerationFailedCallback, PLUGIN_NAME, "generateFramesFromVideo", [video,fps]);
}
;
module.exports = CameraPreview;
