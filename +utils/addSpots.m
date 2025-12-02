function addSpots(phasemap,calibrator,points)
    arguments
        phasemap devices.slm.PhaseMap
        calibrator calibration.Calibrator
        points (:,2) {mustBeNumeric}
    end
    for i = 1:size(points,1)
        [x,y,z,power]=calibrator.calibrate(points(i,1),points(i,2),0);
        phasemap.addSpot(x,y,z,sqrt(power));
    end
end

