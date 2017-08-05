function data = DAQmxReadAnalogF64(lib,taskh,numSampsPerChan,timeout,fillMode,numchan,numsample)
% checked
% this function reads analog inputs from previously setup task
% 
% inputs:
%	lib - .dll or alias (ex. 'myni')
%	taskh - taskhandle of analog inputs
%	numSampsPerChan = DAQmx_Val_Auto (-1 -> read all available)
%	timeout - in seconds
%	fillMode - DAQmx_Val_GroupByChannel or DAQmx_Val_GroupByScanNumber
%	numchan - number of analog channels to read
%	numsample - number of samples to read
% 
% 
% C functions used:
%	int32 DAQmxReadAnalogF64 (
%		TaskHandle taskHandle,int32 numSampsPerChan,float64 timeout,bool32 fillMode,
%		float64 readArray[],uInt32 arraySizeInSamps,int32 *sampsPerChanRead,bool32 *reserved);
% %	int32 DAQmxStopTask (TaskHandle taskHandle);
% disp('in read')
% whos taskh
% taskh.Value

readarray_ptr=libpointer('doublePtr',zeros(numchan,numsample));
sampread_ptr=libpointer('int32Ptr',0);
empty_ptr=libpointer('uint32Ptr',[]);

arraylength=numsample*numchan; % more like 'buffersize'

err = calllib(lib,'DAQmxReadAnalogF64',...
		taskh,numSampsPerChan,timeout,fillMode,...
		readarray_ptr,arraylength,sampread_ptr,empty_ptr);
DAQmxCheckError(lib,err);

readarray=readarray_ptr.Value;
%sampread=sampread_ptr.Value;

data = readarray(:,1:sampread_ptr.Value)';
