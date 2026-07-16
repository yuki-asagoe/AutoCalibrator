classdef DCAMCamera < devices.camera.Camera
    properties(Access = private)
        IsOpened logical
        IsClosed logical
        LibName char
        HeaderName char
        DeviceIndex {mustBeInteger}
    end

    methods
        function obj = DCAMCamera(lib_name,header_name,device_index)
            arguments(Input)
                lib_name char
                header_name char
            end
            obj.LibName = lib_name;
            obj.HeaderName = header_name;
            obj.DeviceIndex = device_index;
        end

        function open(obj)
            if ~libisloaded(obj.LibName)
                loadlibrary(obj.LibName);

                dcamapi_init_struct.size = 4*4 + 8*2; % コンパイラがアライメントしなければこうなるはず... たぶんしなくても済む配置だけど ていうかなんでこんなパラメータが...?
                dcamapi_init_struct.initoptionbytes = 0;
                dcamapi_init_cstruct=libstruct('DCAMAPI_INIT',dcamapi_init_struct);

                calllib(obj.LibName,'dcamapi_init',dcamapi_init_cstruct);
                calllib(obj.LibName,'dcamapi_open',)
            end


        end

        function image=take(obj)
        end

        function imageSize = getImageSize(obj)
        end
        
        function close(obj)
            calllib(obj.LibName,'dcamapi_uninit')
            unloadlibrary(obj.LibName);
        end

        function delete(obj)
            obj.close();
        end
    end
end