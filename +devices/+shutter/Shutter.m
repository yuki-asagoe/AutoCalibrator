
classdef Shutter < handle
    methods(Abstract)
        openShutter(obj)
        closeShutter(obj)
        dispose(obj)
    end
end