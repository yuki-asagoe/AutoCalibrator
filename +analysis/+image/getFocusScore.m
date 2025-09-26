function focusScore = getFocusScore(grayscaleimage)
    arguments(Input)
        grayscaleimage (:,:) uint8
    end
    arguments(Output)
        focusScore double
    end
    % 輝点検出と同じように二値化して背景の平均輝度と輝点の平均輝度を比較する
    averagefilter=fspecial("average",3);
    filteredimg=imfilter(grayscaleimage,averagefilter);
    thresh=adaptthresh(filteredimg, 0.01,'Statistic','gaussian');
    binaryimg=imbinarize(filteredimg,thresh);
    
    focusScore=mean(grayscaleimage(binaryimg),"all")/mean(grayscaleimage(~binaryimg),"all");
end