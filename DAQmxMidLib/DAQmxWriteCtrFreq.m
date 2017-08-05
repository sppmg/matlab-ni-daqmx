function numWritten = DAQmxWriteCtrFreq (lib, taskh, numSampsPerChan, timeout, dataLayout, frequency , dutyCycle)

%  Purpose
%  Writes a new pulse frequency and duty cycle to each channel in a continuous counter output task that contains one or more channels.
%
%  C function prototype
%  int32 DAQmxWriteCtrFreq (TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, float64 frequency[], float64 dutyCycle[], int32 *numSampsPerChanWritten, bool32 *reserved);


%sampsPerChanWritten=0;sampsPerChanWritten_ptr=libpointer('int32Ptr',sampsPerChanWritten);
%empty=[]; empty_ptr=libpointer('uint32Ptr',empty);
numSampsPerChanWritten = libpointer('int32Ptr', 0) ;
reserved = libpointer('uint32Ptr', [] );

err = calllib(lib,'DAQmxWriteCtrFreq', taskh, numSampsPerChan, 1,  timeout, dataLayout, frequency, dutyCycle, numSampsPerChanWritten, reserved); % autoStart = 1

DAQmxCheckError(lib,err);

numWritten = numSampsPerChanWritten.Value ;