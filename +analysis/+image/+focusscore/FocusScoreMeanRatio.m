classdef FocusScoreMeanRatio < analysis.image.focusscore.IFocusScore
    methods(Access = public)
        function obj = FocusScoreMeanRatio()
        end

        function value = calculate(obj,image)
            averagefilter=fspecial("average",3);
            filteredimg=rescale(imfilter(image,averagefilter));
            thresh=adaptthresh(filteredimg, 0.01,'Statistic','gaussian');
            binaryimg=imbinarize(filteredimg,thresh);

            if ~any(binaryimg,"all")
                focusScore = 0;
                return;
            end

            focusScore=mean(image(binaryimg),"all")/mean(image(~binaryimg),"all");
        end
    end
end