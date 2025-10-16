classdef AndorCamera < devices.camera.Camera
    properties(Access = private)
        IsOpened logical
        IsClosed logical
        ImageWidth {mustBeInteger}
        ImageHeight {mustBeInteger}
    end
    
    methods(Access = public)
        function obj = AndorCamera()
            obj.IsOpened = false;
            obj.IsClosed = false;
            obj.Width=0;
            obj.Height=0;
        end
        
        function open(obj)
            if obj.isOpened
                return;
            end
            if obj.IsClosed
                error("Error : this AndorCamera instance is already closed");
            end
            
            result = AndorInitialize('');
            if obj.printIfResultIsError(result)
                return;
            end
            result = SetAquisitionMode(devices.camera.andor.AcquisitionMode.SingleScan.get);
            obj.printIfResultIsError(result);
            
            result = SetExposureTime(0.02);
            obj.printIfResultIsError(result);
            
            result = SetReadMode(devices.camera.andor.ReadMode.Image.get);
            obj.printIfResultIsError(result);
            
            result = SetTriggerMode(devices.camera.andor.TriggerMode.Internal.get);
            obj.printIfResultIsError(result);
            
            result = SetShutter(1,1,0,0); % Open shutter in 0 ms
            obj.printIfResultIsError(result);
            
            [result,obj.ImageWidth, obj.ImageHeight]=GetDetector();
            obj.printIfResultIsError(result);
            
            result=SetImage(1, 1, 1, obj.ImageWidth, 1, obj.ImageHeight);
            obj.printIfResultIsError(result);
            
            result=StartAcquisition();
            obj.printIfResultIsError(result);
            
            obj.IsOpen=true;
        end
        
        function close(obj)
            if ~obj.IsOpened
                return;
            end
            
            result=AbortAcquisition();
            obj.printIfResultIsError(result);
            result=SetShutter(1, 2, 1, 1); % Close Shutter in 1 ms
            obj.printIfResultIsError(result);
            result=AndorShutdown();
            obj.printIfResultIsError(result);
        end
        
        function image=take(obj)
            obj.assertIsOpened();
            if obj.ImageHeight == 0 || obj.ImageWidth == 0
                error("Error : Image size of this Andor Camera is not initialized for some reason");
            end
            
            result=WaitForAcquisition();
            obj.printIfResultIsError(result);
            
            [result, imageData]=GetMostRecentImage(obj.ImageWidth*obj.ImageHeight);
            obj.printIfResultIsError(result);
            
            if result ~= atmcd.DRV_SUCCESS
               error("Error : failed to get camera image"); 
            end
            image=obj.decodeImageData(imageData);
        end
        
        function enableCooler(obj,enable)
            arguments(Input)
                obj
                enable logical = true
            end
            obj.assertIsOpened();
            result = [];
            if enable
                result=CoolerON();
            else
                result=CoolerOFF();
            end
            obj.printIfResultIsError(result);
        end
        
        function setExposureTime(obj,time_sec)
            arguments(Input)
                obj
                time_sec {mustBeNumeric}
            end
            result=SetExposureTime(time_sec);
            obj.printIfResultIsError(result);
        end
        
        function delete(obj)
            obj.close();
        end
    end
    
    methods(Access = private)
        function assertIsOpened(obj)
            if ~obj.IsOpened
                error("Error : this AndorCamera instance is not opened or already closed.")
            end
        end
        
        function image=decodeImageData(imageData)
            image = flip(reshape(imageData,obj.ImageWidth,obj.ImageHeight).',1);
        end
    end
    methods(Access = private, Static)
        function isResultError = printIfResultIsError(result)
            arguments(Output)
                isResultError logical
            end
            try
                CheckError(result);
            catch e
                warning(e);
                isResultError = true;
                return;
            end
            isResultError=false;
        end
    end
end

