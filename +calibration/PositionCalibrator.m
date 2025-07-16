% About position calibration for difference of coordinates at camera images and spotting focal plane
% Used for adjust spot positions given as one on camera coordinate, to
% actual position
classdef PositionCalibrator < handle
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
        %
        % もとのプログラムがなぜか カメラ画像座標系 -> 光学座標系 の変換を
        % 全部アフィン変換の逆変換で扱う設計になってるっぽいから
        % 逆演算用パラメータを出力しなければいけません
        function saveInCompatibleCSVFormat(obj, filename)
            savedMatrix = zeros(3,2);
            % 今は逆変換パラメータを出力していない
            % named A, in previous code
            savedMatrix(1,1) = obj.AffineMapMatrix(1,1);
            savedMatrix(1,2) = obj.AffineMapMatrix(1,2);
            savedMatrix(2,1) = obj.AffineMapMatrix(2,1);
            savedMatrix(2,2) = obj.AffineMapMatrix(2,2);
            savedMatrix(3,1) = obj.AffineMapMatrix(1,3);
            savedMatrix(3,2) = obj.AffineMapMatrix(2,3);
            csvwrite(filename,savedMatrix);
        end

        function [outx,outy] = calibrate(obj,x,y)
            outPos=obj.AffineMapMatrix(1:2,1:2) * [x;y] + obj.AffineMapMatrix(1:2,3);
            outx=outPos(1,1);
            outy=outPos(2,1);
        end

        function calibrated = calibratePointArray(obj, points)
            arguments (Input)
                obj
                points (:,2) {mustBeNumeric}
            end
            arguments(Output)
                calibrated (:,2) {mustBeNumeric}
            end
            calibrated = zeros(size(points));
            for i = 1:size(points,1)
                [outx,outy] = obj.calibrate(points(i,1),points(i,2));
                calibrated(i,:)=[outx outy];
            end
        end

    end

    methods (Access = public, Static)
        function obj = loadFrom(filename)
            loadedMatrix= importdata(filename);
            obj = PositionCalibrator(loadedMatrix);
        end

        % 上述の通りもとのプログラムのパラメータは逆演算なので
        function obj = loadInCompatibleCSVFormatFrom(filename)
            loadedMatrix = importdata(filename);
            obj= PositionCalibrator([ ...
                loadedMatrix(1,1) loadedMatrix(1,2) loadedMatrix(3,1); ...
                loadedMatrix(2,1) loadedMatrix(2,2) loadedMatrix(3,2) ...
            ]);
        end

        function obj=adjust(inputpositions,outputpositions)
            arguments
                % Each number of rows should be multiple of 3
                % Column 1 is x
                % Column 2 is y
                inputpositions (:,2)
                outputpositions (:,2)
            end
            numberofposition = size(inputpositions,1);
            iterationcount=numberofposition/3;
            affinemapmatrix = zeros(2,3,iterationcount);

            for i = 1:iterationcount
                A = [ ...
                    inputpositions(i*3,1) inputpositions(i*3,2) 1; ...
                    inputpositions(i*3+1,1) inputpositions(i*3+1,2) 1; ...
                    inputpositions(i*3+2,1) inputpositions(i*3+2,2) 1; ...
                ];
                bx = [outputpositions(i*3,1); outputpositions(i*3+1,1); outputpositions(i*3+2,1)];
                by = [outputpositions(i*3,2); outputpositions(i*3+1,2); outputpositions(i*3+2,2)];
                
                xrowcoefficients=linsolve(A,bx);
                yrowcoefficients=linsolve(A,by);

                affinemapmatrix(1,:) = affinemapmatrix(1,:) + xrowcoefficients';
                affinemapmatrix(2,:) = affinemapmatrix(2,:) + yrowcoefficients';
            end
            
            % calculate as average
            affinemapmatrix = affinemapmatrix / iterationcount;

            obj= calibration.PositionCalibrator(affinemapmatrix);
        end
    end

end