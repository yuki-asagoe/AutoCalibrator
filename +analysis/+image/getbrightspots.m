function brightspotpoints = getbrightspots(grayscaleimage)
    arguments
        grayscaleimage uint8
    end
    thresh=adaptthresh(grayscaleimage, 0.3,'Statistics','gaussian');
    binaryimage=imbinarize(grayscaleimage,thresh);
    pixelgroups=bwconncomp(binaryimage,8);

    % total amount of each pixel value in each connected pixel group
    groupValueSum=zeros(pixelgroups.NumObjects);

end