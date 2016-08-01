Cordova CameraPreview Plugin
====================

Cordova plugin that allows camera interaction from HTML code.<br/>
Show camera preview popup on top of the HTML.<br/>

<p><b>Features:</b></p>
<ul>
  <li>Start a camera preview from HTML code.</li>
  <li>Set a custom position for the camera preview box.</li>
  <li>Set a custom size for the preview box.</li>
  <li>Set a custom alpha for the preview box.</li>
  <li>Maintain HTML interactivity.</li>
  <li>Record Video</li>
  <li>Get Frames from Video</li>
</ul>

<p><b>Installation:</b></p>

```
cordova plugin add https://github.com/sami4064/CordovaCameraPreview.git
```


<p><b>Methods:</b></p>


  <b>startCamera(rect, defaultCamera, desiredFps)</b><br/>
  <info>
  	Starts the camera preview instance.
  	<br/>
	<br/>
	


</info>

Javascript:

```
	var rect = {x: 50, y: 50, width: 250, height:500};
        var desiredFps = 60.0;
        cordova.plugins.camerapreview.startCamera(rect, "front",desiredFps);

```

<b>stopCamera()</b><br/>
<info>Stops the camera preview instance.</info><br/>

```

cordova.plugins.camerapreview.stopCamera(stopCameraCallback);
functoin stopCameraCallback(message){
	console.log("message from stop camera call: "+message);
}
```





<b>switchCamera()</b><br/>
<info>Switch from the rear camera and front camera, if available.</info><br/>

```
cordova.plugins.camerapreview.switchCamera();
```

<b>show()</b><br/>
<info>Show the camera preview box.</info><br/>

```
cordova.plugins.camerapreview.show();
```

<b>hide()</b><br/>
<info>Hide the camera preview box.</info><br/>

```
cordova.plugins.camerapreview.hide();
```


<b>startRecording()</b><br/>
<info>Starts the recording of video, before that startCamera() must have been called.</info><br/>

```
var directoryPath="private/var/mobile/Containers/Data/Application/B8731A4E-623B-4345-890B-D0D3C26DFAC6/tmp/";
var uniqueFileNamePrefix="123456abcd"
        
cordova.plugins.camerapreview.startRecording(directoryPath,uniqueFileNamePrefix,startedRecordingCallBack,startRecordingFailedCallBack);


function startRecordingFailedCallBack(message){
        console.log(message);
        console.log("capture video failed");
        }
function startedRecordingCallBack(recordingOnFilePath){
       console.log("capture video start called and returned");
       console.log("file path:" + recordingOnFilePath);
       }
```


<b>stopRecording()</b><br/>
<info>Stops the recording of video, before that startCamera() and startRecording() must have been called.</info><br/>

```

cordova.plugins.camerapreview.stopRecording(getPathResultCallBack,stopRecordingFailedCallback);


function getPathResultCallBack(arr){
        console.log("returned video path = "+arr);
        var fps=30.0;
        cordova.plugins.camerapreview.generateFramesFromVideo(fps,arr,generatingFramesSuccessCallBack,generatingFramesErrorCallBack);
                                     
                                     
        }
                                     
function stopRecordingFailedCallback(message){
        console.log("stop recording said : "+message);
       }

```




<b>generateFramesFromVideo()</b><br/>
<info>Generates frames from mov and mp4 videos.</info><br/>

```
var fps=30.0;
var videoFilePath = [some video file path];
var directoryPath="private/var/mobile/Containers/Data/Application/B8731A4E-623B-4345-890B-D0D3C26DFAC6/tmp/";
var uniqueFileNamePrefix="123456abcd"
var quality = 0.9;
cordova.plugins.camerapreview.generateFramesFromVideo(fps,videoFilePath,directoryPath,uniqueFileNamePrefix,quality,generatingFramesSuccessCallBack,generatingFramesErrorCallBack);
                                     


function generatingFramesErrorCallBack(message){
        console.log("error in generation : "+message);
}

function generatingFramesSuccessCallBack(arr){
        for (i = 0; i < arr.length; i++) {
                console.log("got path : "+arr[i]);
                }
 }

```




<b>Base64 image:</b><br/>
Use the cordova-file in order to read the picture file and them get the base64.<br/>
Please, refer to this documentation: http://docs.phonegap.com/en/edge/cordova_file_file.md.html<br/>
Method <i>readAsDataURL</i>: Read file and return data as a base64-encoded data URL.

<b>Sample:</b><br/>
Please see the <a href="https://github.com/mbppower/CordovaCameraPreviewApp">CordovaCameraPreviewApp</a> for a complete working example for Android and iOS platforms.

<p><b>Android Screenshots:</b></p>
<p><img src="https://raw.githubusercontent.com/mbppower/CordovaCameraPreview/master/docs/img/android-1.png"/></p>
<p><img src="https://raw.githubusercontent.com/mbppower/CordovaCameraPreview/master/docs/img/android-2.png"/></p>
