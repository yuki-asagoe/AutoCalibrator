function brightspots = getbrightspots(image, maxoutputcount)
    arguments (Input)
        image (:,:) {mustBeNumeric}
        maxoutputcount
    end
    arguments (Output)
        brightspots (1,:) analysis.image.BrightSpot
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
    stde=std(image,0,"all");
    binaryimg=imbinarize(img,localmean+stde);

    pixelgroups=bwconncomp(binaryimg,8);

    areaPixelIdxList={};

    % 各領域について最大値の半分以下になる成分を取り除いて再度二値化
    for i=1:pixelgroups.NumObjects
        idxlist=pixelgroups.PixelIdxList{i};
        detectedvalues=image(idxlist);
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
        localbinaryimg(localrow,localcol)=true;
        greaterThanHalfPixelGroups=bwconncomp(localbinaryimg,8);
        areaPixelIdxList=[areaPixelIdxList,greaterThanHalfPixelGroups.PixelIdxList];
    end

    detectedAreaCount=length(areaPixelIdxList);
    % total amount of each pixel value in each connected pixel group
    groupValueSum=zeros(detectedAreaCount);
    for i = 1:detectedAreaCount
        groupValueSum(i)=sum(image(pixelgroups.PixelIdxList{i}));
    end
    [~,sortingarray]=sort(groupValueSum,'descend');

    spots = [];
    for i = 1:min([maxoutputcount pixelgroups.NumObjects])
        spots = [spots analysis.image.BrightSpotScore.ValueSum.getBrightSpot(image,pixelgroups.PixelIdxList{sortingarray(i)})];
    end
    brightspots= spots;
end