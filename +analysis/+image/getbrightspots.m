function brightspots = getbrightspots(grayscaleimage, maxoutputcount)
    arguments
        grayscaleimage (:,:) uint8
    end
    arguments (Output)
        brightspots (:) analysis.image.BrightSpot
    end
    if maxoutputcount < 1
        brightspots=[];
        return
    end
    [sizey,sizex]=size(grayscaleimage)
    thresh=adaptthresh(grayscaleimage, 0.3,'Statistics','gaussian');
    binaryimage=imbinarize(grayscaleimage,thresh);
    pixelgroups=bwconncomp(binaryimage,8);

    grayscaleimagelinear=grayscaleimage(:)
    % total amount of each pixel value in each connected pixel group
    groupValueSum=zeros(pixelgroups.NumObjects);
    for i = 1:pixelgroups.NumObjects
        groupValueSum(i)=sum(grayscaleimagelinear(pixelgroups.PixelIdxList(i)));
    end
    [sortedGroupValue,sortingarray]=sort(groupValueSum);
    sortedPixelIdx=sort(pixelgroups.PixelIdxList,sortingarray);

    spots = [];
    for i = 1:min([maxoutputcount pixelgroups.NumObjects])
        spots = [spots analysis.image.BrightSpot.getFromImageAndPixels(grayscaleimage,ind2sub(size(grayscaleimage),sortedPixelIdx(i)))];
    end
    brightspots= spots
end