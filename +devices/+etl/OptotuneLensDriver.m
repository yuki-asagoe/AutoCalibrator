% スレッドセーフではないのでマルチスレッド環境で呼ぶのは勘弁
classdef OptotuneLensDriver < handle
    properties(Access = private)
        IsOpen logical
        IsClosed logical
        SerialportName
        Serialport
        MaxHardwareCurrent_mA double
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
            obj.MaxHardwareCurrent_mA=[];
            
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
            value = int16(min(max(value,-4096),4095));
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
        
        function setCurrent(obj,value_mA)
            if ~obj.IsOpen
                return;
            end
            if isempty(obj.MaxHardwareCurrent_mA)
                obj.MaxHardwareCurrent_mA=obj.readMaxCurrentLimit();
            end
            obj.setCurrentRaw(int16(4096*min(max(value_mA/obj.MaxHardwareCurrent_mA,-1.0),1.0)));
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
            configureCallback(obj.Serialport,"terminator",@(src,evt) obj.onMessageReceived(src));
        end
        function unregisterCallback(obj)
            configureCallback(obj.Serialport,"off");
        end

        function onMessageReceived(obj,srcserialport)
            message=append(obj.IncompleteMessage,char(read(srcserialport,srcserialport.NumBytesAvailable,"uint8")));
            splitMessages=split(message,sprintf("\r\n"));
            obj.IncompleteMessage = splitMessages(end);
            obj.Messages=[obj.Messages;splitMessages(1:end-1)];
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
        
        function maxcurrentcalib_mA=readMaxCurrentLimit(obj,channel)
            arguments
                obj
                channel char = 'A'
            end
            if ~obj.IsOpen
                error('Error : This lens driver is already closed.');
            end
            if channel ~= 'A'
                error(['Error : Now Optotune lens driver allows this operation only for channel A, but the passed parameter is ',channel]);
            end
            obj.unregisterCallback();
            
            write(obj.Serialport,obj.appendCRCToMessage([uint8(['CrM',channel]),0b0,0b0]),"uint8");
            pause(1);
            
            if obj.Serialport.NumBytesAvailable < 9
                error('Loading current limit request is sent, but the driver seems not to have responded');
            end
            
            obj.onMessageReceived(obj.Serialport);
            responseIdx=find(startsWith(obj.Messages,['CM',channel]),1,'last');
            response=obj.Messages{responseIdx};
            obj.Messages(responseIdx)=[];
            
            if length(response) ~= 7
                error(append('Wrong response size for loading current limit request : ',response));
            end
            
            value=bitor(bitshift(uint32(response(4)),8),uint32(response(5)));
            maxcurrentcalib_mA=double(value)/100;
            
            obj.registerCallback();
        end
    end
end