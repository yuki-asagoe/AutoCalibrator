function calibrator = getCalibrationInfo(vid, slm, printprogress, focallength_um, wavelength_nm)
    arguments
        slm slm.PhaseSLM
        focallength_um {mustBeNumeric}
        wavelength_nm {mustBeNumeric}
        printprogress logical
    end
    arguments(Output)
        calibrator calibration.Calibrator
    end
    start(vid);

    [zdistanceinfo, resultimageofzscan] = calibration.scanFocusAlignZ(vid, slm, 0, 0, ,focallength_um, wavelength_nm);

    positioncalibrator = calibration.calculateAffineTransformParameter(vid,slm,zdistanceinfo,focallength_um,wavelength_nm);

    weightmap = calibration.scanWeightMap(vid,slm,zdistanceinfo,positioncalibrator,focallength_um,wavelength_nm);

    stop(vid);

    calibrator = calibration.Calibrator(zdistanceinfo,positioncalibrator,weightmap);
end