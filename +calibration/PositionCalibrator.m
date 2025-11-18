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
        % もとのプログラムが カメラ画像座標系 -> 光学座標系 の変換を
        % 全部アフィン変換の逆変換で扱う設計になってるっぽい
        % (つまり扱ってるパラメータは 光学座標系 -> カメラ座標系 の変換用パラメータ)
        function saveByCompatibleCSVFormat(obj, filename)
            % 逆演算用パラメータを出力する
            invmatrix=calibration.PositionCalibrator.getInverseTransformParameter(obj.AffineMapMatrix);
            savedMatrix=[invmatrix(1:2,1:2);invmatrix(1:2,3)'];
            csvwrite(filename,savedMatrix);
        end
        
        function saveByCompatibleCSVFormatForNormalPhaseMap(obj, filename, wavelength_um, focallength_um, slmxpixelsize, slmypixelsize, slmxpixelpitch_um, slmypixelpitch_um)
            arguments
                obj
                filename
                wavelength_um
                focallength_um
                slmxpixelsize = 1920
                slmypixelsize = 1200
                slmxpixelpitch_um = 8
                slmypixelpitch_um = 8
            end
            affinematrix = obj.AffineMapMatrix;
            affinematrix(1,:) = affinematrix(1,:) * (slmxpixelsize * slmxpixelpitch_um) / (wavelength_um * focallength_um);
            affinematrix(2,:) = affinematrix(2,:) * (slmypixelsize * slmypixelpitch_um) / (wavelength_um * focallength_um);
            invmatrix=calibration.PositionCalibrator.getInverseTransformParameter(affinematrix);
            savedMatrix=[invmatrix(1:2,1:2);invmatrix(1:2,3)'];
            csvwrite(filename,savedMatrix);
        end

        function [outx,outy] = calibrate(obj,x,y)
            outPos=obj.AffineMapMatrix(:,1:2) * [x;y] + obj.AffineMapMatrix(1:2,3);
            outx=outPos(1);
            outy=outPos(2);
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
            obj = calibration.PositionCalibrator(loadedMatrix);
        end

        % 上述の通りもとのプログラムのパラメータは逆演算なので
        function obj = loadByCompatibleCSVFormatFrom(filename)
            loadedMatrix = importdata(filename);
            reformedMatrix=[loadedMatrix(1:2,1:2),loadedMatrix(3,1:2)'];
            obj= calibration.PositionCalibrator( ...
                calibration.PositionCalibrator.getInverseTransformParameter(reformedMatrix) ...
            );
        end

        % devices.slm.PhaseMap で使用する用に読み込みをします
        % calibration_GUI
        % でえられるパラメータはslmの形状や波長焦点距離みたいなパラメータ全部込みの変換パラメータになっているのであとからそれらを調節できるようにするため逆算して元のパラメータを出さないといけない
        function obj = loadByCompatibleCSVFormatForNormalPhaseMapFrom(filename, wavelength_um, focallength_um, slmxpixelsize, slmypixelsize, slmxpixelpitch_um, slmypixelpitch_um)
            arguments(Input)
                filename
                wavelength_um
                focallength_um
                slmxpixelsize = 1920
                slmypixelsize = 1200
                slmxpixelpitch_um = 8
                slmypixelpitch_um = 8
            end
            loadedMatrix = importdata(filename);
            reformedMatrix = [loadedMatrix(1:2,1:2),loadedMatrix(3,1:2)'];
            affineMatrix = calibration.PositionCalibrator.getInverseTransformParameter(reformedMatrix);
            affineMatrix(1,:) = affineMatrix(1,:) * (wavelength_um * focallength_um) / (slmxpixelsize * slmxpixelpitch_um);
            affineMatrix(2,:) = affineMatrix(2,:) * (wavelength_um * focallength_um) / (slmypixelsize * slmypixelpitch_um);
            obj = calibration.PositionCalibrator(affineMatrix);
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
            affinemapmatrix = zeros(2,3);

            for i = ((1:iterationcount)-1)
                A = [ ...
                    inputpositions(i*3+1,1) inputpositions(i*3+1,2) 1; ...
                    inputpositions(i*3+2,1) inputpositions(i*3+2,2) 1; ...
                    inputpositions(i*3+3,1) inputpositions(i*3+3,2) 1; ...
                ];
                bx = [outputpositions(i*3+1,1); outputpositions(i*3+2,1); outputpositions(i*3+3,1)];
                by = [outputpositions(i*3+1,2); outputpositions(i*3+2,2); outputpositions(i*3+3,2)];
                
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

    methods(Access = private, Static)
        % アフィン変換の逆変換パラメータを計算
        function invtransformparam = getInverseTransformParameter(affinematrix)
            arguments(Input)
                affinematrix (2,3) {mustBeNumeric}
            end
            arguments(Output)
                invtransformparam (2,3) {mustBeNumeric}
            end
            invtransformparam = zeros(2,3);
            % named A, in previous code

            A = affinematrix(1,1);
            B = affinematrix(1,2);
            C = affinematrix(2,1);
            D = affinematrix(2,2);
            tx = affinematrix(1,3);
            ty = affinematrix(2,3);

            % 逆演算用パラメータを出力する
            invtransformparam(1,1) = D/(A*D-B*C);
            invtransformparam(1,2) = B/(B*C-A*D);
            invtransformparam(2,1) = C/(B*C-A*D);
            invtransformparam(2,2) = A/(A*D-B*C);
            invtransformparam(1,3) = -invtransformparam(1,1)*tx-invtransformparam(1,2)*ty;
            invtransformparam(2,3) = -invtransformparam(2,1)*tx-invtransformparam(2,2)*ty;
        end
    end
end