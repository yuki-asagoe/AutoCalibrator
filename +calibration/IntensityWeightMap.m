classdef IntensityWeightMap
    properties (Access = public)
        WeightMap {mustBeNumeric}
    end

    methods (Access = public)
        function obj = IntensityWeightMap(weightmap)
            arguments
                weightmap {mustBeNumeric}
            end
            obj.WeightMap=weightmap
        end

        function saveTo(obj, filename)
            writematrix(obj.WeightMap, filename)
        end

        % Save in csv fomat that has been used by previous code : calibrationGUI
        function saveInCompatibleCSVFormat(obj, filename)
            csvwrite(filename,obj.WeightMap)
        end
    end

    methods (Access = public, Static)
        function obj = loadFrom(filename)
            obj = IntensityWeightMap(importdata(filename))
        end

        function obj = loadInCompatibleCSVFormatFrom(obj,filename)
            obj = loadFrom(filename)
        end
    end
end
