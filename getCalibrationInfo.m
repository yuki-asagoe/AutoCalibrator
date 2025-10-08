function calibrator = getCalibrationInfo(vid, slm, printprogress, focallength_um, wavelength_nm)
    arguments (Input)
        vid
        slm slm.PhaseSLM
        printprogress logical
        focallength_um {mustBeNumeric}
        wavelength_nm {mustBeNumeric}
    end
    arguments(Output)
        calibrator calibration.Calibrator
    end
    start(vid);

    % zscanlistの -40:2:40は適当
    [zdistanceinfo, ~] = calibration.scanFocusAlignZ(vid, slm, 0, 0, -40:2:40,focallength_um, wavelength_nm);

    positioncalibrator = calibration.scanAffineTransformParameter(vid,slm,zdistanceinfo,focallength_um,wavelength_nm);

    weightmap = calibration.scanWeightMap(vid,slm,zdistanceinfo,positioncalibrator,focallength_um,wavelength_nm);

    stop(vid);

    calibrator = calibration.Calibrator(zdistanceinfo,positioncalibrator,weightmap);
end