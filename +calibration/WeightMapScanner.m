classdef WeightMapScanner

    properties(Access = private)
        Camera devices.camera.Camera
        Slm devices.slm.PhaseSLM
        Calibrator calibration.PositionCalibrator
        FocalLength_um {mustBeNumeric}
        WaveLength_nm {mustBeNumeric}
        GridSize {mustBeInteger}
        Margin {mustBeNumeric}
        IterationCount {mustBeInteger} = 0
    end

    methods(Access = public)
        function obj = WeightMapScanner(camera, slm, calibrator, focallength_um, wavelength_nm,gridsize,margin)
            arguments(Input)
                camera devices.camera.Camera
                slm devices.slm.PhaseSLM
                calibrator calibration.PositionCalibrator
                focallength_um {mustBeNumeric}
                wavelength_nm {mustBeNumeric}
                gridsize {mustBeInteger} = 21
                margin {mustBeNumeric} = 0
            end
            obj.Camera = camera;
            obj.Slm = slm;
            obj.Calibrator = calibrator;
            obj.FocalLength_um = focallength_um;
            obj.WaveLength_nm = wavelength_nm;
            obj.GridSize = gridsize;
            obj.Margin = margin;
        end

        function [hasNext,image] = next(obj)
            if length(obj.GridSize * obj.GridSize) <= obj.IterationCount
                hasNext = false;
                image = [];
                return;
            end
            obj.IterationCount = obj.IterationCount + 1;
            hasNext = length(obj.GridSize * obj.GridSize) <= obj.IterationCount;
        end

        function weightmap = getWeightMap(obj)
            arguments(Output)
                weightmap calibration.IntensityWeightMap
            end
        end
    end
end