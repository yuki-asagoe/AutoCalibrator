classdef TriggerMode < uint8
    enumeration
        Internal (0)
        External (1)
        ExternalStart(6)
        ExternalExposure (7)
        Externa_FVB_EM (9)
        ExternalChargeShifting (12)
    end
    methods(Access = public)
        function code=get(obj)
            code = uint8(obj);
        end
        function set(obj)
            SetTriggerMode(obj.get);
        end
    end
end

