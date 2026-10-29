classdef HamamatsuCamera < devices.camera.Camera
    %% Available Formats
    % 'MONO12_2048x2048_Std'
    % 'MONO12_2048x2048_UltraQuiet'
    % 'MONO12_BIN2x2_1024x1024_Std'
    % 'MONO12_BIN2x2_1024x1024_UltraQuiet'
    % 'MONO12_BIN2x2_DualLightSheet Mode_Std'
    % 'MONO12_BIN2x2_DualLightSheet Mode_UltraQuiet'
    % 'MONO12_BIN2x2_SplitView Mode_Std'
    % 'MONO12_BIN2x2_SplitView Mode_UltraQuiet'
    % 'MONO12_BIN4x4_512x512_Std'
    % 'MONO12_BIN4x4_512x512_UltraQuiet'
    % 'MONO12_BIN4x4_DualLightSheet Mode_Std'
    % 'MONO12_BIN4x4_DualLightSheet Mode_UltraQuiet'
    % 'MONO12_BIN4x4_SplitView Mode_Std'
    % 'MONO12_BIN4x4_SplitView Mode_UltraQuiet'
    % 'MONO12_DualLightSheet Mode_Std'
    % 'MONO12_DualLightSheet Mode_UltraQuiet'
    % 'MONO12_LightSheet Mode_Std'
    % 'MONO12_LightSheet Mode_UltraQuiet'
    % 'MONO12_SplitView Mode_Std'
    % 'MONO12_SplitView Mode_UltraQuiet'
    % 'MONO16_2048x2048_Std'
    % 'MONO16_2048x2048_UltraQuiet' 
    % 'MONO16_BIN2x2_1024x1024_Std'
    % 'MONO16_BIN2x2_1024x1024_UltraQuiet'
    % 'MONO16_BIN2x2_DualLightSheet Mode_Std'
    % 'MONO16_BIN2x2_DualLightSheet Mode_UltraQuiet'
    % 'MONO16_BIN2x2_SplitView Mode_Std'
    % 'MONO16_BIN2x2_SplitView Mode_UltraQuiet'
    % 'MONO16_BIN4x4_512x512_Std'
    % 'MONO16_BIN4x4_512x512_UltraQuiet'
    % 'MONO16_BIN4x4_DualLightSheet Mode_Std'
    % 'MONO16_BIN4x4_DualLightSheet Mode_UltraQuiet'
    % 'MONO16_BIN4x4_SplitView Mode_Std'
    % 'MONO16_BIN4x4_SplitView Mode_UltraQuiet'
    % 'MONO16_DualLightSheet Mode_Std'
    % 'MONO16_DualLightSheet Mode_UltraQuiet'
    % 'MONO16_LightSheet Mode_Std' 
    % 'MONO16_LightSheet Mode_UltraQuiet'
    % 'MONO16_SplitView Mode_Std'
    % 'MONO16_SplitView Mode_UltraQuiet'
    % 'MONO8_2048x2048_Std'
    % 'MONO8_2048x2048_UltraQuiet'
    % 'MONO8_BIN2x2_1024x1024_Std'
    % 'MONO8_BIN2x2_1024x1024_UltraQuiet'
    % 'MONO8_BIN2x2_DualLightSheet Mode_Std'
    % 'MONO8_BIN2x2_DualLightSheet Mode_UltraQuiet'
    % 'MONO8_BIN2x2_SplitView Mode_Std'
    % 'MONO8_BIN2x2_SplitView Mode_UltraQuiet'
    % 'MONO8_BIN4x4_512x512_Std'
    % 'MONO8_BIN4x4_512x512_UltraQuiet'
    % 'MONO8_BIN4x4_DualLightSheet Mode_Std'
    % 'MONO8_BIN4x4_DualLightSheet Mode_UltraQuiet'
    % 'MONO8_BIN4x4_SplitView Mode_Std'
    % 'MONO8_BIN4x4_SplitView Mode_UltraQuiet'
    % 'MONO8_DualLightSheet Mode_Std'
    % 'MONO8_DualLightSheet Mode_UltraQuiet'
    % 'MONO8_LightSheet Mode_Std'
    % 'MONO8_LightSheet Mode_UltraQuiet'
    % 'MONO8_SplitView Mode_Std'
    % 'MONO8_SplitView Mode_UltraQuiet'
    %%
    properties(Access = private)
        DeviceID {mustBeInteger}
        VideoInputDevice
        SelectedSource
        IsOpened logical
        IsClosed logical
        ExposureTime
    end

    methods(Access = public)
        function obj = HamamatsuCamera(deviceID,exposure)
            arguments(Input)
                deviceID {mustBeInteger}
                exposure
            end
            obj.DeviceID = deviceID;
            obj.VideoInputDevice = [];
            obj.SelectedSource = [];
            obj.IsOpened = false;
            obj.IsClosed = false;
            obj.ExposureTime = exposure;
        end

        function open(obj)
            obj.openWithFormat("MONO16_2048x2048_Std");
        end

        function openWithFormat(obj,format)
            if obj.IsOpened
                return;
            end
            obj.VideoInputDevice = videoinput("hamamatsu",obj.DeviceID,format);
            obj.SelectedSource = getselectedsource(obj.VideoInputDevice);

            obj.SelectedSource.TriggerSource = "INTERNAL";
            obj.SelectedSource.TriggerMode = "NORMAL";
            obj.SelectedSource.TriggerPolarity = "POSITIVE";
            obj.SelectedSource.TriggerActive = "EDGE";
            obj.SelectedSource.HotPixelCorrectionLevel = "STANDARD";
            obj.SelectedSource.ExposureTime = obj.ExposureTime;

            triggerconfig(obj.VideoInputDevice,"manual");
            obj.VideoInputDevice.FramesPerTrigger = 1;
            obj.VideoInputDevice.TriggerRepeat = Inf;

            obj.IsOpened = true;

            start(obj.VideoInputDevice);
        end

        function imageSize = getImageSize(obj)
            imageSize = obj.VideoInputDevice.VideoResolution;
        end

        function close(obj)
            if obj.IsClosed
                return;
            end
            stop(obj.VideoInputDevice);
            imaqreset
            delete(obj.VideoInputDevice);
            obj.VideoInputDevice = [];
            obj.SelectedSource = [];
            obj.IsClosed = true;
        end

        function image = take(obj)
            image = [];
            if ~obj.IsOpened
                warning("This camera is not opened yet");
                return;
            end
            if obj.IsClosed
                warning("This camera is already closed");
                return;
            end
            trigger(obj.VideoInputDevice);
            image = getdata(obj.VideoInputDevice,1);
        end

        function setExposureTime(obj, time_sec)
            if obj.IsClosed
                return;
            end
            if obj.IsOpened
                stop(obj.VideoInputDevice);
            end
            obj.ExposureTime = time_sec;
            obj.SelectedSource.ExposureTime = time_sec;
            if obj.IsOpened
                start(obj.VideoInputDevice);
            end
        end

        function delete(obj)
            obj.close();
        end
    end
end