classdef Camera
    methods(Abstract)
        open(obj)
        image = take(obj)
        close(obj)
    end
end