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
    load(filename);
    data = compendata
    clear compendata;

    deltaPixelX_mm = slmpixelpitch_mm;
    deltaPixelY_mm = slmpixelpitch_mm;
    width = size(data,2);
    height = size(data,1);
    
    zshift_mm = (log(data(1,1)) * wavelength_mm * focallength_mm^2 / (pi * 1i * (-width/2 * deltaPixelX_mm)^2 * (-height/2 * deltaPixelY_mm)^2 ));
    zshift_um = zshift_mm * 10^3;
end