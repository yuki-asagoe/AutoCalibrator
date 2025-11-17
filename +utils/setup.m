camera = devices.camera.AndorCamera();
camera.open();
slm = devices.slm.SantecSLM200DisplayHosted.createForDisplay(2);
slm.open();
etl = devices.etl.OptotuneLensDriver("COM6");
etl.open();