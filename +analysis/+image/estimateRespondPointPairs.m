% あまり大きな点群は想定していません
function sortedEstimatedPoints=estimateRespondPointPairs(basePoints,estimatedPoints)
    arguments(Input)
        basePoints (:,2) {mustBeNumeric}
        estimatedPoints (:,2) {mustBeNumeric}
    end
    arguments(Output)
        sortedEstimatedPoints (:,2) {mustBeNumeric}
    end

    assert(all(size(basePoints) == size(estimatedPoints)));

    pointCount = size(basePoints,1);

    % ソフトビニング付きのShapeContextを各点で計算してχ2乗距離が近いものを対応点にする

    shapeContextOfBasePoints=analysis.geometry.getShapeContext(basePoints,5,12); % 5,12 はテキトウに決めました
    shapeContextOfEstimatedPoints=analysis.geometry.getShapeContext(estimatedPoints,5,12);

    chiSquaredDistances=zeros(pointCount,pointCount);

    for i=1:pointCount
        for j=1:pointCount
            chiSquaredDistances(i,j)=analysis.statistics.getChiSquaredDistance(shapeContextOfBasePoints(i,:,:),shapeContextOfEstimatedPoints(j,:,:));
        end
    end
    similarity = rescale(1./chiSquaredDistances);

    % 残り類似度のうちから最大の類似度を与えるペアから順番に対応付けしていきます
    sortIndexArray=zeros(1,pointCount);
    for i=1:pointCount
        [maxSimilarities,basePointIdxProvidingMaxSimilarity] = max(similarity);
        [~,estimatedPointIdxProvidingMaxSimilarity] = max(maxSimilarities);

        selectedIdxOfEstimated=estimatedPointIdxProvidingMaxSimilarity;
        selectedIdxOfBase=basePointIdxProvidingMaxSimilarity(selectedIdxOfEstimated);
        % 対応付けが完了したのでその点の関連する類似度を最小化している
        similarity(selectedIdxOfBase,:) = -Inf;
        similarity(:,selectedIdxOfBase) = -Inf;

        sortIndexArray(estimatedPointIdxProvidingMaxSimilarity)=selectedIdxOfBase;
    end
    sortedEstimatedPoints=estimatedPoints(sortIndexArray);
end