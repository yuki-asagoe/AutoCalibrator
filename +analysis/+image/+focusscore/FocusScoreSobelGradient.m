classdef FocusScoreSobelGradient < analysis.image.focusscore.IFocusScore
    methods(Access = public)
        function obj = FocusScoreSobelGradient()
        end

        function value = calculate(obj,image)
            ysobel=fspecial("sobel");
            xsobel=ysobel';
            xsobelimg=imfilter(image,xsobel);
            ysobleimg=imfilter(image,ysobel);
            value=mean(sqrt(xsobelimg.^2+ysobleimg.^2),"all");
        end
    end
end