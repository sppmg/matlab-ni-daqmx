function isTaskDone = DAQmxIsTaskDone(lib,taskh )
% Task done retuen 1 otherwise 0
% c function
% int32 DAQmxIsTaskDone (TaskHandle taskHandle, bool32 *isTaskDone);
isTaskDone_ptr = libpointer('uint32Ptr',0);
DAQmxCheckError(lib, calllib(lib,'DAQmxIsTaskDone', taskh, isTaskDone_ptr) );

isTaskDone = isTaskDone_ptr.Value;