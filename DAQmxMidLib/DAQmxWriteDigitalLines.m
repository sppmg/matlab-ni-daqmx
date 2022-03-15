function numwritten = DAQmxWriteDigitalLines(lib,taskh,numChan,timeout,dataLayout,writeArray)
% single output worked
% this function reads analog inputs from previously setup task
% 
% inputs:
%	lib - .dll or alias (ex. 'myni')
%	taskh - taskhandle of analog inputs
%	numSampsPerChan = DAQmx_Val_Auto ?
%	timeout - in seconds
%	dataLayout - DAQmx_Val_GroupByChannel or DAQmx_Val_GroupByScanNumber
%	numchan - number of analog channels to read
%	numsample - number of samples to read
% 
% C functions used:
%　int32 DAQmxWriteDigitalLines (TaskHandle taskHandle, int32 numSampsPerChan, 
%  bool32 autoStart, float64 timeout, bool32 dataLayout, uInt8 writeArray[], 
%  int32 *sampsPerChanWritten, bool32 *reserved);


if ndims(writeArray) > 1 	% column for channel
	writeArray=reshape(writeArray',1,[]);
end

numSampsPerChan = numel(writeArray)/numChan;

writeArray_ptr=libpointer('uint8Ptr',writeArray);
sampsPerChanWritten_ptr=libpointer('int32Ptr',0);
empty_ptr=libpointer('uint32Ptr',[]);
%sampsPerChanWritten=0;sampsPerChanWritten_ptr=libpointer('int32Ptr',sampsPerChanWritten);
%empty=[]; empty_ptr=libpointer('uint32Ptr',empty);

err = calllib(lib,'DAQmxWriteDigitalLines',...
		taskh,numSampsPerChan,1,timeout,dataLayout,...
		writeArray_ptr,sampsPerChanWritten_ptr,empty_ptr);
DAQmxCheckError(lib,err);

numwritten = sampsPerChanWritten_ptr.Value;
