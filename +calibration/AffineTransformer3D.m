classdef AffineTransformer3D < handle
    % 複数スポットを異なるz平面に置くとかzスキャンとかいろいろやるなら
    % 最初から三次元アフィン変換使えばいいのではとなったテスト

    properties(Access=private)
        AffineMatrix (3,4) {mustBeNumeric}
    end

    methods(Access=private,Static)
        function obj = AffineTransformer3D(affinematrix)
            arguments(Input)
                affinematrix (3,4) {mustBeNumeric}
            end
            obj.AffineMatrix = affinematrix;
        end
    end
    methods(Access=public,Static)
        function obj = adjust(points,respondpoints)
            arguments(Input)
                % [x1,y1,z1;
                % x2,y2,z2;
                % x3,y3,z3;
                % x4,y4,z4]みたいになる
                points (4,3) {mustBeNumeric}
                respondpoints (4,3) {mustBeNumeric}
            end
            B = respondpoints(:);
            A = zeros(12,12);
            for i = 1:3
                for j = 1:4
                    A((i-1)*4+j,(1:3)+(i-1)*3)=points(j,:);
                    A((i-1)*4+j,9+i)=1;
                end
            end
            params=linsolve(A,B);
            % params は今こうなってるはず
            % nx=[A B C] [x] + tx
            % ny=[D E F]*[y] + ty 
            % nz=[G H Q] [z] + tz
            % にたいして
            % params == [A B C D E F G H Q tx ty tz]
            obj = calibration.AffineTransformer3D([ ...
                params(1:3),params(10); ...
                params(4:6),params(11); ...
                params(7:9),params(12) ...
            ]);
        end
        function obj=loadFrom(filename)
            obj=calibration.AffineTransformer3D(readmatrix(filename));
        end
    end
    methods(Access=public)
        function transformed=transform(obj,points)
            arguments(Input)
                obj
                points (:,3) {mustBeNumeric}
            end
            arguments(Output)
                transformed (:,3) {mustBeNumeric}
            end
            transformedpoints=obj.AffineMatrix*[points';ones(1,size(points,1))];
            transformed=transformedpoints';
        end
        function saveTo(obj,filename)
            writematrix(obj.AffineMatrix,filename);
        end
    end
end