classdef HamamatsuCamera < devices.camera.Camera
    properties(Access = private)
        AdaptorDllName char
        DeviceID {mustBeInteger}
        VideoInputDevice
        SelectedSource
        IsOpened logical
        IsClosed logical
    end

    methods(Access = public)
        function obj = HamamatsuCamera(deviceID)
            arguments(Input)
                deviceID {mustBeInteger}
            end
            hwinfo = imaqhwinfo("hamamatsu");
            obj.AdaptorDllName = hwinfo.AdaptorDllName;
            obj.DeviceID = deviceID;
            obj.VideoInputDevice = [];
            obj.SelectedSource = [];
            obj.IsOpened = false;
            obj.IsClosed = false;
        end

        function open(obj)
            if obj.IsOpened
                return;
            end
            imaqreset
            obj.VideoInputDevice = videoinput("hamamatsu",obj.DeviceID);
            obj.SelectedSource = getselectedsource(obj.VideoInputDevice);

            obj.VideoInputDevice.FramesPerTrigger = 1;
            triggerconfig(obj.VideoInputDevice,"immediate");
            obj.SelectedSource.TriggerSource = "internal";

            obj.IsOpened = true;
            start(obj.VideoInputDevice);
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
            obj.VideoInputDevice = [];
            obj.SelectedSource = [];
            obj.IsClosed = true;
        end

        function image = take(obj)
            image = getdata(obj.VideoInputDevice,obj.VideoInputDevice.FramesAvailable);
        end

        function delete(obj)
            obj.close();
        end
    end
end