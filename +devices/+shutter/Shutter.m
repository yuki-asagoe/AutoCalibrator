
classdef Shutter < handle
    methods(Abstract)
        openshutter(obj)
        closeshutter(obj)
        dispose(obj)
    end
end