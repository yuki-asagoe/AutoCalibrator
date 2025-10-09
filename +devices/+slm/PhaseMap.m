classdef PhaseMap < handle
    properties (Access = private)
        % Center of modulation array should be on optical axis of incident ray
        ModulationArray (:,:) {coder.mustBeComplex}
        XPixelPitch_um double
        YPixelPitch_um double
        FocalLength_um double
        WaveLength_nm double
    end

    methods (Access = public)
        % pixel size of phase map in real optical system
        % xpixelpitch : Unit [μm]
        % ypixelpitch : Unit [μm]
        % --
        % focal length of objective lens that concentrate modulated light
        % focallength : Unit [μm]
        % --
        % wave length of modulated light ray
        % wavelength : Unit [nm]
        function obj = PhaseMap(xsize,ysize, xpixelpitch_um, ypixelpitch_um, focallength_um, wavelength_nm)
            obj.ModulationArray = zeros(ysize,xsize);
            obj.XPixelPitch_um=xpixelpitch_um;
            obj.YPixelPitch_um=ypixelpitch_um;
            obj.FocalLength_um=focallength_um;
            obj.WaveLength_nm=wavelength_nm;
        end
        % x,y,z : Unit [μm]
        % (x,y,z) = (0,0,0) is at center of optical system on focal plane
        function addSpot(obj,x_um,y_um,z_um,power)
            arguments(Input)
                obj
                x_um {mustBeNumeric}
                y_um {mustBeNumeric}
                z_um {mustBeNumeric}
                power = 1
            end
            [ysize,xsize] = size(obj.ModulationArray);
            [coordinatesMeshX,coordinatesMeshY] = meshgrid( ...
                (-xsize/2):1:((xsize-1)-xsize/2), ...
                (-ysize/2):1:((ysize-1)-ysize/2) ...
            );
            coordinatesMeshX_um = obj.XPixelPitch_um * coordinatesMeshX;
            coordinatesMeshY_um = obj.YPixelPitch_um * coordinatesMeshY;
            wavelength_um = obj.WaveLength_nm * 10e-3;

            obj.ModulationArray(:,:) = obj.ModulationArray(:,:) + power * exp( ...
                ... % X Y shift
                -2i*pi * (x_um*coordinatesMeshX_um+y_um*coordinatesMeshY_um)/(wavelength_um*obj.FocalLength_um) + ...
                ... % Z shift
                1i*pi * z_um * (coordinatesMeshX_um.^2 + coordinatesMeshY_um.^2) / (wavelength_um*obj.FocalLength_um^2) ...
            );
        end
        function phasearray = getPhaseArray(obj)
            phasearray=angle(obj.ModulationArray);
        end
    end
end