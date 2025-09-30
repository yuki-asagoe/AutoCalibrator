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
                data (1,:) uint8
            end
            arguments(Output)
                crc uint16
            end
            value=obj.InitialValue;
            for i = 1:size(data)
                value=bitxor(value,data(i));
                for j=1:8
                    if bitand(value,1) == 1
                        value=bitxor(bitsrl(value,1),obj.ReversePolynomial);
                    else
                        value=bitsrl(value,1);
                    end
                end
            end
            crc=value;
        end
    end
end