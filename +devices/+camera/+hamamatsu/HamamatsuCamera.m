classdef HamamatsuCamera < devices.camera.Camera
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
            if obj.IsOpened
                return;
            end
            imaqreset
            obj.VideoInputDevice = videoinput("hamamatsu",obj.DeviceID,"MONO8_2304x2304_Std");
            obj.SelectedSource = getselectedsource(obj.VideoInputDevice);

            obj.SelectedSource.TriggerSource = "INTERNAL";
            obj.SelectedSource.TriggerMode = "NORMAL";
            obj.SelectedSource.TriggerPolarity = "POSITIVE";
            obj.SelectedSource.TriggerActive = "EDGE";
            obj.SelectedSource.HotPixelCorrectionLevel = "STANDARD";
            obj.SelectedSource.ExposureTime = obj.ExposureTime;

            triggerconfig(obj.VideoInputDevice,"immediate");
            obj.VideoInputDevice.FramesPerTrigger = 1;
            obj.VideoInputDevice.TriggerRepeat = Inf;

            obj.IsOpened = true;

            start(obj.VideoInputDevice);
        end

        function imageSize = getImageSize(obj)
            imageSize = [2304,2304];
        end

        function close(obj)
            if ~obj.IsOpened
                return;
            end
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
            
            image = peekdata(obj.VideoInputDevice,1);
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