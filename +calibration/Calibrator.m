classdef Calibrator
    properties (Access = private)
        Intensity calibration.IntensityWeightMap
        XYPosition calibration.PositionCalibrator
        ZDistance calibration.ZDistanceInfo
    end

    properties (Access = public, Constant)
        FILENAME_POS_CALIBRATOR = "transformer.csv"
        FILENAME_Z_INFORMATION = "depth_information.csv"
        FILENAME_WEIGHT_MAP = "weight_map.csv"
    end

    methods (Access = public)
        function obj = Calibrator(intensitymap,positioncalibrator,zdistanceinfo)
            arguments
                intensitymap calibration.IntensityWeightMap
                positioncalibrator calibration.PositionCalibrator
                zdistanceinfo calibration.ZDistanceInfo
            end
            obj.Intensity=intensitymap;
            obj.XYPosition=positioncalibrator;
            obj.ZDistance=zdistanceinfo;
        end
        function [outx,outy,outz,power] = calibrate(obj,x,y,z)
            [outx,outy]=obj.XYPosition.calibrate(x,y);
            outz=obj.ZDistance.calibrate(z);
            power=obj.Intensity.getWeight(x,y);
        end

        function save(obj,folderpath)
            mkdir(folderpath);

            obj.XYPosition.saveTo(folderpath+"/"+obj.FILENAME_POS_CALIBRATOR);
            writematrix(obj.ZDistance.ZDistance,folderpath+"/"+obj.FILENAME_Z_INFORMATION);
            obj.Intensity.saveTo(folderpath+"/"+obj.FILENAME_WEIGHT_MAP);
        end
    end
    methods (Access = public, Static)
        function obj = load(folderpath)
            arguments(Input)
                folderpath
            end
            if ~exist(folderpath,"dir")
                obj = [];
                return;
            end
            zdist=readmatrix(folderpath+"/"+calibration.Calibrator.FILENAME_Z_INFORMATION);
            zinfo=calibration.ZDistanceInfo(zdist);
            pc=calibration.PositionCalibrator.loadFrom(folderpath+"/"+calibration.Calibrator.FILENAME_POS_CALIBRATOR);
            imap=calibration.IntensityWeightMap.loadFrom(folderpath+"/"+calibration.Calibrator.FILENAME_WEIGHT_MAP);
            obj=calibration.Calibrator(imap,pc,zinfo);
        end
    end
end