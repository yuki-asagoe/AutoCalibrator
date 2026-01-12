classdef DeviceProvider
    methods(Abstract)
        [camera,slm,etl]=setup(obj)
        close(obj,camera,slm,etl)
    end
end