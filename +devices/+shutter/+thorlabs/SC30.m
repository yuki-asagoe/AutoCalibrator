classdef SC30 < devices.shutter.Shutter
    properties(Access = private)
        SeiralPort
        Disposed logical
    end

    methods(Access = private)
        function assertNotDisposed(obj)
            if obj.Disposed
                error("This device is already disposed");
            end
        end

        function flushInput(obj)
            if obj.SeiralPort.NumBytesAvailable > 0
                flush(obj.SeiralPort,"input");
            end
        end

        % Input responseText should be a string of one line without line break chars
        function resultValue, commandName = parseResponse(~,responseText)
            if responseText == "UNKNOWN COMMAND!"
                resultValue = [];
                return;
            end
            splitResponse = split(responseText,"? ");
            resultValue = splitResponse(2);
            commandName = splitResponse(1);
        end

        function sendCommand(obj,command)
            writeline(obj.SeiralPort,uint8(command));
        end

        function resultValue = sendCommandAndGetResult(obj,command)
            obj.flushInput();
            obj.sendCommand(command);
            line = readline(obj.SerialPort);
            resultValue = obj.parseResponse(line);
        end

        function sendCommandAndDiscardResult(obj,command)
            obj.sendCommandAndGetResult(command);
        end
    end

    methods(Access = public)
        function obj = SC30(portname)
            obj.Disposed = false;
            obj.SeiralPort = serialport(portname,115200);
            % SC30 seems send carriage return as terminator
            obj.SeiralPort.configureTerminator("CR","CR/LF");
            pause(0.5);
            result = obj.sendCommandAndGetResult("model?");
            if result ~= "SC30"
                obj.dispose();
                error("Connected device seems not SC30");
            end
        end

        % .openshutter() -> open shutter of channel 1
        % .openshutter(channel_number) -> open shutter of given channel (1 or 2)
        function openshutter(obj,varargin)
            channel = int32(1);
            if length(varargin) >= 1
                channel = int32(varargin{1});
            end
            obj.setshutter(channel,true);
        end

        function closeshutter(obj,varargin)
            channel = int32(1);
            if length(varargin) >= 1
                channel = int32(varargin{1});
            end
            obj.setshutter(channel,false);
        end

        function setshutter(obj,channel,open)
            arguments(Input)
                obj
                channel int32
                open logical
            end
            obj.assertNotDisposed();
            if ~any([1,2] == channel)
                error(sprintf("This channel[%d] is not supported",channel));
            end
            if open
                sendCommand("enable" + channel + "=1")
            else
                sendCommand("enable" + channel + "=0")
            end
        end

        function delete(obj)
            obj.dispose();
        end

        function dispose(obj)
            if obj.Disposed
                return;
            end
            delete(obj.SeiralPort)
            obj.Disposed = true;
        end
    end
end