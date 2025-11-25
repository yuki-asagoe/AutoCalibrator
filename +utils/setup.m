andorcamera = devices.camera.andor.AndorCamera();
andorcamera.open();
camera=devices.camera.BackgroundRemoveWrappedCamera(andorcamera);
slm = devices.slm.SantecSLM200DisplayHosted.createForDisplay(2);
slm.open();
etl = devices.etl.OptotuneLensDriver("COM6");
etl.open();

zshift=tools.calibgui.readSphericalComp("save\SLM1sphericalComp.mat",920*10^(-6),200/25,8*10^(-3));
calibrator = calibration.PositionCalibrator.loadFrom("save/pos_calibrator.csv");
% calibrator=calibration.PositionCalibrator.loadByCompatibleCSVFormatForNormalPhaseMapFrom("save\SLM1zoom1calidata.csv",920*10^(-3),8*10^3);

% [value,imageatfocus,scores]=calibration.scanFocusByETL(camera,slm,etl,x,y,zshift,8*10^3,920,true);
% pc=calibration.scanAffineTransformParameter(camera,slm,calibration.ZDistanceInfo(zshift),8*10^3,920,30,[x,y]);

pause(1);

camera.updateBackground();

% map=devices.slm.PhaseMap(1920,1200,8,8,8*10^3,920);