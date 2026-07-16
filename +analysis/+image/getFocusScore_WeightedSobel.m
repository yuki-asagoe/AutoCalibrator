function focusScore = getFocusScore_WeightedSobel(image)
    arguments(Input)
        image (:,:) {mustBeNumeric}
    end
    arguments(Output)
        focusScore double
    end

    thresh = adaptthresh(image, 0.01,'Statistic','gaussian');
    weight = abs(image - thresh);
    sobelX = fspecial("sobel");
    xGrad = weight.*imfilter(image,sobelX);
    sobelY = sobelX.';
    yGrad = weight.*imfilter(image,sobelY);
    focusScore = var(sqrt(xGrad.*xGrad + yGrad.*yGrad),1,'all');
end