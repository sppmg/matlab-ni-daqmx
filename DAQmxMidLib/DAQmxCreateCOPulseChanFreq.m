function taskh = DAQmxCreateCOPulseChanFreq (lib, taskh, PhysicalChannel, freq, dutyCycle, varargin)

%  Purpose
%  Creates channel(s) to generate digital pulses that freq and dutyCycle define and adds the channel to the task you specify with taskHandle. The pulses appear on the default output terminal of the counter unless you select a different output terminal.
%
%  C function prototype
%  int32 DAQmxCreateCOPulseChanFreq (TaskHandle taskHandle, const char counter[], const char nameToAssignToChannel[], int32 units, int32 idleState, float64 initialDelay, float64 freq, float64 dutyCycle);
	% DAQmx_Val_Hz = 10373
	% DAQmx_Val_High = 10192
	% DAQmx_Val_Low = 10214

specify_idleState = false ;
specify_initialDelay = false ;
switch nargin
	case 6
		specify_idleState = true ;
	case 7
		specify_idleState = true ;
		specify_initialDelay = true ;
end
if specify_idleState
	if varargin{1} == 10192 || varargin{1} == 10214
		idleState = varargin{1};
	else
		error('idleState must be 10192 (high) or 10214 (low)');
	end
else
	idleState = 10214 ; % default = low
end
if specify_initialDelay
	if isfloat(varargin{2})
		initialDelay = varargin{2} ;
	else
		error('initialDelay must be float');
	end
else
	initialDelay = 0 ;
end


if isempty(taskh)
	taskh=libpointer('voidPtr',taskh);
	err = calllib(lib,'DAQmxCreateTask','',taskh);	% task name set to '', recommended to avoid problems;
	DAQmxCheckError(lib,err);
end

err = calllib(lib,'DAQmxTaskControl',taskh,2); % DAQmx_Val_Task_Verify =2;
% create channel(s) and add to task
if ~iscell(PhysicalChannel)	% just 1 channel name to add to task
	err = calllib(lib, 'DAQmxCreateCOPulseChanFreq', taskh, PhysicalChannel, '', 10373, idleState, initialDelay, freq, dutyCycle);
	DAQmxCheckError(lib,err);
else % more than 1 channel name to add to task
	for name_i = 1:numel(PhysicalChannel)
		err = calllib(lib, 'DAQmxCreateCOPulseChanFreq', taskh, PhysicalChannel{name_i}, '', 10373, idleState, initialDelay, freq, dutyCycle);
		DAQmxCheckError(lib,err);
	end
end
