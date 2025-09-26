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
    averagefilter=fspecial("average",3);
    img=imfilter(grayscaleimage,averagefilter);
    thresh=adaptthresh(img, 0.01,'Statistic','gaussian');
    binaryimg_gauss=imbinarize(img,thresh);
    pixelgroups=bwconncomp(binaryimg_gauss,8);

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