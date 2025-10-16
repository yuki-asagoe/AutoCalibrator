classdef AcquisitionMode < uint8
    enumeration
        SingleScan (1)
        Accumulate (2)
        Kinetics (3)
        FastKinetics (4)
        RunTillAbort (5)
    end
    methods(Access = public)
        function code=get(obj)
            code = uint8(obj);
        end
        function set(obj)
            SetAcquisitionMode(obj.get);
        end
    end
end

