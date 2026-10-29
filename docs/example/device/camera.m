% Examples of camera devices
% These classes are designed to acquistion single images, not video
% sequence
% I have to add video classes?

%% devices.camera.hamamatsu.HamamatsuCamera
% This class needs Image Acquistion Toolbox and Hamamatsu Camera Adaptor
% This feature might not work in Matlab 2026+

% If device id is 1 (call `imaqhwinfo 'hamamatsu'` to check device id)
% and exposure time is 0.05 seconds, initialization should be like follwing
hCamera = devices.camera.hamamatsu.HamamatsuCamera(1,0.05);

% let the camera connection start
hCamera.open();
% or with explicit format
hCamera.openWithFormat("MONO16_2048x2048_Std");

% get image size in [width height]
size = hCamera.getImageSize();
% change exposere time in milli seconds unit
hCamera.setExposureTime(0.02);

% get single picture
img = hCamera.take();

% close connection
hCamera.close();

%% devices.camera.andor.AndorCamera
% This need Andor camera matlab binding
aCamera = devices.camera.andor.AndorCamera();

% start connection
aCamera.open();

% set exposure time in milli seconds unit
aCamera.setExposureTime(0.02);
% enable/disable cooler
aCamera.enableCooler(true);
% set gain [0,255]
aCamera.setEMCCDGain(127);

% get single picture
img = aCamera.take();

% close connection
aCamera.close();