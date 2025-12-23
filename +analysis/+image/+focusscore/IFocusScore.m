classdef IFocusScore
    methods(Abstract)
        value=calculate(obj,image)
    end
end