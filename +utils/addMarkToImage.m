function addMarkToImage(points,color)
    arguments
        points (:,2) {mustBeNumeric}
        color = "yellow"
    end
    
    for i = 1:size(points,1)
        text(points(i,1),points(i,2),string(i),"color",color);
    end
end

