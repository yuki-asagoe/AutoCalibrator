% Display-Hosted SLM
% Modulation pattern is shown on firgure window
classdef DisplayHostedPhaseSLM < PhaseSLM
    properties (Access = private)
        TargetFigure matlab.ui.Figure
        TargetImage
    end

    methods (Access = private)
        function obj = DisplayHostedPhaseSLM(targetfigure,targetimage)
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
            obj.TargetImage.CData=phasemap;
        end

        function close(obj)
            if isempty(obj.TargetFigure)
                return
            end
            delete(figure(obj.TargetFigure))
            obj.TargetFigure=[];
            obj.TargetImage=[];
        end
    end
    
    methods (Access = public)
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
                'WindowState', 'fullscreen' ...
            );
            targetAxis=figure('Parent',targetfigure);
            imagehandle=imshow([],'Parent',targetAxis,'InitialMagnification','fit','Border','tight');

            obj = DisplayHostedPhaseSLM(targetfigure,imagehandle);
        end
    end
end