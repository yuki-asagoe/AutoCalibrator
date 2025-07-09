classdef (Abstract) PhaseSLM < handle
    methods (Abstract)
        open(obj)
        close(obj)
        apply(obj,phasemap)
    end
end