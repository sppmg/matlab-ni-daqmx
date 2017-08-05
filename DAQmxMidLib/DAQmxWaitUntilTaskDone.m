function DAQmxWaitUntilTaskDone(lib,taskh, varargin)
switch nargin
	case 2
		timeToWait = -1 ; % DAQmx_Val_WaitInfinitely
	case 3 
		timeToWait = varargin{1} ;
	otherwise
		error('To many argument.');
end
calllib(lib,'DAQmxWaitUntilTaskDone', taskh, timeToWait);