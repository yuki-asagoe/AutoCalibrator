% About position calibration for difference of coordinates at camera and spotting focal plane
% Used for adjust spot positions given as one on camera coordinate, to
% actual position
classdef PositionCalibrator
    properties (Access = private)
        % (A B tx)
        % (C D ty)
        % Intended to be used as below
        % (new_x) = (A B) (x) + (tx)
        % (new_y) = (C D) (y) + (ty)
        AffineMapMatrix (2,3) {mustBeNumeric}
    end

    methods (Access = public)
        function obj = PositionCalibrator(affinemapmatrix)
            arguments
                affinemapmatrix (2,3) {mustBeNumeric}
            end
            obj.AffineMapMatrix=affinemapmatrix;
        end

        function saveTo(obj, filename)
            writematrix(obj.AffineMapMatrix, filename)
        end

        % Save in csv fomat that has been used by previous code : calibrationGUI
        function saveInCompatibleCSVFormat(obj, filename)
            savedMatrix = zeros(3,2);
            % named A, in previous code
            savedMatrix(1,1) = obj.AffineMapMatrix(1,1);
            savedMatrix(1,2) = obj.AffineMapMatrix(1,2);
            savedMatrix(2,1) = obj.AffineMapMatrix(2,1);
            savedMatrix(2,2) = obj.AffineMapMatrix(2,2);
            savedMatrix(3,1) = obj.AffineMapMatrix(1,3);
            savedMatrix(3,2) = obj.AffineMapMatrix(2,3);
            csvwrite(filename,savedMatrix)
        end

        function [outx,outy] = calibrate(obj,x,y)
            outPos=obj.AffineMapMatrix(1:2,1:2) * [x;y] + obj.AffineMapMatrix(1:2,3);
            outx=outPos(1,1);
            outy=outPos(2,1);
        end
    end

    methods (Access = public, Static)
        function obj = loadFrom(filename)
            loadedMatrix= importdata(filename);
            obj = PositionCalibrator(loadedMatrix);
        end

        function obj = loadInCompatibleCSVFormatFrom(filename)
            loadedMatrix = importdata(filename);
            obj= PositionCalibrator([ ...
                loadedMatrix(1,1) loadedMatrix(1,2) loadedMatrix(3,1); ...
                loadedMatrix(2,1) loadedMatrix(2,2) loadedMatrix(3,2) ...
            ]);
        end
    end

end