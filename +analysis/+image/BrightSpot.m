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
            CenterX=centerx;
            CenterY=centery;
            Area=area;
            SumOfPixelValue=pixelsum;
        end
    end
    methods (Access = public, Static)
        function obj = getFromImageAndPixels(grayscaleimage, pixels)
            arguments
                % column 1 is x
                % column 2 is y
                pixels (:,2) integer
            end
            sumvalue=0
            centerx=0;
            centery=0;
            pixelcount=size(pixels,1);
            for i = 1:pixelcount
                x=pixels(i,1);
                y=pixels(i,2);
                value = grayscaleimage(y,x);
                sumvalue+=value;
                centerx+=value*x;
                centery+=value*y;
            end
            centerx/=sumvalue;
            centery/=sumvalue;

            obj = BrightSpot(centerx,centery,pixelcount,sumvalue);
        end
    end
end