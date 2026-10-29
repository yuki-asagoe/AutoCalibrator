classdef SC30 < devices.shutter.Shutter
    properties(Access = private)
        SerialPort
        Disposed logical
    end

    methods(Access = private)
        function assertNotDisposed(obj)
            if obj.Disposed
                error("This device is already disposed");
            end
        end

        function assertValidChannel(~,channel)
            if ~any([1,2] == channel)
                error("This channel[%d] is not supported",channel);
            end
        end

        function assertCurrentModeIs(obj,mode)
            arguments
                obj devices.shutter.thorlabs.SC30
                mode devices.shutter.thorlabs.Mode
            end
            currentMode = obj.getMode();
            if mode ~= currentMode
                error("Mode[%s] is needed, but current mode is [%s]",mode,currentMode);
            end
        end

        function flushInput(obj)
            if obj.SerialPort.NumBytesAvailable > 0
                flush(obj.SerialPort,"input");
            end
        end

        % Input responseText should be a string of one line without line break chars
        function [resultValue, commandName] = parseResponse(~,responseText)
            if responseText == "UNKNOWN COMMAND!"
                resultValue = [];
                return;
            end
            splitResponse = split(responseText,"? ");
            resultValue = splitResponse(2);
            commandName = splitResponse(1);
        end

        function sendCommand(obj,command)
            writeline(obj.SerialPort,command);
        end

        function resultValue = sendCommandAndGetResult(obj,command)
            obj.flushInput();
            obj.sendCommand(command);
            readline(obj.SerialPort); % SC30 sends empty line at start of response
            line = readline(obj.SerialPort);
            resultValue = obj.parseResponse(line);
        end
    end

    methods(Access = public)
        function obj = SC30(portname)
            obj.Disposed = false;
            obj.SerialPort = serialport(portname,115200);
            % SC30 seems send carriage return as terminator
            obj.SerialPort.configureTerminator("CR","CR/LF");
            pause(0.5);
            result = obj.sendCommandAndGetResult("model?");
            if result ~= "SC30"
                obj.dispose();
                error("Connected device seems not SC30");
            end
        end

        % .openshutter() -> open shutter of channel 1
        % .openshutter(channel_number) -> open shutter of given channel (1 or 2)
        function openShutter(obj,varargin)
            channel = int32(1);
            if length(varargin) >= 1
                channel = int32(varargin{1});
            end
            obj.setShutter(channel,true);
        end

        function closeShutter(obj,varargin)
            channel = int32(1);
            if length(varargin) >= 1
                channel = int32(varargin{1});
            end
            obj.setShutter(channel,false);
        end

        function setShutter(obj,channel,open)
            arguments(Input)
                obj
                channel int32
                open logical
            end
            obj.assertCurrentModeIs(devices.shutter.thorlabs.Mode.Manual);
            obj.enable(channel,open);
        end

        function enable(obj,channel,state)
            arguments
                obj devices.shutter.thorlabs.SC30
                channel int32
                state logical
            end
            obj.assertNotDisposed();
            obj.assertValidChannel(channel);
            if state
                obj.sendCommand("enable" + channel + "=1");
            else
                obj.sendCommand("enable" + channel + "=0");
            end
        end

        function enabled = isEnabled(obj,channel)
            obj.assertNotDisposed();
            obj.assertValidChannel(channel);
            enabled = str2double(obj.sendCommandAndGetResult("enable"+channel+"?")) == 1;
        end

        function synced = isSyncEnabled(obj)
            arguments(Output)
                synced logical
            end
            obj.assertNotDisposed();
            synced=(str2double(obj.sendCommandAndGetResult("syncenable?")) == 1);
        end
        
        function setSynchronization(obj,sync)
            if sync
                obj.sendCommand("syncenable=1");
            else
                obj.sendCommand("syncenable=0");
            end
        end

        function enableSync(obj)
            obj.setSynchronization(true);
        end

        function enableSyncEqual(obj,mode)
            arguments
                obj devices.shutter.thorlabs.SC30
                mode devices.shutter.thorlabs.Mode
            end
            obj.setSyncMode(mode,"Equal");
            obj.enableSync();
        end

        function enableSyncInverted(obj,mode)
            arguments
                obj devices.shutter.thorlabs.SC30
                mode devices.shutter.thorlabs.Mode
            end
            obj.setSyncMode(mode,"Inverted");
            obj.enableSync();
        end

        function enableSyncDelayed(obj,mode,delayTimeInMilliSeconds)
            arguments
                obj devices.shutter.thorlabs.SC30
                mode devices.shutter.thorlabs.Mode
                delayTimeInMilliSeconds double
            end
            obj.setSyncMode(mode,"Delayed");
            obj.setSyncDelay(mode,delayTimeInMilliSeconds);
            obj.enableSync();
        end

        function disableSync(obj)
            obj.setSynchronization(false);
        end

        function setSyncDelay(obj,mode,delayInMilliSeconds)
            arguments(Input)
                obj devices.shutter.thorlabs.SC30
                mode devices.shutter.thorlabs.Mode
                delayInMilliSeconds double
            end
            prefix = mode.toCommandPrefix();
            obj.sendCommand(prefix + "syncdelayuom=0");
            obj.sendCommand(prefix + "syncdelay="+delayInMilliSeconds);
        end

        function mode = getMode(obj)
            arguments(Output)
                mode devices.shutter.thorlabs.Mode
            end
            mode = devices.shutter.thorlabs.Mode( ...
                str2double(obj.sendCommandAndGetResult("mode?")) ...
            );
        end

        function mode = setMode(obj,mode)
            arguments
                obj devices.shutter.thorlabs.SC30
                mode devices.shutter.thorlabs.Mode
            end
            obj.sendCommand("mode="+double(mode));
        end

        function syncMode = getSyncMode(obj,shutterMode)
            arguments(Input)
                obj devices.shutter.thorlabs.SC30
                shutterMode devices.shutter.thorlabs.Mode
            end
            arguments(Output)
                syncMode devices.shutter.thorlabs.SyncMode
            end
            syncMode = devices.shutter.thorlabs.SyncMode( ...
                str2double(obj.sendCommandAndGetResult(shutterMode.toCommandPrefix()+"syncmode?")) ...
            );
        end

        function setSyncMode(obj,shutterMode,syncMode)
            arguments(Input)
                obj devices.shutter.thorlabs.SC30
                shutterMode devices.shutter.thorlabs.Mode
                syncMode devices.shutter.thorlabs.SyncMode
            end
            obj.sendCommand(shutterMode.toCommandPrefix()+"syncmode="+int8(syncMode))
        end

        function startInternalModeControl(obj,channel)
            obj.setMode("Internal");
            obj.enable(channel,true);
        end

        function stopControl(obj,channel)
            obj.enable(channel,false);
        end

        function setInternalModeParameters(obj,channel,openTimeInMilliSeconds,closeTimeInMilliSeconds,repetition)
            obj.setModeParameters("Internal",channel,openTimeInMilliSeconds,closeTimeInMilliSeconds,repetition);
        end

        function setExternalModeParameters(obj,channel,openTimeInMilliSeconds,closeTimeInMilliSeconds,repetition)
            obj.setModeParameters("External",channel,openTimeInMilliSeconds,closeTimeInMilliSeconds,repetition);
        end

        function setTriggeredModeParameters(obj,channel,openTimeInMilliSeconds,closeTimeInMilliSeconds,repetition)
            obj.setModeParameters("Triggered",channel,openTimeInMilliSeconds,closeTimeInMilliSeconds,repetition);
        end

        function setModeParameters(obj,mode,channel,openTimeInMilliSeconds,closeTimeInMilliSeconds,repetition)
            arguments
                obj devices.shutter.thorlabs.SC30
                mode devices.shutter.thorlabs.Mode
                channel int32
                openTimeInMilliSeconds double
                closeTimeInMilliSeconds double
                repetition double
            end
            obj.assertValidChannel(channel);
            if mode == devices.shutter.thorlabs.Mode.Manual
                error('This operation is unavailable for Manual mode');
            end
            if openTimeInMilliSeconds < 20
                warning("Too short open duration[%d] might be not supported",openTimeInMilliSeconds);
            end
            if closeTimeInMilliSeconds < 20
                warning("Too short close duration[%d] might be not supported",closeTimeInMilliSeconds);
            end
            repetition = round(repetition);
            prefix = mode.toCommandPrefix();

            obj.sendCommand(prefix+"openuom"+channel+"=0");
            obj.sendCommand(prefix+"closeuom"+channel+"=0");
            obj.sendCommand(prefix+"open"+channel+"="+openTimeInMilliSeconds);
            obj.sendCommand(prefix+"close"+channel+"="+closeTimeInMilliSeconds);
            obj.sendCommand(prefix+"cyclecnt"+channel+"="+repetition);
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