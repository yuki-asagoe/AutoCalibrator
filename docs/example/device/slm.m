% Examples of slm devices

%% devices.slm.SantecSLM200DisplayHosted

% initialize for display 1
slm200 = devices.slm.SantecSLM200DisplayHosted.createForDisplay(1);

% open window for slm
slm200.open();

% get size
height,width = slm200.getPixelArraySize();

% apply phase map (array of double, and the values should be in [0,2pi])
phase = zeros(height,width);
slm200.apply(phase);

% close window
slm200.close();