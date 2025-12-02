function weightmap = scanWeightMap(camera,slm,zdistanceinfo,positioncalibrator, focallength_um, wavelength_nm, gridsize,margin)
    arguments (Input)
        camera
        slm slm.PhaseSLM
        zdistanceinfo calibration.ZDistanceInfo
        positioncalibrator calibration.PositionCalibrator
        focallength_um {mustBeNumeric}
        wavelength_nm {mustBeNumeric}
        gridsize {mustBeInteger} = 21
        margin {mustBeNumeric} = 0
    end
    arguments (Output)
        weightmap calibration.IntensityWeightMap
    end

    imageSize=camera.getImageSize();
    imageHeight=imageSize(1);
    imageWidth=imageSize(2);
    gridWidth=(imageWidth-margin*2)/gridsize;
    gridHeight=(imageHeight-margin*2)/gridsize;
    [ypixelcount,xpixelcount]=slm.getPixelArraySize();
    pixelpitch_um=slm.getPixelPitch();

    averagefilter=fspecial("average",3);

    % スキャン画像の各領域の最大輝度で重みを計算
    % 正直輝点の座標と輝度が検出できるから各画像に対して輝点を調べてもいいんだけど
    % 以前のプログラムがそういう実装なので踏襲する

    intensitymap=zeros(gridsize,gridsize);
    
    % figure;
    for gridy = 1:gridsize
        gridStartY=margin+gridHeight*(gridy-1);
        gridCenterY = gridStartY+gridHeight*0.5;
        for gridx = 1:gridsize
            gridStartX=margin+gridWidth*(gridx-1);
            gridCenterX = gridStartX+gridWidth*0.5;
            phasemap = devices.slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um, focallength_um, wavelength_nm);
            [opticalx, opticaly]=positioncalibrator.calibrate(gridCenterX,gridCenterY);
            opticalz=zdistanceinfo.calibrate(0);
            phasemap.addSpot(opticalx,opticaly,opticalz,1);

            slm.apply(phasemap.getPhaseArray);
            pause(0.05);

            image = camera.take();

            if size(image,3) == 3
                image = rgb2gray(image);
            end
            
            filteredimg=imfilter(image,averagefilter);
            
            %imshow(rescale(filteredimg));

            intensitymap(gridy,gridx)=max(filteredimg(round(gridStartY):round(gridStartY+gridHeight) , round(gridStartX):round(gridStartX+gridWidth)),[],"all");
        end
    end

    maxscale=5;
    normalizedintensity = intensitymap / max(intensitymap,[],"all");
    normalizedintensity(normalizedintensity < (1/maxscale)) = (1/maxscale);

    % range [1 ~ 10]
    correctionweights= 1./normalizedintensity;
    weightmap = calibration.IntensityWeightMap( ...
        correctionweights, ...
        margin, ...
        margin, ...
        imageWidth-margin, ...
        imageHeight-margin ...
    );
end