function [zdistanceinfo,imageatfocalplane] = scanFocusAlignZ(camera,slm, spotx_um, spoty_um, scanzlist_um, focallength_um, wavelength_nm)
    arguments (Input)
        camera devices.camera.Camera
        slm slm.PhaseSLM
        % belows :Unit [μm]
        spotx_um {mustBeNumeric}
        spoty_um {mustBeNumeric}
        scanzlist_um {mustBeNumeric,verifyNotEmpty}
        focallength_um {mustBeNumeric}
        wavelength_nm {mustBeNumeric}
    end
    arguments(Output)
        zdistanceinfo calibration.ZDistanceInfo
        imageatfocalplane (:,:) {mustBeNumeric}
    end
    
    scores=zeros(size(scanzlist_um));
    currentMaxScore=-Inf;
    zProvidingMaxScore=[];
    imageProvidingMaxScore=[];

    [ypixelcount,xpixelcount]=slm.getPixelArraySize();
    pixelpitch_um=slm.getPixelPitch();

    for i = 1:length(scanzlist_um)
        z_um = scanzlist_um(i);
        phasemap=slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um,focallength_um,wavelength_nm);
        phasemap.addSpot(spotx_um,spoty_um,z_um);
        phasearray=phasemap.getPhaseArray();
        slm.apply(phasearray)
        pause(0.05)

        image=camera.take();
        singleChannelImage=[];
        if size(image,3) == 3
            singleChannelImage = rgb2gray(image);
        else
            singleChannelImage = image;
        end

        score=analysis.image.getFocusScore(singleChannelImage);
        if currentMaxScore < score
            currentMaxScore = score;
            zProvidingMaxScore=z_um;
            imageProvidingMaxScore=singleChannelImage;
        end
        scores(i)=score;
    end

    zdistanceinfo=calibration.ZDistanceInfo(zProvidingMaxScore);
    imageatfocalplane=imageProvidingMaxScore;
end