% About z distance to target plane offset from normal forcal plane of the
% optical system
classdef ZDistanceInfo < handle
    properties (Access = public)
        % Unit : [μm]
        ZDistance double
    end

    methods
        function obj = ZDistanceInfo(zDistanceToTargetPlaneFromFocalPlane_um)
            ZDistance = zDistanceToTargetPlaneFromFocalPlane_um
        end

        function zpos = calibrate(obj,z_um)
            zpos=obj.ZDistance+z_um
        end
    end
end