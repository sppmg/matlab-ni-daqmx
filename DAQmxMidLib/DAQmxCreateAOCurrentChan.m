function taskh = DAQmxCreateAOCurrentChan(lib,taskh,PhysicalChannel,Vmin,Vmax)

%  Creates channel(s) to generate current and adds the channel(s) to the task you specify with taskHandle.

% C functions used:
%  int32 DAQmxCreateAOCurrentChan (TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);


if isempty(taskh)
	taskh=libpointer('voidPtr',taskh);
	err = calllib(lib,'DAQmxCreateTask','',taskh);	% task name set to '', recommended to avoid problems;
	DAQmxCheckError(lib,err);
end


err = calllib(lib,'DAQmxTaskControl',taskh,2); % DAQmx_Val_Task_Verify =2;

% Task will auto start when created.


% create AO voltage channel(s) and add to task
DAQmx_Val_Amps= 10342 ; % unit == amperes
name_channel ='';
%regexprep(PhysicalChannel,'/','_')	% recommended to avoid problems
%Vmin=-10;Vmax=10;

if ~iscell(PhysicalChannel)	% just 1 channel to add to task (maybe no need)
	err = calllib(lib,'DAQmxCreateAOCurrentChan',taskh, ...
		PhysicalChannel,name_channel,Vmin,Vmax,DAQmx_Val_Amps,'');
	DAQmxCheckError(lib,err);
else % more than 1 channel to add to task
	if length(Vmin)==1
		Vmin=repmat(Vmin,1,numel(PhysicalChannel));
	end
	if length(Vmax)==1
		Vmax=repmat(Vmax,1,numel(PhysicalChannel));
	end
	for m = 1:numel(PhysicalChannel)
		err = calllib(lib,'DAQmxCreateAOCurrentChan',taskh, ...
		PhysicalChannel{m},name_channel,Vmin(m),Vmax(m),DAQmx_Val_Amps,'');
		DAQmxCheckError(lib,err);

	end
end
%err = calllib(lib,'DAQmxStopTask',taskh);
