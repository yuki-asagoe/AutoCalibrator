function distMat = getDistanceMatrix(pointSet)
    arguments(Input)
        pointSet (:,2) {mustBeNumeric}
    end
    pointCount=size(pointSet,2);
    distMat = zeros(pointCount,pointCount);
    for i=1:pointCount
        for j=(i+1):pointCount
            distMat(i,j)=math.euclideanDistance(pointSet(i,:),pointSet(j,:));
            distMat(j,i)=distMat(i,j);
        end
    end
end