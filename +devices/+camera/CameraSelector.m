classdef CameraSelector < handle
    properties (Access = public)
        DeviceAdaptor string
        DeviceID {mustBeInteger}
        DeviceFormat string
    end
    properties (Access = private, Constant = true)
        AvailableFormatsDictionary = dictionary( ...
            ['hamamatsu'],...
            [['MONO16_BIN4x4_512x512_Std']]...
        )
    end

    methods (Access = public)
        function obj = CameraSelector
            
        end
        
        % Return currently available deviceadaptors
        % must be vector of string
        function availableadaptors = getAvailableAdaptors(~)
            availableadaptors=imaqhwinfo().InstalledAdaptors;
        end

        % Return available device ids for current DeviceAdaptor
        % Return empty list if current DeviceAdaptor is invalid
        function availableids = getAvailableIDs(obj)
            if isempty(obj.DeviceAdaptor)
                availableids=[];
                return
            end
            info = imaqhwinfo(obj.DeviceAdaptor);
            if isfield(info,'DeviceIDs')
                availableids = info.DeviceIDs;
            else
                availableids = [];
            end
        end

        % Return available formats for current DeciceAdaptor
        % Return empty list if current DeviceAdaptor is invalid
        function availableformats = getAvailableFormats(obj)
            if isKey(obj.AvailableFormatsDictionary, obj.DeviceAdaptor)
                availableformats = obj.AvailableFormatsDictionary(obj.DeviceAdaptor);
            else
                availableformats = [];
            end
        end

        function valid = isValid(obj)
            valid = any(obj.getAvailableAdaptors == obj.DeviceAdaptor) & any(obj.getAvailableIDs == obj.DeviceID) & any(obj.getAvailableFormats == obj.DeviceFormat);
        end
        
        % Return videoinput instance
        % if not isValid, return empty list
        function videoin = getVideoInput(obj)
            if(obj.isValid)
                videoin=videoinput(obj.DeviceAdaptor,obj.DeviceID,obj.DeviceFormat);
            else
                videoin = [];
            end
        end
    end
end