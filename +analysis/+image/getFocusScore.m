function focusScore = getFocusScore(image)
    arguments(Input)
        image (:,:) {mustBeNumeric}
    end
    arguments(Output)
        focusScore double
    end
    % 輝点検出と同じように二値化して背景の平均輝度と輝点の平均輝度を比較する
    averagefilter=fspecial("average",3);
    filteredimg=imfilter(image,averagefilter);
    thresh=adaptthresh(filteredimg, 0.01,'Statistic','gaussian');
    binaryimg=imbinarize(filteredimg,thresh);
    
    focusScore=mean(image(binaryimg),"all")/mean(image(~binaryimg),"all");
end