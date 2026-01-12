classdef DummyCamera < devices.camera.Camera
    methods(Access = public)
        function obj = DummyCamera()
        end
        function open(~)
        end
        function image = take(~)
            pause(0.2);
            image = rand(512);
            disp("DummyCamera-take");
        end
        function imageSize = getImageSize(~)
            imageSize = [512,512];
        end
        function close(~)
        end
    end
end