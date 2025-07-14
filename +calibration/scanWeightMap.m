function weightmap = scanWeightMap(vid,slm,zdistanceinfo,positioncalibrator, focallength_um, wavelength_nm)
    arguments
        slm slm.PhaseSLM
        zdistanceinfo calibration.ZDistanceInfo
        positioncalibrator calibration.PositionCalibrator
    end
    arguments (Output)
        weightmap calibration.IntensityWeightMap
    end

    [videowidth,videoheight] = vid.VideoResolution;
    [ypixelcount,xpixelcount]=slm.getPixelArraySize();
    pixelpitch_um=slm.getPixelPitch();

    gridsize=21;

    % スキャン画像を全部画素ごとの最大輝度で合成した画像に対して最大値を基準に重みを計算
    % 正直輝点の座標と輝度が検出できるから各画像に対して輝点を調べてもいいんだけど
    % 以前のプログラムがそういう実装なので踏襲する

    intensitymap=zeros(videoheight,videowidth);
    for y = linspace(videoheight*0.1,videoheight*0.9,gridsize)
        for x = linspace(videowidth * 0.1,videoheight*0.9,gridsize)
            phasemap = slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um, focallength_um, wavelength_nm);
            [opticalx opticaly]=positioncalibrator.calibrate(x,y);
            opticalz=zdistanceinfo.calibrate(0);
            phasemap.addSpot(opticalx,opticaly,opticalz,1);

            slm.apply(phasemap.getPhaseArray);
            pause(0.05);

            image = getdata(vid);

            if size(image,3) == 3
                image = rgb2gray(image);
            end

            intensitymap = max(intensitymap,image);
        end
    end

    intensity = zeros(gridsize,gridsize);

    widthofsinglegrid = videowidth * 0.8 / (gridsize - 1);
    heightofsinglegrid = videoheight * 0.8 / (gridsize -1);
    for yindex = 1:gridsize
        ycenterofgrid = math.lerp((yindex-1)/(gridsize-1),videoheight*0.1,videoheight*0.9);
        for xindex = 1:gridsize
            xcenterofgrid = math.lerp((xindex-1)/(gridsize-1),videowidth*0.1,videowidth*0.9);
            intensity(yindex,xindex) = max( ...
                intensitymap( ...
                    max([0,round(ycenterofgrid-heightofsinglegrid/2)]):min([videoheight,round(ycenterofgrid+heightofsinglegrid/2)]), ...
                    max([0,round(xcenterofgrid-widthofsinglegrid/2)]):min([videowidth,round(xcenterofgrid+widthofsinglegrid/2)]) ...
                ), ...
                [],"all" ...
            );
        end
    end

    normalizedintensity = intensity / max(intensity,[],"all");

    intensityaverage=mean(normalizedintensity,"all");

    % range [1 ~ 10]
    correctionweights= intensityaverage ./ max(normalizedintensity,0.1);
    weightmap = calibration.IntensityWeightMap( ...
        correctionweights, ...
        videowidth*0.1, ...
        videoheight*0.1, ...
        videowidth*0.9, ...
        videoheight*0.9 ...
    );
end