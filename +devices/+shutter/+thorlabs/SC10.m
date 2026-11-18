classdef SC10 < devices.shutter.Shutter
    properties(Access = private)
        SerialPort
        Disposed logical
    end

    methods(Access = private)
        function assertNotDisposed(obj)
            if obj.Disposed
                error("Error : this shutter controller connection is already closed, please reopen again");
            end
        end

        function sendCommand(obj, command)
            obj.assertNotDisposed();
            writeline(obj.SerialPort, command);
            while readline(obj.SerialPort) ~= ">"; end % wait that the controller gets ready
        end

        function resultValue = parseResponse(~,responseText)
            resultValue = responseText;
        end

        function result = sendCommandAndGetResult(obj, command)
            obj.assertNotDisposed();
            flush(obj.SerialPort);
            writeline(obj.SerialPort,command);
            while true
                line = readline(obj.SerialPort);
                if line == "" || line == ">"
                    continue;
                elseif startsWith(line,"Command error")
                    error("SC10 / communication error : "+line);
                end
                result = obj.parseResponse(line);
                break;
            end
            while readline(obj.SerialPort) ~= ">"; end
        end
    end

    methods(Access = public)
        function obj = SC10(portname)
            obj.SerialPort = serialport(portname,9600);
            configureTerminator(obj.SerialPort,"CR/LF","CR");
            pause(0.5);
            
            writeline(obj.SerialPort,"");
            if readline(obj.SerialPort) ~= "Command error CMD_NOT_DEFINED" || readline(obj.SerialPort) ~= ">"
                obj.dispose();
                error("The shutter send unexpected responses, this device might not be sc10");
            end
        end

        function setMode(obj,mode)
            arguments(Input)
                obj devices.shutter.thorlabs.SC10
                mode devices.shutter.thorlabs.SC10Mode
            end
            if obj.getMode() ~= mode
                obj.sendCommand("mode="+uint8(mode));
            end
        end

        function mode = getMode(obj)
            arguments(Output)
                mode devices.shutter.thorlabs.SC10Mode
            end
            mode = devices.shutter.thorlabs.SC10Mode(str2double(obj.sendCommandAndGetResult("mode?")));
        end
        
        function enabled = isEnabled(obj)
            enabled = str2double(obj.sendCommandAndGetResult("ens?"));
        end

        function setEnable(obj,value)
            arguments(Input)
                obj devices.shutter.thorlabs.SC10
                value logical
            end
            if obj.isEnabled() == value
                return;
            end
            % Toggle enabled state
            obj.sendCommand("ens");
        end

        function openShutter(obj)
            obj.setMode("Manual");
            obj.setEnable(true);
        end

        function closeShutter(obj)
            obj.setMode("Manual");
            obj.setEnable(false);
        end

        function delete(obj)
            obj.dispose();
        end

        function dispose(obj)
            if obj.Disposed
                return;
            end
            delete(obj.SerialPort);
            obj.Disposed = true;
        end
    end
end