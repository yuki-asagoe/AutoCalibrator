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
            % いわゆる有名角の三角形 (90°/60°/30°)
            trianglepoints = [ ...
                0 0; ...
                1 0; ...
                0 sqrt(3) ...
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
            expectedSpots = trianglepoints;
            detectedSpots = [brightspots.CenterX; brightspots.CenterY]';
            if length(brightspots) < 3
                calibrator = calibration.PositionCalibrator.empty;
                return;
            end

            % 各点の角度のcos値から元の三角形との対応を推論
            cosValues=zeros(3,1);
            for i=1:3
                normalizedVectors = zeros(2,2);
                for j=1:2
                    targetIndex=[];
                    if j >= i
                        targetIndex = j+1;
                    else
                        targetIndex = j;
                    end
                    diffVec=detectedSpots(targetIndex,:) - detectedSpots(i,:);
                    normalizedVectors(j,:)=diffVec / norm(diffVec);
                end
                cosValues(i)=dot(normalizedVectors(1,:),normalizedVectors(1,:));
            end
            [~,I] = sort(cosValues);


            respondPointsInImage=detectedSpots(I,:);

            calibrator= calibration.PositionCalibrator.adjust(respondPointsInImage,trianglepoints);
        end

        function [calibrator,image,detectedSpots,expectedSpots] = tryByTriangleWithProvisionalCalibrator(obj,provisionalCalibrator,rotationAngle_rad)
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
            trianglepoints = (rotMat * (trianglepoints'))';
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
            respondpoints=analysis.image.estimateRespondPointPairs(trianglepoints,detectedSpots);

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