function DAQmxCfgImplicitTiming(lib, taskh, sampleMode, sampsPerChanToAcquire)
%  Purpose
%  Sets only the number of samples to acquire or generate without specifying timing. Typically, you should use this function when the task does not require sample timing, such as tasks that use counters for buffered frequency measurement, buffered period measurement, or pulse train generation. For finite counter output tasks, sampsPerChanToAcquire is the number of pulses to generate.
%
%  C function
%  int32 DAQmxCfgImplicitTiming (TaskHandle taskHandle, int32 sampleMode, uInt64 sampsPerChanToAcquire);
%
%  DAQmx_Val_FiniteSamps = 10178
%  DAQmx_Val_ContSamps = 10123
%  DAQmx_Val_HWTimedSinglePoint = ? , lazy find :)


err = calllib(lib, 'DAQmxCfgImplicitTiming', taskh ,sampleMode ,sampsPerChanToAcquire) ;