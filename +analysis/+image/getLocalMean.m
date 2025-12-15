function localmean = getLocalMean(image,kernelsize)
    arguments(Input)
        image (:,:) {mustBeNumeric}
        kernelsize = -1
    end
    height = size(image,1);
    width = size(image,2);
    if kernelsize < 0
        kernelsize = 2*floor(min([height,width])/16)+1;
    elseif mod(kernelsize,2) == 0
        kernelsize=kernelsize+1;
    end 
    kernel=ones(kernelsize)/(kernelsize^2);
    localmean = imfilter(image,kernel);
end