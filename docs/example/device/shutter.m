% Examples of shutter devices

%% devices.shutter.thorlabs.SC30

% Initialize
% The serial port name should be changed in each environment
sc30 = devices.shutter.thorlabs.SC30("COM1");
% Close connection, this should be also called automatically
% when it's deleted from workspace like `delete sc30`, but you
% should call this explicitly as long as possible
sc30.dispose();

% --- Manual control ---

% first change mode to manual control
sc30.setMode("Manual");

% open/close shutter ch1, fails when the shutter is not manual mode
sc30.openShutter();
sc30.closeShutter();

% possible to select shutter channel by passing parameter
sc30.openShutter(1);
sc30.openShutter(2);

% passing full parameters
sc30.setShutter(1,true);
sc30.setShutter(2,false);

% --- Synchronization ---
% SC30 allows to change state of ch2 shutter along with ch1

% enable/disable
sc30.enableSync();  % equals `sc30.setSynchronization(true);`
sc30.disableSync(); % equals `sc30.setSynchronization(false);`

% change synchronization mode, it needs 2 params.
% the mode you want to change sync mode
% and the mode you want to set acutally.
sc30.setSyncMode("Manual","Equal");
sc30.setSyncMode("Internal","Inverted");
sc30.setSyncMode("External","Delayed");

% delay mode need additional parameter `delay(unit:ms)`
sc30.setSyncDelay("External",200);

% there are some functions to set these parameters in single call
% for example, this below does set sync mode to delayed and delaytime, then
% enable sync in one line
sc30.enableSyncDelayed("Internal",100);

% --- Internal control ---
% Internal mode provides features to repeat pattern of open/close time
% automatically

% first it needs information of demanded pattern
% this sentence means to set following pattern to ch1
% repeating 5 times [open time : 200ms -> close time : 50ms]
sc30.setModeParameters("Internal",1,200,50,5);
% or this equals sentence above
sc30.setInternalModeParameters(1,200,50,5);

% start internal mode operation of ch1
% this change the mode automatically to internal, so you don't have to need
% `setMode` function, of course there is no problem if you call it
sc30.startInternalModeControl(1);
% The sentence equals these lines
sc30.setMode("Internal");
sc30.enable(1,true);

% When you want to stop the internal control explicitly, you can use this
% function
sc30.stopControl(1);
% or
sc30.enable(1,false);

% possible to check whether the internal control is working by `isEnabled`
if sc30.isEnabled(1)
    disp("Auto control working");
end