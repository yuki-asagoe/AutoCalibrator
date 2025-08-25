function GUI_util_detectBrightSpots(calibGUI)
    handles=guidata(calibGUI);
    if ~all(isfield(handles,"shiftx"),isfield(handles,"shifty"))
        return;
    end
    %opticalX=handles.shiftx;
    %opticalY=handles.shifty;
    
    [filename, filepath] = uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.jpg'});
    if(filename == 0)
        return;
    end

    image=imread(append(filepath,filename));
    if size(image,3) == 3
        image= rgb2gray(image);
    end

    brightSpots = analysis.image.getbrightspots(image,6);

    % opticalPositions=[opticalX;opticalY]';
    originalPositions = getSpotPointOnScreenFromTexts(handles);
    inImagePotisions=[brightSpots.CenterX;brightSpots.CenterY]';

    sortedInImagePositions=analysis.image.estimateRespondPointPairs(originalPositions,inImagePotisions);

    feedbackInImagePositionsToTextFiled(handles,sortedInImagePositions);
    showImageWithBrightSpotMarks(image,sortedInImagePositions);
end

function feedbackInImagePositionsToTextFiled(handles,positions)
    arguments(Input)
        handles
        positions (6,2) {mustBeNumeric}
    end
    set(handles.x1,'String',positions(1,1));
    set(handles.x2,'String',positions(2,1));
    set(handles.x3,'String',positions(3,1));
    set(handles.x4,'String',positions(4,1));
    set(handles.x5,'String',positions(5,1));
    set(handles.x6,'String',positions(6,1));
    set(handles.y1,'String',positions(1,2));
    set(handles.y2,'String',positions(2,2));
    set(handles.y3,'String',positions(3,2));
    set(handles.y4,'String',positions(4,2));
    set(handles.y5,'String',positions(5,2));
    set(handles.y6,'String',positions(6,2));
end

function inimagePositions=getSpotPointOnScreenFromTexts(handles)
    spotscreen=handles.image;
    inimagePositions = [ ...
        findobj(spotscreen,'String','1').Position(1:2); ...
        findobj(spotscreen,'String','2').Position(1:2); ...
        findobj(spotscreen,'String','3').Position(1:2); ...
        findobj(spotscreen,'String','4').Position(1:2); ...
        findobj(spotscreen,'String','5').Position(1:2); ...
        findobj(spotscreen,'String','6').Position(1:2) ...
    ];
end

function showImageWithBrightSpotMarks(image,brightspots)
    arguments(Input)
        image (:,:) {mustBeInteger}
        brightspots (:,2)
    end
    [sizey,sizex]=size(image);
    spotCount=size(brightspots,1);
    for i = 1:spotCount
        x=brightspots(i,1);
        y=brightspots(i,2);
        radius=3;
        if(x-radius < 1 || sizex < x+radius)
            continue;
        end
        if(y-radius < 1 || sizey < y+radius)
            continue;
        end
        image(y-radius:y+radius,x-radius:x+radius)=255;
    end

    figure;
    imshow(image);

    for i = 1:spotCount
        text(round(brightspots(i,1)),round(brightspots(i,2)),int2str(i),Color=[1,1,0]);
    end
end