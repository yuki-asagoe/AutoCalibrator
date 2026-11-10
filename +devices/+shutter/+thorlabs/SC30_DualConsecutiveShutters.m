classdef SC30_DualConsecutiveShutters < devices.shutter.Shutter
    properties(Access = private)
        sc30 devices.shutter.thorlabs.SC30
    end
    
    methods
        function obj = SC30_DualConsecutiveShutters(serialportName)
            obj.sc30 = devices.shutter.thorlabs.SC30(serialportName);
        end
        
        function setExposurePattern(obj,openTimeInMilliSeconds,closeTimeInMilliSeconds,repetition)
            % The duration of open/close are enough long in single control
            if openTimeInMilliSeconds >= 20 && closeTimeInMilliSeconds >= 20
                obj.sc30.setInternalModeParameters(1,openTimeInMilliSeconds,closeTimeInMilliSeconds,repetition);
                obj.sc30.setInternalModeParameters(2,openTimeInMilliSeconds+100,20,1);
                obj.sc30.enableSyncEqual("Internal");
            elseif openTimeInMilliSeconds + closeTimeInMilliSeconds < 20 + 20
                error("This conbination of opening time and closing time should exceed limit of dual shutter control");
            elseif closeTimeInMilliSeconds < 20
                error("This close time duration is too short");
            else % openTimeInMilliSeconds < 20
                fullDuration = openTimeInMilliSeconds + closeTimeInMilliSeconds;
                openTime = 20;
                closeTime = fullDuration - openTime;
                delayTime = openTime - openTimeInMilliSeconds;
                obj.sc30.setInternalModeParameters(1,openTime,closeTime,repetition);
                obj.sc30.setInternalModeParameters(2,openTime,closeTime,repetition);
                obj.sc30.enableSyncDelayed("Internal",delayTime);
                obj.sc30.setMode("Internal");
            end
        end

        function start(obj)
            obj.sc30.startInternalModeControl(1);
        end

        function stop(obj)
            obj.sc30.stopControl(1);
        end

        function openShutter(obj)
            obj.sc30.setMode("Manual");
            obj.sc30.openShutter(1);
            obj.sc30.openShutter(2);
        end

        function closeShutter(obj)
            obj.sc30.setMode("Manual");
            obj.sc30.closeShutter(1);
            obj.sc30.closeShutter(2);
        end

        function dispose(obj)
            obj.sc30.dispose();
        end
    end
end

