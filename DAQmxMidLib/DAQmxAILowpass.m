function val = DAQmxAILowpass(lib, taskh, PhysicalChannel, varargin)

%  Purpose
%  Enable the hardware filter on DAQ channel.
%
%  Usage
%  val = DAQmxAILowpass(lib, taskh, PhysicalChannel) % Get enable status
%  val = DAQmxAILowpass(lib, taskh, PhysicalChannel, cutFreq) % Set cutoff frequency (Hz), 0 -> disable
%  val = DAQmxAILowpass(lib, taskh, PhysicalChannel, 'cutFreq') % Get cutoff frequency (Hz)
%  val = DAQmxAILowpass(lib, taskh, PhysicalChannel, 'reset') % Reset enable status

%  C functions
%  //*** Set/Get functions for DAQmx_AI_Lowpass_Enable ***
%  int32 DAQmxGetAILowpassEnable(TaskHandle taskHandle, const char channel[], bool32 *data);
%  int32 DAQmxSetAILowpassEnable(TaskHandle taskHandle, const char channel[], bool32 data);
%  int32 DAQmxResetAILowpassEnable(TaskHandle taskHandle, const char channel[]);
%  //*** Set/Get functions for DAQmx_AI_Lowpass_CutoffFreq ***
%  int32 DAQmxGetAILowpassCutoffFreq(TaskHandle taskHandle, const char channel[], float64 *data);
%  int32 DAQmxSetAILowpassCutoffFreq(TaskHandle taskHandle, const char channel[], float64 data);
%  int32 DAQmxResetAILowpassCutoffFreq(TaskHandle taskHandle, const char channel[]);


% if isempty(taskh)
%     taskh=libpointer('voidPtr',taskh);
%     err = calllib(lib,'DAQmxCreateTask','',taskh);    % task name set to '', recommended to avoid problems;
%     DAQmxCheckError(lib,err);
% end



if nargin == 3
    % Get enable status
    isLowpassEnable_ptr = libpointer('uint32Ptr',0);
    err = calllib(lib,'DAQmxGetAILowpassEnable',taskh, PhysicalChannel, isLowpassEnable_ptr);
    val = logical(isLowpassEnable_ptr.Value);
else
    switch class(varargin{1})
        case 'double'
            cutFreq = varargin{1} ;
            if cutFreq == 0  % disable lowpass
                err = calllib(lib,'DAQmxSetAILowpassEnable',taskh, PhysicalChannel, 0);
                val = err ;
            else             % set cutoff
                err = calllib(lib,'DAQmxSetAILowpassEnable',taskh, PhysicalChannel, 1);
                % check if err
                err = calllib(lib,'DAQmxSetAILowpassCutoffFreq',taskh, PhysicalChannel, cutFreq);
                % check if err
                
                % Read real frequency
                cutFreq_real_ptr = libpointer('doublePtr',0);
                err = calllib(lib,'DAQmxGetAILowpassCutoffFreq',taskh, PhysicalChannel, cutFreq_real_ptr);
                val = cutFreq_real_ptr.Value ;
            end
            
        case 'char'     % other command
            cmd = varargin{1} ;
            switch cmd
                case 'reset'    % Reset enable status
                    err = calllib(lib,'DAQmxResetAILowpassEnable',taskh, PhysicalChannel);
                case 'cutFreq'  % Get cutoff frequency (Hz)
                    cutFreq_real_ptr = libpointer('doublePtr',0);
                    err = calllib(lib,'DAQmxGetAILowpassCutoffFreq',taskh, PhysicalChannel, cutFreq_real_ptr);
                    val = cutFreq_real_ptr.Value ;
            end
        otherwise
            warning('Wrong argument number in DAQmxAILowpass. skip') ;
    end
end
    
    
    

 
err = calllib(lib,'DAQmxTaskControl',taskh,2); % DAQmx_Val_Task_Verify =2;
