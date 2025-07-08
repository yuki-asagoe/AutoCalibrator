classdef (Abstract) PhaseSLM < handle
    methods (Abstract)
        function open(obj)
        function close(obj)
        function apply(obj,phasemap)
    end
end