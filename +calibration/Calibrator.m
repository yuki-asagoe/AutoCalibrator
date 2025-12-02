classdef Calibrator
    properties (Access = private)
        Intensity calibration.IntensityWeightMap
        XZPosition calibration.PositionCalibrator
        ZDistance calibration.ZDistanceInfo
    end

    methods (Access = public)
        function obj = Calibrator(intensitymap,positioncalibrator,zdistanceinfo)
            arguments
                intensitymap calibration.IntensityWeightMap
                positioncalibrator calibration.PositionCalibrator
                zdistanceinfo calibration.ZDistanceInfo
            end
            obj.Intensity=intensitymap;
            obj.XZPosition=positioncalibrator;
            obj.ZDistance=zdistanceinfo;
        end
        function [outx,outy,outz,power] = calibrate(obj,x,y,z)
            [outx,outy]=obj.XZPosition.calibrate(x,y);
            outz=obj.ZDistance.calibrate(z);
            power=obj.Intensity.getWeight(x,y);
        end
    end
end