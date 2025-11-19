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
            obj.ImageWidth=0;
            obj.ImageHeight=0;
        end
        
        function open(obj)
            if obj.IsOpened
                return;
            end
            if obj.IsClosed
                error("Error : this AndorCamera instance is already closed");
            end
            
            result = AndorInitialize('');
            
            obj.IsOpened=true;
            
            if obj.printIfResultIsError(result)
                return;
            end
            
            obj.enableCooler(true);
            
            result = SetAcquisitionMode(double(devices.camera.andor.AcquisitionMode.SingleScan.get));
            obj.printIfResultIsError(result);
            
            result = SetExposureTime(0.5);
            obj.printIfResultIsError(result);
            
            result = SetReadMode(double(devices.camera.andor.ReadMode.Image.get));
            obj.printIfResultIsError(result);
            
            result = SetEMCCDGain(255);
            obj.printIfResultIsError(result);
            
            result = SetTriggerMode(double(devices.camera.andor.TriggerMode.Internal.get));
            obj.printIfResultIsError(result);
            
            result = SetShutter(1,1,0,0); % Open shutter in 0 ms
            obj.printIfResultIsError(result);
            
            [result,obj.ImageWidth, obj.ImageHeight]=GetDetector();
            obj.printIfResultIsError(result);
            
            result=SetImage(1, 1, 1, obj.ImageWidth, 1, obj.ImageHeight);
            obj.printIfResultIsError(result);
        end
        
        function close(obj)
            if ~obj.IsOpened
                return;
            end
            
            result=AbortAcquisition();
            %obj.printIfResultIsError(result);
            
            result=SetShutter(1, 2, 1, 1); % Close Shutter in 1 ms
            obj.printIfResultIsError(result);
            result=AndorShutDown();
            obj.printIfResultIsError(result);
            
            obj.IsOpened=false;
            obj.IsClosed=true;
        end
        
        function image=take(obj)
            obj.assertIsOpened();
            if obj.ImageHeight == 0 || obj.ImageWidth == 0
                error("Error : Image size of this Andor Camera is not initialized for some reason");
            end
            % Single Scan モードでは画像一枚とるたびにStartAcquisitionが必要な様子
            % 連続で画像とるならほかのモードのがいいかも
            result=StartAcquisition();
            obj.printIfResultIsError(result);
            
            result=WaitForAcquisitionTimeOut(1000);
            if result == atmcd.DRV_NO_NEW_DATA
                error("Error : Acquisition Timeout");
            end
            
            [imageresult, imageData]=GetMostRecentImage(obj.ImageWidth*obj.ImageHeight);
            obj.printIfResultIsError(result);
            
            result=AbortAcquisition();
            obj.printIfResultIsError(result);
            
            if imageresult ~= atmcd.DRV_SUCCESS
                error("Error : failed to get camera image"); 
            end
            image=obj.decodeImageData(imageData);
        end
        
        function enableCooler(obj,enable)
            arguments (Input)
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
            arguments
                obj
                time_sec {mustBeNumeric}
            end
            result=SetExposureTime(time_sec);
            obj.printIfResultIsError(result);
        end
        
        function setEMCCDGain(obj,value)
            value = min([max([value,0]),255]);
            result=SetEMCCDGain(value);
            obj.printIfResultIsError(result);
        end
        
        function delete(obj)
            obj.close();
        end
        function setImageSize(obj,size)
            height=min([max([size(1),1]),1024]);
            width=min([max([size(2),1]),1024]);

            obj.ImageHeight=height;
            obj.ImageWidth=width;
            result=SetImage(1, 1, 1, obj.ImageWidth, 1, obj.ImageHeight);
            obj.printIfResultIsError(result);
        end
        function imageSize=getImageSize(obj)
            imageSize=[obj.ImageHeight,obj.ImageWidth];
        end
    end
    
    methods(Access = private)
        function assertIsOpened(obj)
            if ~obj.IsOpened
                error("Error : this AndorCamera instance is not opened or already closed.")
            end
        end
        
        function image=decodeImageData(obj,imageData)
            image = flip(reshape(imageData,obj.ImageWidth,obj.ImageHeight).',1);
        end
    end
    methods(Access = private, Static)
        function isResultError = printIfResultIsError(result)
            try
                CheckError(result);
            catch e
                warning(e.message);
                isResultError = true;
                return;
            end
            isResultError=false;
        end
    end
end
