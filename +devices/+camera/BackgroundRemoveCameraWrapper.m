% 内部の camera インスタンスは take メソッドについて常に同じサイズのデータを返さなければいけません。
classdef BackgroundRemoveCameraWrapper < devices.camera.Camera
    properties (Access = private)
        InnerCamera
        BackgroundScale {mustBeNumeric}
        Background (:,:) {mustBeNumeric}
    end

    methods
        function obj = BackgroundRemoveCameraWrapper(camera,backgroundScale)
            arguments(Input)
                camera devices.camera.Camera
                backgroundScale {mustBeNumeric} = 0.8
            end
            obj.InnerCamera = camera;
            obj.Background = 0;
            obj.BackgroundScale = backgroundScale;
        end

        function open(obj)
            obj.InnerCamera.open();
        end
        function close(obj)
            obj.InnerCamera.close();
        end
        function image=take(obj)
            image = obj.InnerCamera.take() - obj.Background * obj.BackgroundScale;
        end

        function updateBackground(obj)
            background = obj.InnerCamera.take();
            for i = 1:4
                background = background + obj.InnerCamera.take();
            end
            obj.Background = background / 5;
        end
    end
end