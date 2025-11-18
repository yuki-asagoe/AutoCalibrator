classdef ImageFlipCameraWrapper < devices.camera.Camera
    properties
        InnerCamera
        VerticalFlip
        HorizotalFlip
    end

    methods
        function obj = ImageFlipCameraWrapper(camera,verticalflip,horizontalflip)
            arguments
                camera devices.camera.Camera
                verticalflip logical
                horizontalflip logical
            end
            obj.InnerCamera = camera;
            obj.VerticalFlip = verticalflip;
            obj.HorizotalFlip = horizontalflip;
        end

        function open(obj)
            obj.InnerCamera.open();
        end
        function close(obj)
            obj.InnerCamera.close();
        end
        function image=take(obj)
            image = obj.InnerCamera.take();
            if obj.VerticalFlip
                image=flip(image,1);
            end
            if obj.HorizotalFlip
                image=flip(image,2);
            end
        end
    end
end
