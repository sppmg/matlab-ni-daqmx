function DAQmxWriteCtrTimeScalar (lib, taskh, timeout, highTime, lowTime)

%  Purpose
%  Writes a new pulse high time and low time to a continuous counter output task that contains a single channel.
%
%  C function prototype
%  int32 DAQmxWriteCtrTimeScalar (TaskHandle taskHandle, bool32 autoStart, float64 timeout, float64 highTime, float64 lowTime, bool32 *reserved);

reserved = libpointer('uint32Ptr', [] );

err = calllib(lib,'DAQmxWriteCtrTimeScalar', taskh, 1,  timeout, highTime, lowTime, reserved); % autoStart = 1

DAQmxCheckError(lib,err);