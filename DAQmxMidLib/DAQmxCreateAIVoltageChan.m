function taskh = DAQmxCreateAIVoltageChan(lib,taskh,PhysicalChannel,Vmin,Vmax)

%  Purpose
%  Creates channel(s) to measure voltage and adds the channel(s) to the task you specify with taskHandle. If your measurement requires the use of internal excitation or you need the voltage to be scaled by excitation, call DAQmxCreateAIVoltageChanWithExcit.
%
%  C function
%  int32 DAQmxCreateAIVoltageChan (TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], int32 terminalConfig, float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);


%checked
% this function creates a task and adds analog input channel(s) to the task
% C functions used:
%	int32 DAQmxCreateTask (const char taskName[],TaskHandle *taskHandle);
%	int32 DAQmxCreateAIVoltageChan (TaskHandle taskHandle,const char physicalChannel[],
%		const char nameToAssignToChannel[],int32 terminalConfig,float64 minVal,
%		float64 maxVal,int32 units,const char customScaleName[]);
%	int32 DAQmxTaskControl (TaskHandle taskHandle,int32 action);
% 

if isempty(taskh)
	taskh=libpointer('voidPtr',taskh);
	err = calllib(lib,'DAQmxCreateTask','',taskh);	% task name set to '', recommended to avoid problems;
	DAQmxCheckError(lib,err);
end

 
err = calllib(lib,'DAQmxTaskControl',taskh,2); % DAQmx_Val_Task_Verify =2;

% Task will auto start when created.


% create AI voltage channel(s) and add to task
DAQmx_Val_RSE =10083;  % RSE
DAQmx_Val_Volts= 10348; % measure volts
name_channel = '';

if ~iscell(PhysicalChannel)	% just 1 channel to add to task (maybe no need)
	err = calllib(lib,'DAQmxCreateAIVoltageChan',taskh,...
		PhysicalChannel,name_channel,...
		DAQmx_Val_RSE,Vmin,Vmax,DAQmx_Val_Volts,'');
	DAQmxCheckError(lib,err);
else % more than 1 channel to add to task
	if length(Vmin)==1
		Vmin=repmat(Vmin,1,numel(PhysicalChannel));
	end
	if length(Vmax)==1
		Vmax=repmat(Vmax,1,numel(PhysicalChannel));
	end
	
	for m = 1:numel(PhysicalChannel)
		err = calllib(lib,'DAQmxCreateAIVoltageChan',taskh,...
			PhysicalChannel{m},name_channel,...
			DAQmx_Val_RSE,Vmin(m),Vmax(m),DAQmx_Val_Volts,'');
		DAQmxCheckError(lib,err);
	end
end
%err = calllib(lib,'DAQmxStopTask',taskh);
