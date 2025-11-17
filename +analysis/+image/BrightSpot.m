classdef BrightSpot
    properties (Access = public)
        CenterX
        CenterY
        % Unit [pixel^2]
        Area
        SumOfPixelValue
        ScoreType analysis.image.BrightSpotScore
        Score {mustBeNumeric}
    end

    methods (Access = public)
        function obj = BrightSpot(centerx,centery,area,pixelsum,scoretype,score)
            obj.CenterX=centerx;
            obj.CenterY=centery;
            obj.Area=area;
            obj.SumOfPixelValue=pixelsum;
            obj.ScoreType=scoretype;
            obj.Score=score;
        end
    end
end