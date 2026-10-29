% Examples of etl devices

%% devices.etl.OptotuneLensDriver

% Initialize, the serial port name should be change in each environment
optotuneETL = devices.etl.OptotuneLensDriver("COM1");

% start connection
optotuneETL.open();

% set its current by raw value in [-4096,4096)
optotuneETL.setCurrentRaw(100);

% set its current in milli Ampere, but first call take a little time to finish for
% initialization
optotuneETL.setCurrent(0.1);

% close connection
optotuneETL.close();