function [valueprovidingmaxscore,imageatfocus,scores] = scanFocusByETL(camera, slm, etl, spotx_um, spoty_um, spotz_um, focallength_um, wavelength_nm, showprogress)
    arguments (Input)
        camera devices.camera.Camera
        slm devices.slm.PhaseSLM
        etl devices.etl.OptotuneLensDriver
        spotx_um {mustBeNumeric}
        spoty_um {mustBeNumeric}
        spotz_um {mustBeNumeric}
        focallength_um {mustBeNumeric}
        wavelength_nm {mustBeNumeric}
        showprogress logical = false
    end
    values = -4096:250:4095;
    scores=zeros(size(values));
    currentMaxScore=-Inf;
    map=devices.slm.PhaseMap(1920,1200,8,8,focallength_um,wavelength_nm);
    map.addSpot(spotx_um,spoty_um,spotz_um);
    slm.apply(map.getPhaseArray);
    if showprogress
        figure();
    end
    for i = 1:length(values)
        value=values(i);
        etl.setCurrentRaw(value);
        pause(0.05);
        img = camera.take();
        score = analysis.image.getFocusScore(img);
        scores(i)=score;
        if score > currentMaxScore
            currentMaxScore = score;
            valueprovidingmaxscore = value;
            imageatfocus = img;
        end
        if showprogress
            imshow(rescale(img));
        end
    end
    etl.setCurrentRaw(valueprovidingmaxscore);
end