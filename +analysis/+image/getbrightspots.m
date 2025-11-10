function brightspots = getbrightspots(image, maxoutputcount,scoretype)
    arguments (Input)
        image (:,:) {mustBeNumeric}
        maxoutputcount
        scoretype analysis.image.BrightSpotScore
    end
    arguments (Output)
        brightspots (1,:) analysis.image.BrightSpot
    end
    if maxoutputcount < 1
        brightspots=[];
        return
    end
    averagefilter=fspecial("average",3);
    img=rescale(imfilter(image,averagefilter));
    thresh=adaptthresh(img, 0.01,'Statistic','gaussian');
    binaryimg_gauss=imbinarize(img,thresh);
    pixelgroups=bwconncomp(binaryimg_gauss,8);

    if scoretype == analysis.image.BrightSpotScore.ValueSum
        % total amount of each pixel value in each connected pixel group
        groupValueSum=zeros(pixelgroups.NumObjects);
        for i = 1:pixelgroups.NumObjects
            groupValueSum(i)=sum(image(pixelgroups.PixelIdxList{i}));
        end
        [~,sortingarray]=sort(groupValueSum,'descend');

        spots = [];
        for i = 1:min([maxoutputcount pixelgroups.NumObjects])
            spots = [spots scoretype.getBrightSpot(image,pixelgroups.PixelIdxList{sortingarray(i)})];
        end
        brightspots= spots;
    else
        spots = [];
        for i = 1:pixelgroups.NumObjects
            spots = [spots scoretype.getBrightSpot(image,pixelgroups.PixelIdxList{i})];
        end
        [~,sortingarray]=sort([spots.Score],'descend');
        brightspots=spots(sortingarray(1:min([maxoutputcount,length(spots)])));
    end
end