function DAQmxTaskControl(lib,taskh,actions)
% C function
% int32 DAQmxTaskControl (TaskHandle taskHandle, int32 action)

%  	DAQmx_Val_Task_Start = 0   % Start
%  	DAQmx_Val_Task_Stop = 1   % Stop
%  	DAQmx_Val_Task_Verify = 2   % Verify
%  	DAQmx_Val_Task_Commit = 3   % Commit
%  	DAQmx_Val_Task_Reserve = 4   % Reserve
%  	DAQmx_Val_Task_Unreserve = 5   % Unreserve
%  	DAQmx_Val_Task_Abort = 6   % Abort

	if ischar(actions) || isnumeric(actions)
		actions = { actions } ;
	elseif ~iscell(actions)
		return ;
	end
	%cellfun(@tc, lib, taskh, actions);
    for n=1:numel(actions)
        tc(lib, taskh, actions{n});
    end
end


function tc(lib, taskh, action)
	switch lower(action)
		case {0,'start'}
			actCode = 0 ;
		case {1,'stop'}
			actCode = 1 ;
		case {2,'verify'}
			actCode = 2 ;
		case {3,'commit'}
			actCode = 3 ;
		case {4,'reserve'}
			actCode = 4 ;
		case {5,'unreserve'}
			actCode = 5 ;
		case {6,'abort'}
			actCode = 6 ;
		otherwise
			return ;
	end
	%fprintf('action = %s \t code = %d\n',action, actCode)
	err = calllib(lib,'DAQmxTaskControl', taskh, actCode);
	DAQmxCheckError(lib,err);
end