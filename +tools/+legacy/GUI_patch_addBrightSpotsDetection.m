function patchedGUI = GUI_patch_addBrightSpotsDetection(calibrationGUI)
    arguments(Input)
        calibrationGUI matlab.ui.Figure
    end
    
    uibutton(...
        calibrationGUI, ...
        "Position",[0,0,120,22], ...
        "Text","Patch:Auto Detect", ...
        "ButtonPushedFcn", @onAutoDetectButtonPressed ...
    );

    patchedGUI = calibrationGUI;
end

function onAutoDetectButtonPressed(src,~)
    handles=guidata(src.Parent);
    [filename, filepath] = uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.jpg'});
    opticalX=handles.shiftx;
    opticalY=handles.shifty;
    
    if(filename == 0)
        return;
    end

    image=imread(filepath);
    if size(image,3) == 3
        image= rgb2gray(image);
    end

    brightSpots = analysis.image.getbrightspots(image,6);

    opticalPositions=[opticalX,opticalY];
    inImagePotisions=[brightSpots.CenterX,brightSpots.CenterY];

    [sortedInImagePositions, ~]=analysis.image.estimateRespondPointPairs(opticalPositions,inImagePotisions);

    feedbackInImagePositionsToTextFiled(handles,sortedInImagePositions);
    showImageWithBrightSpotMarks(gray2rgb(image));
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

function showImageWithBrightSpotMarks(image,brightspots)
    arguments(Input)
        image (:,:,3) {mustBeInteger}
        brightspots (:,1) analysis.image.BrightSpot
    end
    [sizey,sizex]=size(image);
    for i = 1:size(brightspots)
        spot=brightspots(i);
        x=round(spot.CenterX);
        y=round(spot.CenterY);
        radius=3;
        if(x-radius < 1 || sizex < x+radius)
            continue;
        end
        if(y-radius < 1 || sizey < y+radius)
            continue;
        end
        image(y-radius:y+radius,x-radius:x+radius,:)=[255,255,0];
    end

    figure;
    imshow(image);

    for i = 1:size(brightspots)
        x=round(spot.CenterX);
        y=round(spot.CenterY);
        text(x,y,0,int2str(i),Color=[1,1,0]);
    end
end