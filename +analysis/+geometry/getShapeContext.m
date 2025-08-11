% https://en.wikipedia.org/wiki/Shape_context

% この関数はO(n^2)だと思うのであんまり大きい点群には使わないでください

% 回転に対して柔軟性を持たせるために厳密な形状文脈(Shape Context)ではなくて
% 各領域中心への距離に基づいて重みをとって分散させる処理を加えています (useSoftBinning = true の場合)
% 全領域ですると計算量的な意味で大変なことになるので8近傍領域だけでやります
% この時の距離関数にはユークリッド距離を使用していますが
% 対数極空間においてこのアプローチが最適なのかは考える必要があります
function shapecontexts=getShapeContext(pointSet,distanceDivisionCount,angleDivisionCount, useSoftBinning)
    arguments(Input)
        pointSet (:,2) {mustBeNumeric}
        distanceDivisionCount {mustBeInteger}
        angleDivisionCount {mustBeInteger}
        useSoftBinning = true
    end
    pointCount = size(pointSet,1);

    shapecontexts = zeros(pointCount,distanceDivisionCount,angleDivisionCount);

    pairwiseDistances = pdist(pointSet);
    averageDistance = mean(pairwiseDistances);
    pDistMatrix = squareform(pairwiseDistances);

    normalizedLogScaleDistances = log(pDistMatrix./averageDistance +1);
    maxDistanceLimit = log(2+1); % 正規化してるからpDistMatrix はだいたい[0,2]くらいまでの範囲には収まってるだろうという意図

    centerPositionsOfRegion = zeros(distanceDivisionCount,angleDivisionCount,2);
    differenceDistanceBetweenTwoRegion=maxDistanceLimit/distanceDivisionCount;
    differenceAngleBetweenTwoRegion=2*pi/angleDivisionCount;
    [centerDistanceMatrix,centerAngleMatrix] = meshgrid( ...
        differenceDistanceBetweenTwoRegion*(1:distanceDivisionCount - 0.5), ...
        differenceAngleBetweenTwoRegion*(1:angleDivisionCount - 0.5) ...
    );
    centerPositionsOfRegion(:,:,1) = centerDistanceMatrix .* cos(centerAngleMatrix);
    centerPositionsOfRegion(:,:,2) = centerDistanceMatrix .* sin(centerAngleMatrix);

    for i = 1:pointCount
        for j = 1:pointCount
            if i == j
                continue;
            end
            logDist=normalizedLogScaleDistances(i,j);
            distGroup=min([ ...
                distanceDivisionCount, ...
                1+floor(min([1,logDist/maxDistanceLimit])*(distanceDivisionCount)) ...
            ]);
            
            % 複素数経由してるのは無駄かも　暇があったら普通に計算するように修正するべきか
            differenceAsComplex=(pointSet(j,1)+1i*pointSet(j,2))-(pointSet(i,1)+1i*pointSet(i,2));
            differenceAngle=angle(differenceAsComplex);

            angleGroup=min([ ...
                angleDivisionCount, ...
                1+floor((differenceAngle/(2*pi))*(angleDivisionCount)) ...
            ]);

            if ~useSoftBinning
                shapecontexts(i,distGroup,angleGroup)=shapecontexts(i,distGroup,angleGroup)+1;
                continue;
            end

            % 以下近傍領域での重みづけ値分散
            [nearRegionsDistGroup,nearRegionsAngleGroup] = meshgrid(-1:1 + distGroup,-1:1 + angleGroup);
            nearRegionsAngleGroup = mod(nearRegionsAngleGroup,angleDivisionCount)+1;
            distanceToNearRegion=zeros(3,3);

            for regionDistGroupIdx = 1:3
                for regionAngleGroupIdx = 1:3
                    thisRegionDistGroup=nearRegionsDistGroup(regionDistGroupIdx,regionAngleGroupIdx);
                    if thisRegionDistGroup <= 0 | thisRegionDistGroup > angleDivisionCount
                        distanceToNearRegion(regionDistGroupIdx,regionAngleGroupIdx) = Inf;
                        continue;
                    end
                    thisRegionAngleGroup=nearRegionsAngleGroup(regionDistGroupIdx,regionAngleGroupIdx);
                    centerOfThisRegion=centerPositionsOfRegion(thisRegionDistGroup,thisRegionAngleGroup);
                    distanceToNearRegion(regionDistGroupIdx,regionAngleGroupIdx) = pdist([pointSet(i,:),centerOfThisRegion]);
                end
            end

            weight=1 ./ distanceToNearRegion
            normalizedWeight = weight ./ sum(weight,"all");

            for regionDistGroupIdx = 1:3
                for regionAngleGroupIdx = 1:3
                    thisRegionDistGroup=nearRegionsDistGroup(regionDistGroupIdx,regionAngleGroupIdx);
                    if thisRegionDistGroup <= 0 | thisRegionDistGroup > angleDivisionCount
                        continue;
                    end
                    thisRegionAngleGroup=nearRegionsAngleGroup(regionDistGroupIdx,regionAngleGroupIdx);
                    shapecontext(i,thisRegionDistGroup,thisRegionAngleGroup) = ...
                        shapecontext(i,thisRegionDistGroup,thisRegionAngleGroup) + weight(regionDistGroupIdx,regionAngleGroupIdx);
                end
            end
        end
    end

    return;
end