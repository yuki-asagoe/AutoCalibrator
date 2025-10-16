function zshift_um = readSphericalComp(filename,wavelength_mm,focallength_mm,slmpixelpitch_mm)
    arguments(Input)
        filename
        wavelength_mm % refered as lambda in original code
        focallength_mm % refered as f in original code
        slmpixelpitch_mm % refered as pixelSize in original code
    end
    arguments(Output)
        zshift_um {mustBeNumeric}
    end
    load(filename,"compendata");
    data = compendata;
    clear compendata;

    deltaPixelX_mm = slmpixelpitch_mm;
    deltaPixelY_mm = slmpixelpitch_mm;
    width = size(data,2);
    height = size(data,1);
    centerX=width/2+1;
    centerY=height/2+1;
    
    %rowOfCenter=data(centerY,:);
    %zshift_mm = (log(rowOfCenter) * wavelength_mm * focallength_mm^2 ./ (pi * 1i * (((-width/2:1:(width/2-1)) * deltaPixelX_mm).^2 + (0 * deltaPixelY_mm).^2 )));
    
    %ごちゃごちゃしようと思ったけど中心の一つとなりの要素を計算するだけで十分だった
    zshift_mm= log(data(centerY,centerX+1)) * wavelength_mm * focallength_mm^2 / (pi * 1i * ((1 * deltaPixelX_mm).^2 + (0 * deltaPixelY_mm).^2) );
    
    zshift_um = real(zshift_mm) * 10^3;
end