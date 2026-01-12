classdef ETL < handle
    methods(Abstract)
        open(obj)
        close(obj)
        setCurrentRaw(obj,value)
        [minValue,maxValue] = getValueRange(obj)
    end
end