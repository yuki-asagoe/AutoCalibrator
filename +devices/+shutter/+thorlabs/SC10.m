classdef SC10 < devices.shutter.Shutter
    properties(Access = private)
        SerialPort
        Disposed logical
    end

    methods(Access = private)
        function sendCommand(obj, command)
            writeline(obj.SerialPort, command);
            while readline(obj.SerialPort) ~= ">"; end
        end

        function [resultValue, commandName] = parseResponse(~,responseText)
            if responseText == "Command error CMD_NOT_DEFINED"
                resultValue = [];
                return;
            end
            splitResponse = split(responseText,"? ");
            resultValue = splitResponse(2);
            commandName = splitResponse(1);
        end

        function result = sendCommandAndGetResult(obj, command)
            flush(obj.SerialPort);
            obj.sendCommand(command);
            while true
                line = readline(obj.SerialPort);
                if line == "" || line == ">"
                    continue;
                end
                [result, commandName] = obj.parseResponse(line);
                if lower(command) == lower(commandName+"?")
                    break;
                end
            end
            while readline(obj.SerialPort) ~= ">"; end
        end
    end

    methods(Access = public)
        function obj = SC10(portname)
            obj.SerialPort = serialport(portname,9600);
            configureTerminator(obj.SerialPort,"CR","CR");
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