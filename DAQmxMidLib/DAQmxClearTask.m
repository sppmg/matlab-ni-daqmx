function DAQmxClearTask(lib,taskh)
%stop task
err = calllib(lib,'DAQmxStopTask',taskh);
%% clear all tasks
[err] = calllib(lib,'DAQmxClearTask',taskh);



%% unload library
%if libisloaded(lib) % checks if library is loaded
%	unloadlibrary(lib)
%end
