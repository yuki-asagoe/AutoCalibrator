classdef Mode < int8
    enumeration
       Manual(0)
       External(1)
       Internal(2)
       Triggered(3)
    end

    methods(Access = public)
        function prefix = toCommandPrefix(obj)
            value = int8(obj);
            if value == 0
                prefix = 'man';
            elseif value == 1
                prefix = 'ext';
            elseif value == 2
                prefix = 'int';
            elseif value == 3
                prefix = 'trig';
            else
                error('This line should be unreachable');
            end
        end
    end
end

