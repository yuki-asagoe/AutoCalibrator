classdef AffineTransformTester < handle
    properties(Access = private)
        Camera devices.camera.Camera = devices.camera.DummyCamera
        Slm devices.slm.PhaseSLM = devices.slm.DummyPhaseSLM
        SpotX_um {mustBeNumeric}
        SpotY_um {mustBeNumeric}
        SpotZ_um {mustBeNumeric}
        FocalLength_um {mustBeNumeric}
        WaveLength_nm {mustBeNumeric}
        PattenScale
    end

    methods(Access = public)
        function obj = AffineTransformTester(camera, slm, spotx_um, spoty_um, spotz_um, focallength_um, wavelength_nm,patternscale)
            arguments(Input)
                camera devices.camera.Camera
                slm devices.slm.PhaseSLM
                spotx_um {mustBeNumeric}
                spoty_um {mustBeNumeric}
                spotz_um {mustBeNumeric}
                focallength_um {mustBeNumeric}
                wavelength_nm {mustBeNumeric}
                patternscale {mustBeNumeric}
            end
            obj.Camera = camera;
            obj.Slm = slm;
            obj.SpotX_um = spotx_um;
            obj.SpotY_um = spoty_um;
            obj.SpotZ_um = spotz_um;
            obj.FocalLength_um = focallength_um;
            obj.WaveLength_nm = wavelength_nm;
            obj.PattenScale = patternscale;
        end

        function [calibrator,image,detectedSpots,expectedSpots]=tryByTriangle(obj)
            arguments(Output)
                calibrator calibration.PositionCalibrator
                image
                detectedSpots (:,2) {mustBeNumeric}
                expectedSpots (:,2) {mustBeNumeric}
            end
            [ypixelcount,xpixelcount]=obj.Slm.getPixelArraySize();
            pixelpitch_um=obj.Slm.getPixelPitch();
    
            centerpoints=[obj.SpotX_um,obj.SpotY_um];
            trianglepoints = [ ...
                1 0; ...
                0 -1; ...
                -1 0 ...
            ];
            trianglepoints = trianglepoints * obj.PattenScale + centerpoints;
            phasemap = devices.slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um,obj.FocalLength_um,obj.WaveLength_nm);
            for i =1:size(trianglepoints,1)
                point=trianglepoints(i,:);
                phasemap.addSpot(point(1),point(2),calibration.ZDistanceInfo(0).calibrate(0),1);
            end
            phasearray=phasemap.getPhaseArray();
            obj.Slm.apply(phasearray);
            pause(0.05);

            image = obj.Camera.take();
            if size(image,3) == 3
                image= rgb2gray(image);
            end
            brightspots = analysis.image.getbrightspots(image,3);
            if length(brightspots) < 3
                calibrator = calibration.PositionCalibrator.empty;
                detectedSpots = [];
                expectedSpots = [];
                return;
            end
            expectedSpots = trianglepoints;
            detectedSpots = [brightspots.CenterX; brightspots.CenterY]';
            [farestpoint1index,farestpoint2index] = analysis.geometry.searchfarestpair(detectedSpots);
            % 直角三角形の直角部分の頂点の添え字
            lastpointindex=[1 2 3];
            lastpointindex([farestpoint1index,farestpoint2index]) = [];
            % このままだと最遠点として検出された点がどっちがどっちかわからないので外積の符号で判定する
            basecrossproduct=math.cross2d(trianglepoints(3,:)-trianglepoints(1,:),trianglepoints(2,:)-trianglepoints(1,:));
            % 注意点としてmatlabでは画像の下方向がY軸正方向になるので軸をそろえるために外積符号は反転する
            % 入力の二点のY座標を反転して外積をとるのとその外積自体の符号を反転するのは同値のはず
            inimagepointscrossproduct = - math.cross2d(detectedSpots(farestpoint2index,:)-detectedSpots(farestpoint1index),detectedSpots(lastpointindex)-detectedSpots(farestpoint1index));
            if sign(basecrossproduct) ~= sign(inimagepointscrossproduct)
                temp = farestpoint1index;
                farestpoint1index=farestpoint2index;
                farestpoint2index=temp;
            end

            trianglepointsinresultimage=[detectedSpots(farestpoint1index,:);detectedSpots(lastpointindex,:);detectedSpots(farestpoint2index,:)];

            calibrator= calibration.PositionCalibrator.adjust(trianglepointsinresultimage,trianglepoints);
        end

        function [calibrator,image,detectedSpots,expectedSpots] = tryByTriangleWithProvisionalCalibrator(obj,provisionalCalibrator)
            arguments(Input)
                obj calibration.AffineTransformTester
                provisionalCalibrator calibration.PositionCalibrator
                rotationAngle_rad {mustBeNumeric} = 2 * pi * rand()
            end
            arguments(Output)
                calibrator calibration.PositionCalibrator
                image
                detectedSpots (:,2) {mustBeNumeric}
                expectedSpots (:,2) {mustBeNumeric}
            end
            [ypixelcount,xpixelcount]=obj.Slm.getPixelArraySize();
            pixelpitch_um=obj.Slm.getPixelPitch();
            imageSize=obj.Camera.getImageSize();
            ysize=imageSize(1);
            xsize=imageSize(2);
            centerpoints = [xsize/2,ysize/2];
            patternscale = min([xsize,ysize])*0.3;
            trianglepoints = [ ...
                0 1; ...
                -sqrt(3)/2 -0.5; ...
                sqrt(3)/2 -0.5 ...
            ];
            rotMat=[cos(rotationAngle_rad), -sin(rotationAngle_rad);sin(rotationAngle_rad), cos(rotationAngle_rad)];
            trianglepoints = ((trianglepoints') * rotMat)';
            trianglepoints = trianglepoints * patternscale + centerpoints;

            phasemap = devices.slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um,obj.FocalLength_um,obj.WaveLength_nm);
            actualpoints=provisionalCalibrator.calibratePointArray(trianglepoints);
            for i =1:size(actualpoints,1)
                phasemap.addSpot(actualpoints(i,1),actualpoints(i,2),calibration.ZDistanceInfo(0).calibrate(0),1);
            end
            phasearray=phasemap.getPhaseArray();
            obj.Slm.apply(phasearray);
            pause(0.05);

            image = obj.Camera.take();
            if size(image,3) == 3
                image= rgb2gray(image);
            end
            brightspots = analysis.image.getbrightspots(image,3);
            if length(brightspots) < 3
                calibrator = calibration.PositionCalibrator.empty;
                expectedSpots = [];
                detectedSpots = [];
                return;
            end
            expectedSpots=trianglepoints;
            detectedSpots=[brightspots.CenterX;brightspots.CenterY]';
            respondpoints=analysis.image.estimateRespondPointPairs(hexagonpoints,detectedSpots);

            calibrator=calibration.PositionCalibrator.adjust(respondpoints,actualpoints);
        end
        
        function [calibrator,image,detectedSpots,expectedSpots] = tryByHexagon(obj,provisionalCalibrator)
            arguments(Input)
                obj calibration.AffineTransformTester
                provisionalCalibrator calibration.PositionCalibrator
            end
            arguments(Output)
                calibrator calibration.PositionCalibrator
                image
                detectedSpots (:,2) {mustBeNumeric}
                expectedSpots (:,2) {mustBeNumeric}
            end

            [ypixelcount,xpixelcount]=obj.Slm.getPixelArraySize();
            pixelpitch_um=obj.Slm.getPixelPitch();
            imageSize=obj.Camera.getImageSize();
            ysize=imageSize(1);
            xsize=imageSize(2);
            centerpoints = [xsize/2,ysize/2];
            patternscale = min([xsize,ysize])*0.3;
            hexagonpoints = [ ...
                0 1; ...
                -sqrt(3)/2 -0.5; ...
                sqrt(3)/2 -0.5; ...
                0 -1; ...
                -sqrt(3)/2 0.5; ...
                sqrt(3)/2 0.5 ...
            ];
            hexagonpoints = hexagonpoints * patternscale + centerpoints;
            phasemap = devices.slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um,obj.FocalLength_um,obj.WaveLength_nm);
            actualpoints=provisionalCalibrator.calibratePointArray(hexagonpoints);
            for i =1:size(actualpoints,1)
                phasemap.addSpot(actualpoints(i,1),actualpoints(i,2),calibration.ZDistanceInfo(0).calibrate(0),1);
            end
            phasearray=phasemap.getPhaseArray();
            obj.Slm.apply(phasearray);
            pause(0.05);

            image = obj.Camera.take();
            if size(image,3) == 3
                image= rgb2gray(image);
            end
            brightspots = analysis.image.getbrightspots(image,6);
            if length(brightspots) < 6
                calibrator = calibration.PositionCalibrator.empty;
                expectedSpots = [];
                detectedSpots = [];
                return;
            end
            expectedSpots=hexagonpoints;
            detectedSpots=[brightspots.CenterX;brightspots.CenterY]';
            respondpoints=analysis.image.estimateRespondPointPairs(hexagonpoints,detectedSpots);

            calibrator=calibration.PositionCalibrator.adjust(respondpoints,actualpoints);
        end
    end
end