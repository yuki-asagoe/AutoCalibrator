function dist=euclideanDistance(point1,point2)
    arguments(Input)
        point1 (1,2) {mustBeNumeric}
        point2 (1,2) {mustBeNumeric}
    end
    dist=sqrt((point1(1)-point2(1))^2+(point1(2)-point2(2))^2);
end