function taskh = DAQmxCreateAICurrentChan(lib,taskh,PhysicalChannel,Vmin,Vmax)

%  Purpose
%  Creates channel(s) for current measurement and adds the channel(s) to the task you specify with taskHandle. 
%
%  C function
%  int32 DAQmxCreateAICurrentChan (TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], int32 terminalConfig, float64 minVal, float64 maxVal, int32 units, int32 shuntResistorLoc, float64 extShuntResistorVal, const char customScaleName[]);


if isempty(taskh)
	taskh=libpointer('voidPtr',taskh);
	err = calllib(lib,'DAQmxCreateTask','',taskh);	% task name set to '', recommended to avoid problems;
	DAQmxCheckError(lib,err);
end


err = calllib(lib,'DAQmxTaskControl',taskh,2); % DAQmx_Val_Task_Verify =2;

% Task will auto start when created.


% create AI voltage channel(s) and add to task
DAQmx_Val_RSE = 10083 ;  % RSE
DAQmx_Val_Amps= 10342 ; % unit == amperes
name_channel = '';
DAQmx_Val_Internal = 10200
shuntResistorLoc = DAQmx_Val_Internal ;
extShuntResistorVal = 0 ; % no extShuntResistor

if ~iscell(PhysicalChannel)	% just 1 channel to add to task (maybe no need)
	err = calllib(lib,'DAQmxCreateAICurrentChan',taskh, ...
		PhysicalChannel,name_channel, ...
		DAQmx_Val_RSE,Vmin,Vmax,DAQmx_Val_Amps, ...
		shuntResistorLoc, extShuntResistorVal, '');
	DAQmxCheckError(lib,err);
else % more than 1 channel to add to task
	if length(Vmin)==1
		Vmin=repmat(Vmin,1,numel(PhysicalChannel));
	end
	if length(Vmax)==1
		Vmax=repmat(Vmax,1,numel(PhysicalChannel));
	end

	for m = 1:numel(PhysicalChannel)
		err = calllib(lib,'DAQmxCreateAICurrentChan',taskh,...
			hysicalChannel,name_channel, ...
			DAQmx_Val_RSE,Vmin,Vmax,DAQmx_Val_Amps, ...
			shuntResistorLoc, extShuntResistorVal, '');
		DAQmxCheckError(lib,err);
	end
end
%err = calllib(lib,'DAQmxStopTask',taskh);


end
