function data = DAQmxReadAnalogScalarF64(lib,taskh,timeout)
% For single point in single channel.
% C function
% int32 DAQmxReadAnalogScalarF64 (TaskHandle taskHandle, float64 timeout, float64 *value, bool32 *reserved);

value_ptr = libpointer('doublePtr', 0);
empty_ptr=libpointer('uint32Ptr',[]);

DAQmxCheckError(lib, calllib(lib,'DAQmxReadAnalogScalarF64', taskh, timeout, value_ptr, empty_ptr)) ;

data = value_ptr.Value ;