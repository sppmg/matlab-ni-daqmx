% This is a test file use midlib to test functions.
clear classes;
PhyChan ={ 'Dev1/ai0' };
mode = 'RealTime' ; % Single Finite Continuous RealTime 

LibHeader = 'NIDAQmx-lite.h' ;
LibDll = 'C:\WINDOWS\system32\nicaiu.dll' ;
LibAlias = 'nidaqmx' ; % alias

tmp=regexpi(PhyChan,'^.+(?=/)','match');
DevName=unique( [tmp{:}] );
tmp=regexpi(PhyChan,'(?<=/)[a-z]+','match');
ChanType=unique( [tmp{:}] );
if iscellstr(ChanType)
	ChanType = ChanType{:} ;
end
if iscellstr(DevName)
	DevName = DevName{:} ;
end
			
Min = -10 ;
Max = 10 ;
DataLayout = 1 ;	% DAQmx_Val_GroupByScanNumber = 1 ;
Rate = 1e6 ;
SampleNum = 1 ;
Timeout = 5;
ChanNum = 1 ;
readLen = 1e4 ; % length for each loop
data(readLen)=0;
trial = 10 ;
time(trial) = 0;

if ~libisloaded(LibAlias)
	disp(['Matlab: Loading library from ',LibDll ])
	[notfound,warnings] = loadlibrary(LibDll , LibHeader ,'alias',LibAlias );
end

switch ChanType
	case 'ai'
		NITaskHandle = DAQmxCreateAIVoltageChan(LibAlias,[],PhyChan ,Min ,Max );
	case 'ai'
		NITaskHandle = DAQmxCreateAOVoltageChan(LibAlias,[],PhyChan ,Min ,Max );
	otherwise
		error('Wrong in DAQmxCreate*Chan.');
end
DAQmxCheckError(LibAlias, calllib(LibAlias,'DAQmxResetDevice',DevName)) ;
% configure task
switch mode
	case 'Single'
		SampleNum = 1;
	case 'Finite'
		DAQmxCfgSampClkTiming(LibAlias, NITaskHandle, 10178, Rate ,SampleNum); % DAQmx_Val_FiniteSamps = 10178 % Finite Samples , Total data number set in SampleNum
	case 'Continuous'
		SampleNum=1e5;
		DAQmxCfgSampClkTiming(LibAlias, NITaskHandle, 10123, Rate ,SampleNum); % DAQmx_Val_ContSamps = 10123 % Continuous Samples
		
	case 'RealTime'
		SampleNum = 1 ;
		
	otherwise
		error('Wrong mode') ;
end

% for direct use "calllib"
readarray_ptr=libpointer('doublePtr',zeros(1,1));
sampread_ptr=libpointer('int32Ptr',0);
empty_ptr=libpointer('uint32Ptr',[]);
value_ptr = libpointer('doublePtr', 0);
% start read and measure consumed time.
switch mode
	case 'Single'
		NewData = DAQmxReadAnalogF64(LibAlias ,NITaskHandle, -1 , Timeout, DataLayout, ChanNum, SampleNum) ; % -1 == DAQmx_Val_Auto
	case 'Finite'
	case 'Continuous'
		abbr1=libpointer('int32Ptr',0) ;
		calllib( LibAlias, 'DAQmxGetSampTimingType', NITaskHandle ,abbr1);
		abbr2=libpointer('int32Ptr',0) ;
		calllib( LibAlias, 'DAQmxGetReadOverWrite', NITaskHandle ,abbr2);
		
		calllib(LibAlias, 'DAQmxStartTask',NITaskHandle);
		for m = 1:trial
			t0=tic;
			for n=1:readLen
				calllib(LibAlias,'DAQmxReadAnalogF64',NITaskHandle, -1, 10, 1,readarray_ptr,1,sampread_ptr,empty_ptr);
			end
			t=toc(t0);
			fprintf('%0.3f s \t %d loop \t %0.3f ms/loop \n', t, readLen, t*1e3/readLen);
		end
		calllib(LibAlias, 'DAQmxStopTask',NITaskHandle);
		fprintf('read %d sample\n',sampread_ptr.Value);
	case 'RealTime'
		abbr=libpointer('int32Ptr',0) ;
		calllib( LibAlias, 'DAQmxGetSampTimingType', NITaskHandle ,abbr);
		calllib(LibAlias, 'DAQmxStartTask',NITaskHandle);
		%pause(0.5);
		for m = 1:trial
			t0=tic;
			for n=1:readLen
				%NewData = DAQmxReadAnalogF64(LibAlias ,NITaskHandle, -1 , Timeout, DataLayout, ChanNum, SampleNum) ; % -1 == DAQmx_Val_Auto
				%calllib(LibAlias,'DAQmxReadAnalogF64',NITaskHandle,-1, 10, 1,readarray_ptr,1,sampread_ptr,empty_ptr);
				calllib(LibAlias,'DAQmxReadAnalogScalarF64',NITaskHandle,Timeout,value_ptr,empty_ptr);
				data(n)=value_ptr.Value;
			end
			t=toc(t0);
			fprintf('%0.3f s \t %d loop \t %0.3f ms/loop \n', t, readLen, t*1e3/readLen);
			time(m)=t*1e3/readLen;
		end
		calllib(LibAlias, 'DAQmxStopTask',NITaskHandle);
		fprintf('time , mean = %0.3f SD = %0.3f \n', mean(time), std(time) );
		%fprintf('read %d sample = %g \n',sampread_ptr.Value,readarray_ptr.Value);
		%fprintf('last value = %g sample\n',value_ptr.Value);
		
		
	otherwise
		error('Wrong mode') ;
end