function DAQmxWriteCtrFreqScalar (lib, taskh, timeout, frequency , dutyCycle)

%  Purpose
%  Writes a new pulse frequency and duty cycle to a continuous counter output task that contains a single channel.
%
%  C function prototype
%  int32 DAQmxWriteCtrFreqScalar (TaskHandle taskHandle, bool32 autoStart, float64 timeout, float64 frequency, float64 dutyCycle, bool32 *reserved);

numSampsPerChanWritten = libpointer('int32Ptr', 0) ;
reserved = libpointer('uint32Ptr', [] );

err = calllib(lib,'DAQmxWriteCtrFreqScalar', taskh, 1,  timeout, frequency, dutyCycle, reserved); % autoStart = 1

DAQmxCheckError(lib,err);