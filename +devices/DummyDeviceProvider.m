classdef DummyDeviceProvider < devices.DeviceProvider

    methods(Access = public)
        function obj = DummyDeviceProvider()
        end

        function [camera,slm,etl]=setup(~)
            camera = devices.DummyDeviceProvider;
            camera.open();
            slm = devices.slm.DummyPhaseSLM;
            slm.open();
            etl = devices.etl.DummyETL;
            etl.open();
        end
        function close(~,camera,slm,etl)
            camera.close();
            slm.close();
            etl.close();
        end
    end
end