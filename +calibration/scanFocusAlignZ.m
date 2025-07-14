function [zdistanceinfo,imageatfocalplane] = scanFocusAlignZ(vid,slm, spotx_um, spoty_um, scanzlist_um, focallength_um, wavelength_nm)
    arguments
        slm slm.PhaseSLM
        % belows :Unit [μm]
        spotx_um {mustBeNumeric}
        spoty_um {mustBeNumeric}
        scanzlist_um (:) {mustBeNumeric,verifyNotEmpty}
    end
    arguments(Output)
        zdistanceinfo calibration.ZDistanceInfo
    end
    
    smallestspotarea=Inf;
    zprovidessmallestarea=[];
    imageprovidessmallestarea=[];

    [ypixelcount,xpixelcount]=slm.getPixelArraySize();
    pixelpitch_um=slm.getPixelPitch();

    for z_um = scanzlist_um
        phasemap=slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um,focallength_um,wavelength_nm);
        phasemap.addSpot(spotx_um,spoty_um,z_um);
        phasearray=phasemap.getPhaseArray();
        slm.apply(phasearray)
        pause(0.05)

        image=getdata(vid)
        grayscaleimage=[]
        if size(image,3) == 3
            grayscaleimage = rgb2gray(image)
        else
            grayscaleimage = image
        end

        brightspot=analysis.image.getbrightspots(grayscaleimage,1)

        % 最も面積の小さい輝点をもって焦点があっているとする
        if brightspot.Area < smallestspotarea
            smallestspotarea=brightspot.Area
            zprovidessmallestarea = z_um
            imageprovidessmallestarea=grayscaleimage
        end
    end

    zdistanceinfo=calibration.ZDistanceInfo(zprovidessmallestarea);
    imageatfocalplane=imageprovidessmallestarea;
end