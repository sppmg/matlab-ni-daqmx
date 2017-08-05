function bufSize = DAQmxGetBufOutputBufSize(lib, taskh)
% c function
% int32 __CFUNC DAQmxGetBufOutputBufSize(TaskHandle taskHandle, uInt32 *data);

bufSize_ptr = libpointer('uint32Ptr',0);

DAQmxCheckError(lib, calllib(lib,'DAQmxGetBufOutputBufSize', taskh, bufSize_ptr) ) ;

bufSize = bufSize_ptr.Value ;