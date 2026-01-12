classdef WeightMapScanner

    properties(Access = private)
        Camera devices.camera.Camera = devices.camera.DummyCamera
        Slm devices.slm.PhaseSLM = devices.slm.DummyPhaseSLM
        Calibrator calibration.PositionCalibrator
        FocalLength_um {mustBeNumeric}
        WaveLength_nm {mustBeNumeric}
        GridSize {mustBeInteger}
        Margin {mustBeNumeric}
        ImageHeight {mustBeNumeric}
        ImageWidth {mustBeNumeric}
        SLMXPixelCount {mustBeInteger}
        SLMYPixelCount {mustBeInteger}
        SLMPixelPitch_um {mustBeNumeric}
        ZShift {mustBeNumeric}
        IterationCount {mustBeInteger} = 0
        IntensityMap {mustBeNumeric}
    end

    methods(Access = public)
        function obj = WeightMapScanner(camera, slm, calibrator, focallength_um, wavelength_nm,gridsize,margin,zshift)
            arguments(Input)
                camera devices.camera.Camera
                slm devices.slm.PhaseSLM
                calibrator calibration.PositionCalibrator
                focallength_um {mustBeNumeric}
                wavelength_nm {mustBeNumeric}
                gridsize {mustBeInteger} = 21
                margin {mustBeNumeric} = 0
                zshift {mustBeNumeric} = 0
            end
            obj.Camera = camera;
            obj.Slm = slm;
            obj.Calibrator = calibrator;
            obj.FocalLength_um = focallength_um;
            obj.WaveLength_nm = wavelength_nm;
            obj.GridSize = gridsize;
            imageSize=obj.Camera.getImageSize();
            [obj.SLMYPixelCount,obj.SLMXPixelCount]=slm.getPixelArraySize();
            SLMPixelPitch_um=slm.getPixelPitch();
            obj.ImageHeight=imageSize(1);
            obj.ImageWidth=imageSize(2);
            obj.Margin = margin;
            obj.ZShift = zshift;
            obj.IntensityMap = zeros(obj.GridSize);
        end

        function [hasNext,image] = next(obj)
            if obj.GridSize * obj.GridSize <= obj.IterationCount
                hasNext = false;
                image = [];
                return;
            end
            obj.IterationCount = obj.IterationCount + 1;
            hasNext = obj.GridSize * obj.GridSize > obj.IterationCount;
            gridy = ceil(obj.IterationCount/obj.GridSize);
            gridx = mod(obj.IterationCount-1,obj.GridSize)+1;

            gridWidth=(obj.ImageWidth-obj.Margin*2)/obj.GridSize;
            gridHeight=(obj.ImageHeight-obj.Margin*2)/obj.GridSize;
            gridStartY=obj.Margin+gridHeight*(gridy-1);
            gridCenterY = gridStartY+gridHeight*0.5;
            gridStartX=obj.Margin+gridWidth*(gridx-1);
            gridCenterX = gridStartX+gridWidth*0.5;
            phasemap = devices.slm.PhaseMap(obj.SLMXPixelCount,obj.SLMYPixelCount,obj.SLMPixelPitch_um,obj.SLMPixelPitch_um, obj.FocalLength_um, obj.WaveLength_nm);
            [opticalx, opticaly]=positioncalibrator.calibrate(gridCenterX,gridCenterY);
            phasemap.addSpot(opticalx,opticaly,obj.ZShift,1);

            slm.apply(phasemap.getPhaseArray);

            pause(0.05);

            image = camera.take();
            if size(image,3) == 3
                image = rgb2gray(image);
            end
            averagefilter=fspecial("average",3);
            filteredimg=imfilter(image,averagefilter);
            obj.IntensityMap(gridy,gridx)=max([max(filteredimg(round(gridStartY):round(gridStartY+gridHeight) , round(gridStartX):round(gridStartX+gridWidth)),[],"all"),0]);
        end

        function weightmap = getWeightMap(obj)
            arguments(Output)
                weightmap calibration.IntensityWeightMap
            end
            maxscale=5;
            intensitymap = obj.IntensityMap;
            intensitymap(intensitymap < 0.01) = 0.01;
            normalizedintensity = intensitymap / max(intensitymap,[],"all");
            normalizedintensity(normalizedintensity < (1/maxscale)) = (1/maxscale);
            correctionweights= 1./normalizedintensity;
            weightmap = calibration.IntensityWeightMap( ...
                correctionweights, ...
                obj.Margin, ...
                obj.Margin, ...
                obj.ImageWidth-obj.Margin, ...
                obj.ImageHeight-obj.Margin ...
            );
        end
    end
end