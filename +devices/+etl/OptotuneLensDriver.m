classdef OptotuneLensDriver
    properties(Access = private)
        SerialportName
        Serialport
        Messages string
        IncompleteMessage string
        CRC math.crc.CRC16
    end

    methods(Access = public)
        function obj = OptotuneLensDriver(serialportname)
            obj.SerialportName = serialportname;
            obj.Serialport = [];
            obj.Messages = [];
            obj.IncompleteMessage = "";
            obj.CRC=math.crc.CRC16(0xA001,0);
        end

        function open(obj)
            obj.Serialport = serialport(obj.SerialportName,115200,"Timeout",0.5);
            write(obj.Serialport,uint8('Start'),"uint8");
            response=read(obj.Serialport,7,"uint8");
            if response ~= uint8('Ready\r\n')
                error('Error : Response from serialport device is not what expected');
                return;
            end
            configureTerminator(obj.Serialport,"CR/LF");
            configureCallback(obj.Serialport,"terminator",@(src,evt) obj.onMessageReceived(src,evt));
        end

        function setCurrent(obj,value)
            arguments(Input)
                obj
                value % in [-4096,4096)
            end
            write( ...
                obj.Serialport, ...
                appendCRCToMessage([ ...
                    uint8('Aw'), ...
                    uint8([bitand(bitsrl(value,8),0xFF),bitand(value,0xFF)]) ...
                ]), ...
                "uint8" ...
            );
        end

        function close(obj)
            delete(obj.Serialport);
            obj.Serialport=[];
        end
        
        function messages=getMessages(obj)
            messages=obj.Messages;
            obj.Messages=[];
        end
    end

    methods(Access = private)
        function onMessageReceived(obj,srcserialport,event)
            message=append(obj.IncompleteMessage,read(srcserialport,srcserialport.NumBytesAvailable,"uint8"));
            splitMessages=split(message,"\r\n");
            obj.IncompleteMessage = splitMessages(end);
            obj.Messages=[obj.Messages,splitMessages];
        end

        function crcmessage=appendCRCToMessage(obj,message)
            arguments(Input)
                obj
                message (1,:) uint8
            end
            arguments(Output)
                crcmessage (1,:) uint8
            end
            crc=obj.CRC.calculate(message);
            crcmessage = [message, uint8([bitand(crc,0xFF), bitand(bitsrl(crc,8),0xFF)])];
        end
    end
end