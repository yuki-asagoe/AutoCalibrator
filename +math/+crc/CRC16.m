classdef CRC16
    properties(Access = private)
        ReversePolynomial uint16
        InitialValue uint16
    end

    methods(Access = public)
        function obj = CRC16(reversePolynomial,initialValue)
            obj.ReversePolynomial=reversePolynomial;
            obj.InitialValue=initialValue;
        end
    
        function crc= calculate(obj,data)
            arguments(Input)
                obj
                data (1,:) uint8
            end
            arguments(Output)
                crc uint16
            end
            value=obj.InitialValue;
            for i = 1:size(data,2)
                value=bitxor(value,uint16(data(i)));
                for j=1:8
                    if bitand(value,1) == 1
                        value=bitxor(bitshift(value,-1),obj.ReversePolynomial);
                    else
                        value=bitshift(value,-1);
                    end
                end
            end
            crc=value;
        end
    end
end