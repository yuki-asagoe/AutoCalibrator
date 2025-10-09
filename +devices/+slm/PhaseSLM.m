classdef (Abstract) PhaseSLM < handle
    methods (Abstract)
        open(obj)
        close(obj)
        apply(obj,phasemap)
        [ysize,xsize] = getPixelArraySize(obj)
        pixelpitch_um = getPixelPitch(obj)
    end
end