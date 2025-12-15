classdef FocusScoreSobelAndVariance < IFocusScore
    methods(Access = public)
        function obj = FocusScoreSobelAndVariance()
        end

        function value = calculate(obj,image)
            ysobel=fspecial("sobel");
            xsobel=ysobel';
            xsobelimg=imfilter(image,xsobel);
            ysobleimg=imfilter(image,ysobel);
            sobelMagnitude=mean(sqrt(xsobelimg.^2+ysobleimg.^2),"all");
            value = sobelMagnitude + var(image,1,"all");
        end
    end
end