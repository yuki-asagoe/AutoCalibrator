classdef DummyPhaseSLM < devices.slm.PhaseSLM

    methods(Access = public)
        function obj = DummyPhaseSLM()
        end
        function open(~)
        end
        function close(~)
        end
        function apply(~,~)
            disp("DymmyPhaseSLM-apply");
        end
        function [ysize,xsize] = getPixelArraySize(~)
            xsize=1920;
            ysize=1200;
        end
        function pixelpitch_um = getPixelPitch(~)
            pixelpitch_um = 8;
        end
    end
end