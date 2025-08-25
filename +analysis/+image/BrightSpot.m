classdef BrightSpot
    properties (Access = public)
        CenterX
        CenterY
        % Unit [pixel^2]
        Area
        SumOfPixelValue
    end

    methods (Access = public)
        function obj = BrightSpot(centerx,centery,area,pixelsum)
            obj.CenterX=centerx;
            obj.CenterY=centery;
            obj.Area=area;
            obj.SumOfPixelValue=pixelsum;
        end
    end
    methods (Access = public, Static)
        function obj = getFromImageAndPixels(grayscaleimage, pixelsLinearIdx)
            % 効率の都合で線形インデクスを使った方法に直したが添え字を使う実装もした方がいいか
            arguments(Input)
                grayscaleimage (:,:) {mustBeNumeric}
                pixelsLinearIdx (:,1) {mustBeInteger}
            end
            [pixelsY,pixelsX]=ind2sub(size(grayscaleimage),pixelsLinearIdx);
            pixelcount=size(pixelsLinearIdx,2);
            values=grayscaleimage(pixelsLinearIdx);
            sumvalue=sum(values);
            centerx=dot(pixelsX,double(values))/sumvalue;
            centery=dot(pixelsY,double(values))/sumvalue;

            obj = analysis.image.BrightSpot(centerx,centery,pixelcount,sumvalue);
        end
    end
end