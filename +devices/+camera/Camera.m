classdef Camera < handle
    methods(Abstract)
        open(obj)
        image = take(obj)
        imageSize = getImageSize(obj)
        close(obj)
    end
end