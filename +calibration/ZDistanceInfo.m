% About z distance to target plane offset from normal forcal plane of the
% optical system
classdef ZDistanceInfo < handle
    properties (Access = public)
        % Unit : [μm]
        ZDistance double
    end

    methods
        function obj = ZDistanceInfo()
        end
    end
end