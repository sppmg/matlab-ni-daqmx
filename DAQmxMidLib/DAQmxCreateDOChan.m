function taskh = DAQmxCreateDOChan(lib,taskh,PhysicalChannel)
% this function creates a task and add a digital generate channel(s) to the task
% C functions used:
%	int32 DAQmxCreateTask (const char taskName[],TaskHandle *taskHandle);
%	
%   int32 DAQmxCreateDOChan (TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);

if isempty(taskh)
	taskh=libpointer('voidPtr',taskh);
	err = calllib(lib,'DAQmxCreateTask','',taskh);	% task name set to '', recommended to avoid problems;
	DAQmxCheckError(lib,err);
end

 
err = calllib(lib,'DAQmxTaskControl',taskh,2); % DAQmx_Val_Task_Verify =2;

% Task will auto start when created.


% create DO voltage channel(s) and add to task



DAQmx_Val_Volts= 10348; % measure volts

%regexprep(PhysicalChannel,'/','_')	% recommended to avoid problems
%Vmin=-10;Vmax=10;

DAQmx_Val_ChanPerLine = 0 ;
DAQmx_Val_ChanForAllLines = 1;
lineGrouping = DAQmx_Val_ChanPerLine ;
name_channel ='';

if ~iscell(PhysicalChannel)	% just 1 channel to add to task (maybe no need)
	err = calllib(lib,'DAQmxCreateDOChan',taskh, ...
		PhysicalChannel, name_channel, lineGrouping);
	DAQmxCheckError(lib,err);
else % more than 1 channel to add to task
	for m = 1:numel(PhysicalChannel)
		err = calllib(lib,'DAQmxCreateDOChan',taskh, ...
            PhysicalChannel, name_channel, lineGrouping);
        DAQmxCheckError(lib,err);
		
	end
end
%err = calllib(lib,'DAQmxStopTask',taskh);
