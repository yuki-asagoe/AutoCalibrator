classdef BrightSpotScore
    enumeration
        % 画素値の総和
        ValueSum
        % 画素値と中心からの距離に基づく正規化ガウス関数(正規分布みたいなものに相当)の相関和
        NormalizedGaussianCorrelation
        % 画素値と中心からの距離に基づくガウス関数(正規化係数なし)の相関和
        ScaledGaussianCorrelation
        % 画素値と中心からの距離の積の総和
        InverseDistanceWeight
        % 画素値と中心からの距離の二乗の積の総和
        SquaredInverseDistanceWeight
    end
    methods (Access = public)
        function spot = getBrightSpot(obj,image,pixelLinearIdxList)
            arguments (Input)
                obj
                image (:,:) {mustBeNumeric}
                pixelLinearIdxList {mustBeInteger}
            end
            arguments(Output)
                spot analysis.image.BrightSpot
            end
            [pixelsY,pixelsX]=ind2sub(size(image),pixelLinearIdxList);
            values=image(pixelLinearIdxList);
            sumvalue=sum(values);
            centerx=dot(pixelsX,double(values))/sumvalue - 1;
            centery=dot(pixelsY,double(values))/sumvalue - 1;
            score = 0;
            switch obj
                case analysis.image.BrightSpotScore.ValueSum
                    score = sumvalue;
                case analysis.image.BrightSpotScore.NormalizedGaussianCorrelation
                    relativeX=pixelsX-centerx;
                    relativeY=pixelsY-centery;
                    radius=max([3,max(relativeX)-min(relativeX),max(relativeY)-min(relativeY)]);
                    score=sum(exp(-(relativeX.^2+relativeY.^2)/(2*(radius/2)^2)))/radius;
                case analysis.image.BrightSpotScore.ScaledGaussianCorrelation
                    relativeX=pixelsX-centerx;
                    relativeY=pixelsY-centery;
                    radius=max([3,max(relativeX)-min(relativeX),max(relativeY)-min(relativeY)]);
                    score=sum(exp(-(relativeX.^2+relativeY.^2)/(2*(radius/2)^2)));
                case analysis.image.BrightSpotScore.InverseDistanceWeight
                    score = dot((centerx.^2 + centery.^2)^(-1/2),values);
                case analysis.image.BrightSpotScore.SquaredInverseDistanceWeight
                    score = dot((centerx.^2 + centery.^2)^(-1),values);
            end
            spot = analysis.image.BrightSpot(centerx,centery,length(pixelLinearIdxList),sumvalue,obj,score);
        end
    end
end