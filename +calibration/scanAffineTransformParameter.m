function positioncalibrator = scanAffineTransformParameter(camera, slm, zdistanceinfo, focallength_um, wavelength_nm, patternscale, centerpoints)
    arguments (Input)
        camera devices.camera.Camera
        slm devices.slm.PhaseSLM
        zdistanceinfo calibration.ZDistanceInfo
        focallength_um {mustBeNumeric}
        wavelength_nm {mustBeNumeric}
        % キャリブレーションパターンの大きさ係数
        patternscale {mustBeNumeric} = 30;
        % キャリブレーションパターンの中心
        centerpoints (1,2) {mustBeNumeric} = [0,0]
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
    
    trianglepoints = [ ...
        1 0; ...
        0 -1; ...
        -1 0 ...
    ];
    trianglepoints = trianglepoints * patternscale + centerpoints;
    phasemap = devices.slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um,focallength_um,wavelength_nm);
    for i =1:size(trianglepoints,1)
        point=trianglepoints(i,:);
        phasemap.addSpot(point(1),point(2),zdistanceinfo.calibrate(0),1);
    end
    phasearray=phasemap.getPhaseArray();
    slm.apply(phasearray);
    pause(0.05);

    image = camera.take();
    if size(image,3) == 3
        image= rgb2gray(image);
    end
    brightspots = analysis.image.getbrightspots(image,3);
    brightspotpoints = [brightspots.CenterX; brightspots.CenterY]';
    [farestpoint1index,farestpoint2index] = analysis.geometry.searchfarestpair(brightspotpoints);
    % 直角三角形の直角部分の頂点の添え字
    lastpointindex=[1 2 3];
    lastpointindex([farestpoint1index,farestpoint2index]) = [];
    % このままだと最遠点として検出された点がどっちがどっちかわからないので外積の符号で判定する
    basecrossproduct=math.cross2d(trianglepoints(3,:)-trianglepoints(1,:),trianglepoints(2,:)-trianglepoints(1,:));
    % 注意点としてmatlabでは画像の下方向がY軸正方向になるので軸をそろえるために外積符号は反転する
    % 入力の二点のY座標を反転して外積をとるのとその外積自体の符号を反転するのは同値のはず
    inimagepointscrossproduct = - math.cross2d(brightspotpoints(farestpoint2index,:)-brightspotpoints(farestpoint1index),brightspotpoints(lastpointindex)-brightspotpoints(farestpoint1index));
    if sign(basecrossproduct) ~= sign(inimagepointscrossproduct)
        temp = farestpoint1index;
        farestpoint1index=farestpoint2index;
        farestpoint2index=temp;
    end

    trianglepointsinresultimage=[brightspotpoints(farestpoint1index,:);brightspotpoints(lastpointindex,:);brightspotpoints(farestpoint2index,:)];

    provisionalcalibrator= calibration.PositionCalibrator.adjust(trianglepointsinresultimage,trianglepoints);

    % 第二段階
    % 画像サイズに基づいてパターンの中心とスケール係数を再計算
    [ysize,xsize]=size(image);
    centerpoints = [xsize/2,ysize/2];
    patternscale = min([xsize,ysize])*0.3;
    hexagonpoints = [ ...
        0 1; ...
        -sqrt(3)/2 -0.5; ...
        sqrt(3)/2 -0.5; ...
        0 -1; ...
        -sqrt(3)/2 0.5; ...
        sqrt(3)/2 0.5 ...
    ];
    hexagonpoints = hexagonpoints * patternscale + centerpoints;
    phasemap = devices.slm.PhaseMap(xpixelcount,ypixelcount,pixelpitch_um,pixelpitch_um,focallength_um,wavelength_nm);
    actualpoints=provisionalcalibrator.calibratePointArray(hexagonpoints);
    for i =1:size(actualpoints,1)
        phasemap.addSpot(actualpoints(i,1),actualpoints(i,2),zdistanceinfo.calibrate(0),1);
    end
    phasearray=phasemap.getPhaseArray();
    slm.apply(phasearray);
    pause(0.05);

    image = camera.take();
    if size(image,3) == 3
        image= rgb2gray(image);
    end
    brightspots = analysis.image.getbrightspots(image,6);
    brightspotpos=[brightspots.CenterX;brightspots.CenterY]';
    respondpoints=estimateRespondPoints(brightspotpos,hexagonpoints,actualpoints);

    positioncalibrator=calibration.PositionCalibrator.adjust(brightspotpos,respondpoints);
end

% inputpointarrayのそれぞれに対応するoutpointsetの点を対応するインデックのactualoutpointsの点で対応する順で返す
function sortedrespondpoints = estimateRespondPoints(inputpointarray, outpointset, actualoutpoints)
    arguments (Input)
        inputpointarray (:,2) {mustBeNumeric}
        outpointset (:,2) {mustBeNumeric}
        actualoutpoints (:,2) {mustBeNumeric}
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

    sortedrespondpoints = zeros(size(centeredinputangles,1),2);

    for i = 1:size(centeredinputangles)
        angledifference=abs(normalizeRadian(centeredoutputangles -centeredinputangles(i)));
        [~,minindex]=min(angledifference);
        sortedrespondpoints(i,:) = actualoutpoints(minindex,:);
    end

end

% normalized in [-pi,pi)
function normalized = normalizeRadian(radian)
    normalized = radian -2*pi*floor((radian+pi)/(2*pi));
end
