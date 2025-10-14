classdef PhaseMapForCalibGUI < handle
    properties(Access = private)
        ModulationArray (:,:)
        XPixelPitch_um double
        YPixelPitch_um double
        FocalLength_um double
        WaveLength_nm double
    end
    
    methods(Access = public)
        function obj = PhaseMapForCalibGUI(xsize,ysize, xpixelpitch_um, ypixelpitch_um, focallength_um, wavelength_nm)
            arguments
                xsize = 1920
                ysize = 1200
                xpixelpitch_um = 8
                ypixelpitch_um = 8
                focallength_um = 8*10^3
                wavelength_nm = 1040
            end
            obj.ModulationArray = complex(zeros(ysize,xsize),0);
            obj.XPixelPitch_um=xpixelpitch_um;
            obj.YPixelPitch_um=ypixelpitch_um;
            obj.FocalLength_um=focallength_um;
            obj.WaveLength_nm=wavelength_nm;
        end
        
        function addSpot(obj,shiftx,shifty,shiftz_um,power)
            arguments
                obj
                shiftx {mustBeNumeric}
                shifty {mustBeNumeric}
                shiftz_um {mustBeNumeric}
                power = 1
            end
            [ysize,xsize] = size(obj.ModulationArray);
            [coordinatesMeshX,coordinatesMeshY] = meshgrid( ...
                (-xsize/2):1:((xsize-1)-xsize/2), ...
                (-ysize/2):1:((ysize-1)-ysize/2) ...
            );
            coordinatesMeshX_um = obj.XPixelPitch_um * coordinatesMeshX;
            coordinatesMeshY_um = obj.YPixelPitch_um * coordinatesMeshY;
            coordinatesMeshX_normalized = coordinatesMeshX / xsize; % almost -0.5 ~ 0.5
            coordinatesMeshY_normalized = coordinatesMeshY / ysize;
            wavelength_um = obj.WaveLength_nm * 10e-3;

            obj.ModulationArray(:,:) = obj.ModulationArray(:,:) + power * exp( ...
                ... % X Y shift
                -2i*pi * (shiftx*coordinatesMeshX_normalized+shifty*coordinatesMeshY_normalized) + ...
                ... % Z shift
                1i*pi * shiftz_um * (coordinatesMeshX_um.^2 + coordinatesMeshY_um.^2) / (wavelength_um*obj.FocalLength_um^2) ...
            );
        end
        function phasearray = getPhaseArray(obj)
            phasearray=angle(obj.ModulationArray);
        end
    end
end

