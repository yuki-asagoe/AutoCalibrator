function positioncalibrator = calculateAffineTransformParameter(vid, slm, zdistanceinfo, focallength_um, wavelength_nm)
    arguments
        slm slm.PhaseSLM
        zdistanceinfo calibration.ZDistanceInfo
    end
    arguments (Output)
        positioncalibrator calibration.PositionCalibrator
    end
    
    % 二段階で座標系変換パラメータを推定
    % まず一段階目で直角二等辺三角形的な形に点を配置しておおよそのパラメータを推定します
    % 直角二等辺三角形なのは回転対象じゃないためにスポットと画像上の対応点を幾何形状から推論しやすいから
    % 次に正六角形に点を打って改めて実際のパラメータをとります
    % 先に求めた仮パラメータを使ってどの点が元の点と対応するか推論する
    
    [ypixelcount,xpixelcount]=slm.getPixelArraySize();
    pixelpitch_um=slm.getPixelPitch();

    patternscale=1

    trianglepoints = [ ...
        1 0; ...
        0 -1; ...
        -1 0 ...
    ];
    trianglepoints *= patternscale;
    phasemap = slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um,focallength_um,wavelength_nm);
    for i =1:size(trianglepoints,1)
        point=trianglepoints(i,:);
        phasemap.addSpot(point(1),point(2),zdistanceinfo.calibrate(0),1);
    end
    phasearray=phasemap.getPhaseArray();
    slm.apply(phasearray);
    pause(0.05);

    image = getdata(vid);
    if size(image,3) == 3
        image= rgb2gray(image);
    end
    brightspots = analysis.image.getbrightspots(image,3);
    [farestpoint1index,farestpoint2index] = analysis.geometry.searchfarestpair([brightspots.CenterX brightspots.CenterY]);
    lastpointindex=[1 2 3];
    lastpointindex([farestpoint1index,farestpoint2index]) = [];

    trianglepointsinresultimage=[brightspots(farestpoint1index);brightspots(lastpointindex);brightspots(farestpoint2index)];

    provisionalcalibrator= calibration.PositionCalibrator.adjust(trianglepointsinresultimage,trianglepoints);

    % 第二段階

    hexagonpoints = [ ...
        0 1; ...
        -sqrt(3)/2 0.5; ...
        -sqrt(3)/2 -0.5; ...
        0 -1; ...
        sqrt(3)/2 -0.5; ...
        sqrt(3)/2 0.5; ...
    ];
    hexagonpoints *= patternscale;
    phasemap = slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um,focallength_um,wavelength_nm);
    for i =1:size(hexagonpoints,1)
        point=trianglepoints(i,:);
        phasemap.addSpot(point(1),point(2),zdistanceinfo.calibrate(0),1);
    end
    phasearray=phasemap.getPhaseArray();
    slm.apply(phasearray);
    pause(0.05);

    image = getdata(vid);
    if size(image,3) == 3
        image= rgb2gray(image);
    end
    brightspots = analysis.image.getbrightspots(image,3);
    brightspotpos=[brightspots.CenterX brightspots.CenterY];
    for i = 1:size(brightspotpos,1)
        [outx,outy]=provisionalcalibrator.calibrate(brightspotpos(i,1),brightspotpos(i,2));
        brightspotpos(i,:)=[outx outy];
    end
    respondpoints=estimateRespondPoints(brightspotpos,hexagonpoints);

    positioncalibrator=calibration.PositionCalibrator.adjust([brightspots.CenterX brightspots.CenterY],respondpoints);
end

% inputpointarrayの点それぞれに対応する点をoutpointsetから対応する順で返す
function sortedrespondpoints = estimateRespondPoints(inputpointarray, outpointset)
    arguments
        inputpointarray (:,2) {mustBeNumeric}
        outpointset (:,2) {mustBeNumeric}
    end
    arguments(Output)
        sortedrespondpoints (:,2) {mustBeNumeric}
    end

    % 中心からの角度だけ見てる 距離は考慮してない
    % まあどうせローカルだし正六角形にしか使わないし
    centeredinputpoints=inputpointarray - mean(inputpointarray,1);
    centeredoutpointset=outpointset - mean(outpointset,1);

    centeredinputangles=angle(centeredinputpoints(:,1) + centeredinputpoints(:,2) *1i);
    centeredoutputangles=angle(centeredoutpointset(:,1) + centeredoutpointset(:,2) *1i);

    sortedrespondpoints = zeros(size(centeredinputangles),2)

    for i = 1:size(centeredinputangles)
        angledifference=normalizeRadian(centeredoutputangles -centeredinputangles(i));
        [~,minindex]=min(angledifference);
        sortedrespondpoints(i,:) = outpointset(minindex,:);
    end

end

% normalized in [-pi,pi)
function normalized = normalizeRadian(radian)
    normalized = x-pi*floor(x/pi+0.5);
end
