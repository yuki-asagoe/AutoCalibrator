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
        function obj = getFromImageAndPixels(grayscaleimage, pixels)
            arguments
                grayscaleimage (:,:) {mustBeNumeric}
                % column 1 is x
                % column 2 is y
                pixels (:,2) {mustBeInteger}
            end
            sumvalue=0;
            centerx=0;
            centery=0;
            pixelcount=size(pixels,1);
            for i = 1:pixelcount
                x=pixels(i,1);
                y=pixels(i,2);
                value = grayscaleimage(y,x);
                sumvalue=sumavalue+value;
                centerx=centerx+value*x;
                centery=centery+value*y;
            end
            centerx=centerx/sumvalue;
            centery=centery/sumvalue;

            obj = BrightSpot(centerx,centery,pixelcount,sumvalue);
        end
    end
end