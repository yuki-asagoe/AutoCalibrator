:% Display-Hosted SLM
% Modulation pattern is shown on firgure window
classdef SantecSLM200DisplayHosted < devices.slm.PhaseSLM
    properties (Access = private)
        TargetFigure
        TargetImage
    end

    methods (Access = private)
        function obj = SantecSLM200DisplayHosted(targetfigure,targetimage)
            arguments(Input)
                targetfigure matlab.ui.Figure
                targetimage
            end
            obj.TargetFigure = targetfigure;
            obj.TargetImage = targetimage;
        end
    end

    methods (Access = public)
        function open(~)
        end

        function apply(obj, phasemap)
            if isempty(obj.TargetFigure)
                return
            end
            obj.TargetImage.CData=devices.slm.SantecSLM200DisplayHosted.encodeForDisplay(phasemap);
        end

        function close(obj)
            if isempty(obj.TargetFigure)
                return
            end
            delete(obj.TargetFigure)
            obj.TargetFigure=[];
            obj.TargetImage=[];
        end

        function [ysize,xsize]=getPixelArraySize(~)
            xsize=1920;
            ysize=1200;
        end

        % pixelpitch_um : Unit [μm]
        function pixelpitch_um=getPixelPitch(~)
            % btw pixel size is 7.8
            pixelpitch_um = 8.0;
        end
    end
    
    methods (Access = public, Static)
        function obj = createForDisplay(displaynumber)
            monitorPositions=get(groot,"MonitorPositions");
            monitorPos=monitorPositions(displaynumber,:);
            targetfigure=figure( ...
                'Name', 'DisplayHostedPhaseSLM_Target',...
                'MenuBar', 'none',...
                'ToolBar', 'none',...
                'IntegerHandle', 'on',...
                'OuterPosition', [monitorPos(1),monitorPos(2),monitorPos(3),monitorPos(4)],...
                'InnerPosition', [monitorPos(1),monitorPos(2),monitorPos(3),monitorPos(4)],...
                'WindowState', 'maximized' ...
            );
            % Setting fullscreen directly cause margin between screen and
            % window so first set it maximized, then set fullscreen
            pause(1)
            targetfigure.WindowState='fullscreen';
            
            imagehandle=imshow(zeros(1200,1920),'InitialMagnification','fit','Border','tight');

            obj = devices.slm.SantecSLM200DisplayHosted(targetfigure,imagehandle);
        end

        function slm200encodeddisplayoutput = encodeForDisplay(phasearray)
            arguments (Input)
                phasearray (:,:) double
            end
            arguments (Output)
                slm200encodeddisplayoutput (:,:,3) uint8
            end
            phasearrayquantizedin10bit = uint16(clip(phasearray * 1023 / (2*pi), 0,1023));

            R = uint8(bitshift(bitand(phasearrayquantizedin10bit,uint16(0b1110000000)),-2));
            G = uint8(bitshift(bitand(phasearrayquantizedin10bit,uint16(0b0001110000)),1));
            B = uint8(bitshift(bitand(phasearrayquantizedin10bit,uint16(0b0000001111)),4));

            [sizey,sizex]=size(phasearray);
            slm200encodeddisplayoutput=uint8(zeros(sizey,sizex,3));
            slm200encodeddisplayoutput(:,:,1) = R;
            slm200encodeddisplayoutput(:,:,2) = G;
            slm200encodeddisplayoutput(:,:,3) = B;
        end
    end
end