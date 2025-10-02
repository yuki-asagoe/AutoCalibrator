% スレッドセーフではないのでマルチスレッド環境で呼ぶのは勘弁
classdef OptotuneLensDriver < handle
    properties(Access = private)
        IsOpen logical
        IsClosed logical
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
            obj.IsOpen=false;
            obj.IsClosed=false;
        end

        function open(obj)
            if obj.IsOpen
                return;
            end
            if obj.IsClosed
                error('Error : This lens driver is already closed. Please recreate new instance');
            end
            obj.Serialport = serialport(obj.SerialportName,115200,"Timeout",0.5);
            write(obj.Serialport,uint8('Start'),"uint8");
            response=read(obj.Serialport,7,"uint8");
            if response ~= uint8(sprintf('Ready\r\n'))
                obj.close();
                error('Error : Response from serialport device is not what expected');
            end
            obj.registerCallback();
            obj.IsOpen=true;
        end

        function setCurrentRaw(obj,value)
            arguments(Input)
                obj
                value int16 % in [-4096,4096)
            end
            if ~obj.IsOpen
                return;
            end
            value = int16(value);
            write( ...
                obj.Serialport, ...
                obj.appendCRCToMessage([ ...
                    uint8('Aw'), ...
                    uint8([ ...
                        bitand(typecast(bitshift(value,-8),'uint16'),0x00FF), ...
                        bitand(typecast(value,'uint16'),0x00FF) ...
                    ]) ...
                ]), ...
                "uint8" ...
            );
        end

        function setFocalPowerRaw(obj,value)
            arguments(Input)
                obj
                value int16
            end
            if ~obj.IsOpen
                return;
            end
            write( ...
                obj.Serialport, ...
                obj.appendCRCToMessage([ ...
                    uint8('PwDA'), ...
                    uint8([ ...
                        bitand(typecast(bitshift(value,-8),'uint16'),0x00FF), ...
                        bitand(typecast(value,'uint16'),0x00FF) ...
                    ]) ...
                ]), ...
                "uint8" ...
            );
        end

        function active=isActive(obj)
            active=obj.IsOpen;
        end

        function close(obj)
            if ~obj.IsOpen
                return;
            end
            delete(obj.Serialport);
            obj.Serialport=[];
            obj.IsOpen=false;
            obj.IsClosed=true;
        end
        
        function messages=getMessages(obj)
            messages=obj.Messages;
            obj.Messages=[];
        end
        
        function delete(obj)
            obj.close();
        end
    end

    methods(Access = private)
        function registerCallback(obj)
            configureTerminator(obj.Serialport,"CR/LF");
            configureCallback(obj.Serialport,"terminator",@(src,evt) obj.onMessageReceived(src,evt));
        end

        function onMessageReceived(obj,srcserialport,event)
            message=append(obj.IncompleteMessage,read(srcserialport,srcserialport.NumBytesAvailable,"uint8"));
            splitMessages=split(message,sprintf("\r\n"));
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
            crcmessage = [message, uint8([bitand(crc,0x00FF), bitand(bitshift(crc,-8),0x00FF)])];
        end
    end
end