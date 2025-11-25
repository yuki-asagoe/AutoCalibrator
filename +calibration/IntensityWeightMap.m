classdef IntensityWeightMap
    properties (Access = public)
        WeightMap (:,:) {mustBeNumeric}
    end
    properties (Access = private)
        % parameter to map position to actual weight map index
        % for example, position [x,y] = [MinX,MinY] means WeightMap(1,1) 
        MinX {mustBeNumeric}
        MinY {mustBeNumeric}
        MaxX {mustBeNumeric}
        MaxY {mustBeNumeric}
    end

    methods (Access = public)
        function obj = IntensityWeightMap(weightmap,minx,miny,maxx,maxy)
            arguments
                weightmap (:,:) {mustBeNumeric}
                minx,
                miny,
                maxx,
                maxy
            end
            obj.WeightMap=weightmap;
            obj.MinX=min([minx,maxx]);
            obj.MaxX=max([minx,maxx]);
            obj.MinY=min([miny,maxy]);
            obj.MaxY=max([miny,maxy]);
        end

        function saveTo(obj, filename)
            subdatarow=zeros(1,size(obj.WeightMap,2));
            subdatarow(1:4)=[obj.MinX,obj.MinY,obj.MaxX,obj.MaxY];
            writematrix([subdatarow;obj.WeightMap], filename)
        end

        % Save in csv fomat that has been used by previous code : calibrationGUI
        function saveInCompatibleCSVFormat(obj, filename)
            outputsize = 512;
            validation.mustBeSquareMatrix(obj.WeightMap);
            outputWeight=zeros([outputsize,outputsize]);;
            for x=1:outputsize
                for y=1:outputsize
                    outputWeight(y,x)=obj.getWeight(x,y);
                end
            end
            csvwrite(filename,outputWeight);
        end

        function weight = getWeight(obj,x,y)
            [ysize,xsize] = size(obj.WeightMap);
            xindex = clip(0.5 + xsize * (clip(x,obj.MinX,obj.MaxX) - obj.MinX) / (obj.MaxX-obj.MinX),1,xsize);
            yindex = clip(0.5 + ysize * (clip(y,obj.MinY,obj.MaxY) - obj.MinY) / (obj.MaxY-obj.MinY),1,ysize);

            floorx=floor(xindex);
            ceilx=ceil(xindex);
            partialx = xindex - floorx;
            floory=floor(yindex);
            ceily=ceil(yindex);
            partialy = yindex - floory;

            weight = math.lerp( ...
                partialy, ...
                math.lerp(partialx,obj.WeightMap(floory,floorx),obj.WeightMap(floory,ceilx)), ...
                math.lerp(partialx,obj.WeightMap(ceily,floorx),obj.WeightMap(ceily,ceilx)) ...
            );
        end

    end

    methods (Access = public, Static)
        function obj = loadFrom(filename)
            savematrix=importdata(filename);
            obj = calibration.IntensityWeightMap(savematrix(2:end,:),savematrix(1,1),savematrix(1,2),savematrix(1,3),savematrix(1,4));
        end
    end
end
