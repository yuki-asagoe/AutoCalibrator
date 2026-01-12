classdef DummyETL < devices.etl.ETL
    methods(Access = public)
        function open(~)
        end
        function close(~)
        end
        function setCurrentRaw(~,value)
            disp("DummyETL-set : " + string(value));
        end
        function [minValue,maxValue] = getValueRange(~)
            minValue=0;
            maxValue=1023;
        end
    end
end