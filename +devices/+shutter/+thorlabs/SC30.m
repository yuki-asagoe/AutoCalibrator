classdef SC30 < devices.shutter.Shutter
    properties(Access = private)
        Disposed logical
        SdkLocation string
        DeviceHandle
        ParamHandles dictionary
    end
    methods(Access = private)
        function assertNotDisposed(obj)
            if obj.Disposed
                error("This device is already disposed");
            end
        end

        function paramHandle = getParameterhandle(obj, paramName)
            arguments(Input)
                obj
                paramName string
            end
            if ~isKey(obj.ParamHandles,paramName)
                paramNameAtChar = convertStringsToChars(paramName);
                paramHandle = calllib(obj.SdkLocation,"GetParameterHandle",obj.DeviceHandle,paramNameAtChar);
                obj.ParamHandles(paramName) = paramHandle;
            else
                paramHandle = obj.ParamHandles(paramName);
            end
        end
    end

    methods(Access = public)
        function obj = ThorlabShutter(sdk_header_location)
            obj.Disposed = false;
            obj.SdkLocation = sdk_header_location;
            obj.ParamHandles = dictionary();
            if(not libisloaded(obj.SdkLocation))
                loadlibrary(obj.SdkLocation);
            end
            calllib(obj.SdkLocation,"OpenPluginManager");

            obj.DeviceHandle = devices.util.thorlabs.finddevice(obj.SdkLocation,0x100E,0x1313); % These are product and vender id of sc30
            if isempty(obj.DeviceHandle)
                error("Could not find installed SC30 device");
            end
            if calllib(obj.SdkLocation,"OpenDevice") == int32(false)
                error("Could not open loaded SC30 device");
            end
        end

        % .openshutter() -> open shutter of channel 1
        % .openshutter(channel_number) -> open shutter of given channel (1 or 2)
        function openshutter(obj,varargin)
            channel = int32(1);
            if length(varargin) >= 1
                channel = int32(varargin{1});
            end
            obj.setshutter(channel,true);
        end

        function closeshutter(obj,varargin)
            channel = int32(1);
            if length(varargin) >= 1
                channel = int32(varargin{1});
            end
            obj.setshutter(channel,false);
        end

        function setshutter(obj,channel,open)
            obj.assertNotDisposed();
            arguments(Input)
                obj
                channel int32
                open logical
            end
            if ~any([1,2] == channel)
                error(sprintf("This channel[%d] is not supported",channel));
            end
            param = obj.getParameterhandle("enable_channel");
            value = zeros(1,"uint8")
            value(0) = open;
            pOfValue = libpointer('voidPtr',value);
            % channel is enum originally, but pass as int here.
            calllib(obj.SdkLocation,"SetParameterValueToDevice",obj.DeviceHandle,param,channel,pOfValue,1);
            clear pOfValue
        end

        function dispose(obj)
            if obj.Disposed
                return;
            end
            calllib(obj.SdkLocation,"CloseDevice",obj.DeviceHandle);
            obj.Disposed = true;
        end

        function delete(obj)
            obj.dispose();
        end
    end
end