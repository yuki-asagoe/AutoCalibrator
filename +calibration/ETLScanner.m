classdef ETLScanner < handle
    properties(Access = private)
        Camera devices.camera.Camera = devices.camera.DummyCamera
        Slm devices.slm.PhaseSLM = devices.slm.DummyPhaseSLM
        Etl devices.etl.ETL = devices.etl.DummyETL
        SpotX_um {mustBeNumeric}
        SpotY_um {mustBeNumeric}
        SpotZ_um {mustBeNumeric}
        FocalLength_um {mustBeNumeric}
        WaveLength_nm {mustBeNumeric}
        ScannedETLRawValues {mustBeNumeric}
        IterationCount {mustBeInteger}
        Scores double
        CurrentMaxScore double
        PhaseMap devices.slm.PhaseMap
        ImageProvidingMaxScore = []
    end

    methods(Access = public)
        function obj = ETLScanner(camera, slm, etl, spotx_um, spoty_um, spotz_um, focallength_um, wavelength_nm, scannedetlrawvalues)
            arguments(Input)
                camera devices.camera.Camera
                slm devices.slm.PhaseSLM
                etl devices.etl.ETL
                spotx_um {mustBeNumeric}
                spoty_um {mustBeNumeric}
                spotz_um {mustBeNumeric}
                focallength_um {mustBeNumeric}
                wavelength_nm {mustBeNumeric}
                scannedetlrawvalues {mustBeNumeric} = []
            end
            obj.Camera = camera;
            obj.Slm = slm;
            obj.Etl = etl;
            obj.SpotX_um = spotx_um;
            obj.SpotY_um = spoty_um;
            obj.SpotZ_um = spotz_um;
            obj.FocalLength_um = focallength_um;
            obj.WaveLength_nm = wavelength_nm;
            if isempty(scannedetlrawvalues)
                [minValue,maxValue] = etl.getValueRange();
                scannedetlrawvalues = linspace(minValue,maxValue,32);
            end

            obj.ScannedETLRawValues = scannedetlrawvalues;
            obj.Scores = zeros([1,length(scannedetlrawvalues)]);
            obj.IterationCount = 0;
            obj.CurrentMaxScore = -Inf;
            [slmsizeY,slmsizeX]=slm.getPixelArraySize();
            slmpixelpitch_um=slm.getPixelPitch();
            obj.PhaseMap=devices.slm.PhaseMap(slmsizeX,slmsizeY,slmpixelpitch_um,slmpixelpitch_um,focallength_um,wavelength_nm);
            obj.PhaseMap.addSpot(spotx_um,spoty_um,spotz_um);
            slm.apply(obj.PhaseMap.getPhaseArray);
        end
        function scores = getCurrentScores(obj)
            scores = obj.Scores;
        end
        function [hasNext,image] = next(obj,resetPhaseMap)
            arguments(Input)
                obj calibration.ETLScanner
                resetPhaseMap logical = false
            end
            arguments(Output)
                hasNext logical
                image (:,:) {mustBeNumeric}
            end
            if length(obj.ScannedETLRawValues) <= obj.IterationCount
                hasNext = false;
                image = [];
                return;
            end
            obj.IterationCount = obj.IterationCount + 1;
            hasNext = length(obj.ScannedETLRawValues) > obj.IterationCount;
            if resetPhaseMap
                obj.Slm.apply(obj.PhaseMap.getPhaseArray);
            end

            value=obj.ScannedETLRawValues(obj.IterationCount);
            obj.Etl.setCurrentRaw(value);
            pause(0.05);

            image = obj.Camera.take();
            score = analysis.image.getFocusScore_WeightedSobel(image);
            obj.Scores(obj.IterationCount)=score;
            if score > obj.CurrentMaxScore
                obj.CurrentMaxScore = score;
                obj.ImageProvidingMaxScore = image;
            end
        end
        function etlvalue = getResult(obj)
            [~,I] = max(obj.Scores);
            etlvalue = obj.ScannedETLRawValues(I);
        end
    end
end