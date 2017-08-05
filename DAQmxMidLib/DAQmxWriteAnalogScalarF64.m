function DAQmxWriteAnalogScalarF64(lib,taskh,timeout,value)
% For single point in single channel.
% C function
% int32 DAQmxWriteAnalogScalarF64 (TaskHandle taskHandle, bool32 autoStart,
%		float64 timeout, float64 value, bool32 *reserved);

empty_ptr=libpointer('uint32Ptr',[]);

DAQmxCheckError(lib, calllib(lib,'DAQmxWriteAnalogScalarF64', taskh, 1, timeout, value, empty_ptr) );
