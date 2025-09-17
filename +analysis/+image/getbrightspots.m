function brightspots = getbrightspots(grayscaleimage, maxoutputcount)
    arguments (Input)
        grayscaleimage (:,:) uint8
        maxoutputcount
    end
    arguments (Output)
        brightspots (1,:) analysis.image.BrightSpot
    end
    if maxoutputcount < 1
        brightspots=[];
        return
    end
    thresh=adaptthresh(grayscaleimage, 0.0001,'Statistic','mean');
    binaryimg_mean=imbinarize(grayscaleimage,thresh);
    thresh=adaptthresh(grayscaleimage, 0.0001,'Statistic','gaussian');
    binaryimg_gauss=imbinarize(grayscaleimage,thresh);
    binaryimage=binaryimg_mean & binaryimg_gauss;
    pixelgroups=bwconncomp(binaryimage,8);

    % total amount of each pixel value in each connected pixel group
    groupValueSum=zeros(pixelgroups.NumObjects);
    for i = 1:pixelgroups.NumObjects
        groupValueSum(i)=sum(grayscaleimage(pixelgroups.PixelIdxList{i}));
    end
    [~,sortingarray]=sort(groupValueSum,'descend');

    spots = [];
    for i = 1:min([maxoutputcount pixelgroups.NumObjects])
        spots = [spots analysis.image.BrightSpot.getFromImageAndPixels(grayscaleimage,pixelgroups.PixelIdxList{sortingarray(i)})];
    end
    brightspots= spots;
end