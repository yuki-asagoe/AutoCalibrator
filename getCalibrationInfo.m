function calibrator = getCalibrationInfo(camera, slm, printprogress, focallength_um, wavelength_nm)
    arguments (Input)
        camera
        slm slm.PhaseSLM
        printprogress logical
        focallength_um {mustBeNumeric}
        wavelength_nm {mustBeNumeric}
    end
    arguments(Output)
        calibrator calibration.Calibrator
    end
    start(camera);

    % zscanlistの -40:2:40は適当
    [zdistanceinfo, ~] = calibration.scanFocusAlignZ(camera, slm, 0, 0, -40:2:40,focallength_um, wavelength_nm);

    positioncalibrator = calibration.scanAffineTransformParameter(camera,slm,zdistanceinfo,focallength_um,wavelength_nm);

    weightmap = calibration.scanWeightMap(camera,slm,zdistanceinfo,positioncalibrator,focallength_um,wavelength_nm);

    stop(camera);

    calibrator = calibration.Calibrator(zdistanceinfo,positioncalibrator,weightmap);
end