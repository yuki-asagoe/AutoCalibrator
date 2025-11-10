classdef ReadMode < int8
    enumeration
        FullVerticalBinning (0)
        MultiTrack (1)
        RandomTrack (2)
        SingleTrack (3)
        Image (4)
    end
    methods(Access = public)
        function code=get(obj)
            code = double(int8(obj));
        end
        function set(obj)
            SetReadMode(obj.get);
        end
    end
end

