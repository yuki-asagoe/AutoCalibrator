classdef FocusScoreLaplacian < IFocusScore
    methods(Access - public)
        function obj = FocusScoreLaplacian()
        end

        function value = calculate(obj,image)
            filt=fspecial("laplacian",0);
            laplacian=imfilter(image,filt);
            value = var(laplacian,1,"all");
        end
    end
end