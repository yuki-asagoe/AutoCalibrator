function brightspots = getbrightspots(image, maxoutputcount)
    arguments(Input)
        image (:,:) {mustBeNumeric}
        maxoutputcount
    end
    arguments(Output)
        brightspots analysis.image.BrightSpot
    end
    if maxoutputcount < 1
        brightspots=[];
        return
    end
    height=size(image,1);
    width=size(image,2);
    % reduce noise
    averagefilter=fspecial("average",3);
    img=imfilter(image,averagefilter,"replicate");

    % binarize
    localmeanfilter=fspecial("average",2*floor(min([height,width])/16)+1);
    localmean=imfilter(image,localmeanfilter,"replicate");
    img=img-localmean;
    % Matlabが提供する適応的二値化とほぼ同じ(Bladley法)だが
    % adaptthreshではここの係数は最大で0.6程度にしかならない
    % あとどのみちあとあと最大値をガウシアンの最大値と推定したりする都合で
    % 画像を局所平均で減ずるので結局局所平均は必要
    binaryimg=imbinarize(img,localmean*0.7);
    % モルフォロジーオープニングでさらに微小要素を除去
    morphWindow=true(5);
    morphWindow([1,5,21,25])=false;
    binaryimg=imopen(binaryimg,morphWindow);

    pixelgroups=bwconncomp(binaryimg,8);

    areaPixelIdxList={};

    % 各領域について最大値の半分以下になる成分を取り除いて再度二値化
    for i=1:pixelgroups.NumObjects
        idxlist=pixelgroups.PixelIdxList{i};
        detectedvalues=img(idxlist);
        maxofregion=max(detectedvalues);
        greaterThanHalfIdxList=idxlist(detectedvalues > (maxofregion / 2));
        [row,col]=ind2sub([height,width],greaterThanHalfIdxList);
        minrow=min(row);
        localrow=row-(minrow-1);
        localheight=max(localrow);
        mincol=min(col);
        localcol=col-(mincol-1);
        localwidth=max(localcol);
        localbinaryimg=false(localheight,localwidth);
        localbinaryimg(sub2ind([localheight,localwidth],localrow,localcol))=true;
        greaterThanHalfPixelGroups=bwconncomp(localbinaryimg,8);
        for j=1:greaterThanHalfPixelGroups.NumObjects
            [detected_localrow,detected_localcol]=ind2sub([localheight,localwidth],greaterThanHalfPixelGroups.PixelIdxList{j});
            detected_globalrow=detected_localrow+(minrow-1);
            detected_globalcol=detected_localcol+(mincol-1);
            detected_global_linear_idx=sub2ind([height,width],detected_globalrow,detected_globalcol);
            
            areaPixelIdxList=[areaPixelIdxList,detected_global_linear_idx];
        end
    end

    detectedAreaCount=length(areaPixelIdxList);
    % total amount of each pixel value in each connected pixel group
    groupValueSum=zeros(detectedAreaCount);
    for i = 1:detectedAreaCount
        groupValueSum(i)=sum(img(areaPixelIdxList{i}));
    end
    [~,sortingarray]=sort(groupValueSum,'descend');

    spots = analysis.image.BrightSpot.empty;
    for i = 1:min([maxoutputcount detectedAreaCount])
        spots = [spots analysis.image.BrightSpotScore.ValueSum.getBrightSpot(img,areaPixelIdxList{sortingarray(i)})];
    end
    brightspots= spots;
end