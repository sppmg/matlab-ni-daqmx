classdef daqmx_Task < handle
	properties
		ChanAlias ;

		Max = 10 ;
		Min = -10 ;
		DataLayout = 1 ;	% DAQmx_Val_GroupByScanNumber = 1 ;
		SampleNum = 1 ; % per channel, effect like a buffer in matlab.
		%little more than 10 Hz update rate. S mode need also(no set will get error in read).
		Timeout = 5 ; 
		ProcPeriod = 0 ; % Period of NI buffer r/w and user callback.
		DataStorageLen ; % unit = data number
		
		CallbackFunc ; % Callback function name, string.
		
		CircBuf = 1 ; % Circulary buffer of write (ao)
		BufHead = 1 ; % Head pointer for write buffer, next write data.
		UserData ;
	end
	
	properties (SetAccess = private)
		PhyChan ; % eg : 'Dev1/ai0';
		NITaskHandle ; 
		TimerHandle ;
		
		DevName ;  % eg : dev1
		ChanType ; % eg : ai / ao / di / do / etc ....
		ChanMeas = 'Voltage' ; % Measure eg. V,I
		ChanNum ;
		ChanOccupancy ;
		
		Mode ; % Mode = 'Single' | 'Finite' | 'Continuous | RealTime '
		Rate ;
		
		DataTime ; % storage time of each data
		
		DataLastTime = 0 ;
		DataLastPartNum = 0 ;
		DataTotalNumPerChan = 0 ; % per channel 
		DataStorage ; % storage input data.
		
		LibHeader = 'NIDAQmx-lite.h';
		LibDll = 'C:\WINDOWS\system32\nicaiu.dll' ;
		LibAlias = 'nidaqmx' ;

		% LastVal_ for compare variable change.
		LastVal_SampleNum = 1 ;
		
		%StatusTaskRunning = 0 ;
		IsSingleChan = 0; % for fast switch single point read/write function.
		
		% LibPtr_ for calllib 
		LibPtr_null = libpointer('uint32Ptr',[]);
		LibPtr_sampread = libpointer('int32Ptr',0);
		LibPtr_value = libpointer('doublePtr', 0);
		LibPtr_array = libpointer('doublePtr',zeros(1,1));
	end
	methods
		function obj=daqmx_Task(varargin)
			% Load lib
			if ~libisloaded(obj.LibAlias)
				disp(['Matlab: Loading library from ',obj.LibDll ])
				[notfound,warnings] = loadlibrary(obj.LibDll , obj.LibHeader ,'alias',obj.LibAlias );
			end
			switch nargin
				case 0
					helpMsg;
					return;
				case 1
					obj.PhyChan = varargin{1} ;
				otherwise
					if ~mod(nargin,2) % even nargin
						for arg_i = 1:2:size(varargin,2)
							switch lower( varargin{arg_i} )
								case 'chan'
									obj.PhyChan = varargin{arg_i+1} ;
								case 'chantype'
									obj.ChanType = varargin{arg_i+1} ;
									switch lower(varargin{arg_i+1})
										case {'ai'}
											obj.ChanType = 'ai';
										case {'ao'}
											obj.ChanType = 'ao' ;
										otherwise
											error('ChanType string not allowed.');
									end
								case 'chanmeas'
									switch lower(varargin{arg_i+1})
										case {'voltage','v'}
											obj.ChanMeas = 'Voltage';
										case {'current','i'}
											obj.ChanMeas = 'Current' ;
										otherwise
											error('ChanMeas string not allowed.')
									end

								case 'alias'
									obj.ChanAlias = varargin{arg_i+1} ;
								case 'mode'
									% Allow use  s,f,c
									switch lower(varargin{arg_i+1})
										case {'single','s'}
											obj.Mode='Single';
										case {'finite','f'}
											obj.Mode = 'Finite' ;
										case {'continuous','c'}
											obj.Mode = 'Continuous' ;
										case {'realtime', 'r'}
											obj.Mode = 'RealTime' ;
										otherwise
											error('Mode string not allowed.');
									end
								case 'rate'
									% 'Finite' or 'Continuous' mode , if did not set SampleNum , default is 'Continuous' .
									if isnumeric(varargin{arg_i+1})
										obj.Rate = varargin{arg_i+1} ;
									else
										error('Rate should be numeric.');
									end

								case 'samplenum'
									% 'Finite' or 'Continuous' mode , default is 'Finite' .
									if isnumeric(varargin{arg_i+1})
										if mod(varargin{arg_i+1},1)
											error('SampleNum should be interger.');
										end
										obj.SampleNum = varargin{arg_i+1} ;
									end
								case 'max'
									if isnumeric(varargin{arg_i+1})
										obj.Max = varargin{arg_i+1} ;
									else
										error('Max should be numeric.');
									end
								case 'min'
									if isnumeric(varargin{arg_i+1})
										obj.Min = varargin{arg_i+1} ;
									else
										error('Min should be numeric.');
									end
								case 'procperiod'
									% should > 0.001 s , matlab timer limit.
									if varargin{arg_i+1} <= 1e-5   % for set 0
                                                                            obj.ProcPeriod = 0 ;
									elseif varargin{arg_i+1} <= 0.001
										obj.ProcPeriod = 0.001 ;
									else
										obj.ProcPeriod = varargin{arg_i+1} ;
									end
								case 'callbackfunc' % input string
									obj.CallbackFunc = varargin{arg_i+1} ;
								case 'datawindowlen' % data number per channel
									obj.DataStorageLen = varargin{arg_i+1} ;
							end
						end % for each arg
					end % if mod()
			end % switch nargin
			% ----------- PhyChan,Alias parser ---------
			if isempty(obj.PhyChan)
				error('Please specify physical channel name. eg, "Dev1/ai0:3" .');
			elseif ischar(obj.PhyChan)
				obj.PhyChan={obj.PhyChan};
			end
			
			if iscellstr(obj.PhyChan)
				tmp=regexpi(obj.PhyChan,'^.+(?=/)','match');
				obj.DevName=unique( [tmp{:}] );
				
				tmp=regexpi(obj.PhyChan,'(?<=/)[a-z]+','match');
				obj.ChanType=unique( [tmp{:}] );
				
				tmp=regexpi(obj.PhyChan,'(?<=/[a-z]+)[0-9:]+','match');
				
				for fi= 1:numel(tmp)
					obj.ChanOccupancy=[ obj.ChanOccupancy,str2num(tmp{fi}{:})];
				end
			else
				error('Wrong channel name.')
			end

			if numel(obj.DevName) > 1
				error('This program not allow use multidevice in one task object.');
			end
			if numel(obj.ChanType) > 1
				error('This program not allow use multi-type (ai,ao ...) in one task object.');
			end
			if numel(obj.ChanOccupancy) ~= numel(unique(obj.ChanOccupancy))
				error('Channel name overlaped.') ;
			end
			if numel(obj.ChanAlias) ~= numel(unique(obj.ChanAlias))
				error('Channel alias name repeated.');
			end
			
			if numel(obj.ChanAlias) > 0 && numel(obj.ChanAlias) <= numel(obj.ChanOccupancy)
				tmp=cell(1,numel(obj.ChanOccupancy));
				tmp(1:numel(obj.ChanAlias))=obj.ChanAlias ;
				obj.ChanAlias=tmp;	% <^-- add [] after alias cell array.
			end
			if numel(obj.ChanAlias) > numel(obj.ChanOccupancy)
				error('Alias number more than channel number.');
			end
			obj.ChanNum=numel(obj.ChanOccupancy); % It's for fast get number.
			if obj.ChanNum == 1 && exist('DAQmxReadAnalogScalarF64','builtin') && exist('DAQmxWriteAnalogScalarF64','builtin')
				obj.IsSingleChan = true ;
			else
				obj.IsSingleChan = false ;
			end
			% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				
			if iscellstr(obj.ChanType)
				obj.ChanType = obj.ChanType{:} ;
			end
			if iscellstr(obj.DevName)
				obj.DevName = obj.DevName{:} ;
			end
			
			switch [obj.ChanType,obj.ChanMeas]
				% Voltage
				case 'aiVoltage'
					obj.NITaskHandle = DAQmxCreateAIVoltageChan(obj.LibAlias,[],obj.PhyChan ,obj.Min ,obj.Max );
				case 'aoVoltage'
					obj.NITaskHandle = DAQmxCreateAOVoltageChan(obj.LibAlias,[],obj.PhyChan ,obj.Min ,obj.Max );
				% Current
				case 'aiCurrent'
					obj.NITaskHandle = DAQmxCreateAICurrentChan(obj.LibAlias,[],obj.PhyChan ,obj.Min ,obj.Max );
				case 'aoCurrent'
					obj.NITaskHandle = DAQmxCreateAOCurrentChan(obj.LibAlias,[],obj.PhyChan ,obj.Min ,obj.Max );
				otherwise
					error('Wrong in DAQmxCreate*Chan.');
			end
			% -------- Automatically determine mode -------
			if isempty(obj.Mode)
				if isempty(obj.Rate)
					obj.Mode = 'Single' ;
					% obj.SampleNum = 1 ; % default now.
				elseif obj.SampleNum > 1 && isempty(obj.DataStorageLen)
					obj.Mode = 'Finite' ;
					obj.DataStorageLen = obj.SampleNum ;
					obj.Timeout = obj.SampleNum * 1.2 / obj.Rate + 5 ;
					setTiming(obj) ;
					obj.LastVal_SampleNum = obj.SampleNum ;
				else
					obj.Mode = 'Continuous' ;
					if isempty(obj.ProcPeriod)
						obj.ProcPeriod = 0.1;
					end
					if isempty(obj.DataStorageLen)
						obj.DataStorageLen = 10*obj.Rate ;
					end
					if obj.SampleNum < 10
						obj.SampleNum = 3 * obj.Rate * obj.ProcPeriod + 10;
					end
					setTiming(obj) ;
					obj.LastVal_SampleNum = obj.SampleNum ;
				end
			end
			% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		end

		% Start task , for mode == f,c
		function varargout=start(obj,varargin)
			obj.DataLastTime = 0 ;
			obj.DataLastPartNum = 0 ;
			obj.DataTotalNumPerChan = 0 ;
			obj.SampleNum = round( obj.SampleNum ) ; % force set to interger.
			
			switch obj.ChanType
				case 'ai'
					switch obj.Mode
						case 'Single'
							obj.read( varargin{:} ) ;
						case 'Finite'
							calllib(obj.LibAlias,'DAQmxStopTask',obj.NITaskHandle);
							if obj.SampleNum ~= obj.LastVal_SampleNum
								obj.DataStorageLen = obj.SampleNum ;
								obj.Timeout = obj.SampleNum * 1.2 / obj.Rate + 5 ;
								setTiming(obj);
								obj.LastVal_SampleNum = obj.SampleNum ;
							end
							%obj.DataStorage = [] ; % aibg will overwrite
							calllib(obj.LibAlias, 'DAQmxStartTask',obj.NITaskHandle);
						case 'Continuous'
							obj.DataStorageLen = round ( obj.DataStorageLen ) ;
							calllib(obj.LibAlias,'DAQmxStopTask',obj.NITaskHandle);
							setTiming(obj);
							obj.DataStorage = [] ;
							if obj.CircBuf
								calllib( obj.LibAlias, 'DAQmxSetReadOverWrite', obj.NITaskHandle, 10252);
								% DAQmx_Val_OverwriteUnreadSamps = 10252 
							else
								calllib( obj.LibAlias, 'DAQmxSetReadOverWrite', obj.NITaskHandle, 10159);
								% DAQmx_Val_DoNotOverwriteUnreadSamps = 10159
							end
							calllib(obj.LibAlias, 'DAQmxStartTask',obj.NITaskHandle);
							if ~isempty(obj.TimerHandle)
								start(obj.TimerHandle) ;
							end
						case 'RealTime'
							calllib(obj.LibAlias, 'DAQmxStartTask',obj.NITaskHandle);
					end
				case 'ao'
					switch obj.Mode
						case 'Single'
							obj.write( varargin{:} ) ;
						case 'Finite'
							err = calllib(obj.LibAlias,'DAQmxStopTask',obj.NITaskHandle);
							if obj.SampleNum ~= numel(obj.DataStorage)
								%obj.DataStorageLen = obj.SampleNum ;
								obj.Timeout = obj.SampleNum * 1.2 / obj.Rate + 5 ;
								setTiming(obj);
								%obj.LastVal_SampleNum = obj.SampleNum ; % only use in ai
							end
							calllib(obj.LibAlias, 'DAQmxStartTask',obj.NITaskHandle);
						case 'Continuous'
							calllib(obj.LibAlias,'DAQmxStopTask',obj.NITaskHandle);
							setTiming(obj);
							if obj.CircBuf
								calllib( obj.LibAlias, 'DAQmxSetWriteRegenMode', obj.NITaskHandle, 10097);
								% DAQmx_Val_AllowRegen = 10097
							else
								calllib( obj.LibAlias, 'DAQmxSetWriteRegenMode', obj.NITaskHandle, 10158);
								% DAQmx_Val_DoNotAllowRegen = 10158
							end
							calllib(obj.LibAlias, 'DAQmxStartTask',obj.NITaskHandle);
							if ~isempty(obj.TimerHandle)
								start(obj.TimerHandle) ;
							end
						case 'RealTime'
							calllib(obj.LibAlias, 'DAQmxStartTask',obj.NITaskHandle);
					end
			end
		end

		% Stop task , for mode == f,c,r
		function stop(obj)
			switch obj.ChanType
				case {'ai','ao'}
					if ~isempty(obj.TimerHandle)
						stop(obj.TimerHandle);
					end
					if strcmpi(obj.Mode, 'Continuous') || strcmpi(obj.Mode, 'Finite') || strcmpi(obj.Mode, 'RealTime')
						calllib(obj.LibAlias,'DAQmxStopTask',obj.NITaskHandle);
					end
			end
		end
		
		function delete(obj)
			obj.stop;
			calllib(obj.LibAlias,'DAQmxClearTask',obj.NITaskHandle);
			if ~isempty(obj.TimerHandle)
				delete(obj.TimerHandle) ;
			end
		end
		
		% Read last part data.
		function varargout=read(obj,varargin)
			switch obj.Mode
				case 'RealTime'
					calllib(obj.LibAlias, 'DAQmxReadAnalogScalarF64', obj.NITaskHandle, obj.Timeout, obj.LibPtr_value, obj.LibPtr_null );
					varargout{1} = obj.LibPtr_value.Value ;
					return ;
			end
			
			if ~iscellstr(varargin)
				error('Only allow string.') ;
			end
			%if ~strcmpi(obj.Mode,'Single')
			%	error('read method only allow in "single" mode.');
			%end
			switch obj.Mode
				case 'Single'
					% daq read immediately.
					if obj.IsSingleChan
						obj.DataStorage = DAQmxReadAnalogScalarF64(obj.LibAlias , obj.NITaskHandle, obj.Timeout);
						varargout{1} = obj.DataStorage ;
					else
						aibg([],[],obj) ;
						DataColumnLgc = selectChan(obj,varargin{:}) ; % don't forget {:}
						varargout{1} = obj.DataStorage(: ,DataColumnLgc) ;
					end
				case 'Finite'
					aibg([],[],obj) ;
					DataColumnLgc = selectChan(obj,varargin{:}) ; % don't forget {:}
					varargout{1} = obj.DataStorage(: ,DataColumnLgc) ;
					obj.stop; % for autoStartTask
				case 'Continuous'
					% outout last part from .DataStorage
					if isempty(obj.TimerHandle)	% manual transfer .
						aibg([],[],obj) ;
					end
					if ~isempty(obj.DataStorage)
						DataColumnLgc = selectChan(obj,varargin{:}); % don;t forget {:}
						varargout{1} = obj.DataStorage(end - obj.DataLastPartNum +1 : end  ,DataColumnLgc) ;
					else
						varargout{1} = [];
					end
			end
		end
		% Write data to .DataStorage (buffer in matlab).
		function varargout=write(obj,varargin)
			switch obj.Mode
				case 'RealTime'
					calllib(obj.LibAlias, 'DAQmxWriteAnalogScalarF64', obj.NITaskHandle, 1, obj.Timeout, varargin{1}, obj.LibPtr_null );
					return ;
			end
			
			switch nargin		% argin include obj, so nargin >= 1
				case 1
					WriteLastData = 1 ;
				case 2
					WriteLastData = 0 ;
				otherwise
					error('"write" only allow 1 data set. Did not support set data for specify channel.') ;
			end
			
			switch obj.Mode
				case 'Single'
					% daq write immediately.
								%DataColumnLgc = selectChan(obj,varargin{:}); % don;t forget {:}
								%varargout = obj.DataStorage(DataColumnLgc) ;
					if ~WriteLastData
						obj.DataStorage = varargin{1} ;
					end
					if obj.IsSingleChan
						DAQmxWriteAnalogScalarF64(obj.LibAlias , obj.NITaskHandle, obj.Timeout, obj.DataStorage);
					else
						aobg([],[],obj) ;
					end
				case 'Finite'
						obj.stop;
					if ~WriteLastData
						obj.DataStorage = varargin{1} ;
						if numel(obj.DataStorage) ~= obj.SampleNum
							obj.SampleNum = numel(obj.DataStorage) ;
							obj.Timeout = obj.SampleNum * 1.2 / obj.Rate + 5 ;
							setTiming(obj);
							obj.LastVal_SampleNum = obj.SampleNum ;
						end
						aobg([],[],obj) ;
					else
						obj.start;
					end
				case 'Continuous'
					% In continuous mode not support no argument.
					if ~WriteLastData
						if obj.CircBuf
							% overwrite .DataStorage
							obj.DataStorage = varargin{1} ;
							obj.BufHead = 1 ;
						else
							% append .DataStorage
							obj.DataStorage = [obj.DataStorage(obj.BufHead:end,:) ;varargin{1}] ;
							obj.BufHead = 1 ;
						end
					end
			end
			
			% for multichannel function. not support now.
			%if mod(numel(obj.DataStorage), obj.ChanNum)	% it's should stop. Don't put adaptive code.
			%	error('Output data length not same for each channel.');
			%end
		end
		
					% delete this function later
					% Output last part data.
					%function NewData=DataLastPart(obj)
					%	NewData = obj.DataStorage( end - obj.DataLastPartNum -1 : end , :) ;
					%end

		% Get data from .DataStorage which last get from NI buffer.
		% The aim of similar function is readability in other script..
		function varargout=data(obj,varargin)
			if ~iscellstr(varargin)
				error('Only allow string.') ;
			end
			if ~isempty(obj.DataStorage)
				switch obj.Mode	% look like it's same now, maybe merge later.
					case 'Single'
						DataColumnLgc = selectChan(obj,varargin{:}); % don't forget {:}
						varargout{1} = obj.DataStorage(: ,DataColumnLgc) ;
					case 'Finite'
						% outout all data from .DataStorage
						DataColumnLgc = selectChan(obj,varargin{:}); % don't forget {:}
						varargout{1} = obj.DataStorage(: ,DataColumnLgc) ;
					case 'Continuous'
						% outout all data from .DataStorage
						DataColumnLgc = selectChan(obj,varargin{:}); % don't forget {:}
						varargout{1} = obj.DataStorage(: ,DataColumnLgc) ;
				end
			end
		end
		
		function resetDev(obj)
			err=calllib(obj.LibAlias,'DAQmxResetDevice',obj.DevName) ;
		end

		function changeMode(obj,str)
			obj.stop;
			switch lower(str)
				case {'single','s'}
					obj.Mode='Single';
				case {'finite','f'}
					obj.Mode = 'Finite' ;
				case {'continuous','c'}
					obj.Mode = 'Continuous' ;
				otherwise
					error('Mode string not allowed.');
			end
			setTiming(obj);
		end
		function changeRate(obj,RateNum)
			obj.stop;
			if isnumeric(RateNum) && numel(RateNum) == 1
				obj.Rate = RateNum ;
			else
				error('Wrong argument.');
			end
			setTiming(obj);
		end
		function wait(obj,varargin)
			switch nargin
				case 1
					timeToWait = -1 ; % DAQmx_Val_WaitInfinitely
				case 2 
					timeToWait = varargin{1} ;
				otherwise
					error('To many argument.');
			end
			calllib(obj.LibAlias,'DAQmxWaitUntilTaskDone', obj.NITaskHandle, timeToWait);
		end
	end
end

% Background analog intput
function varargout=aibg(TimerObj,event,ChanObj)
	NewData = DAQmxReadAnalogF64(ChanObj.LibAlias ,ChanObj.NITaskHandle, -1 , ChanObj.Timeout, ChanObj.DataLayout, ChanObj.ChanNum, ChanObj.SampleNum) ; % -1 == DAQmx_Val_Auto
	% NewData is 1D data. Follow "if" block format to 2D data.
	% Put each channel data to column(or "_y").
	switch ChanObj.Mode
		case 'Single'
			ChanObj.DataStorage = NewData ;
		case 'Finite'
			ChanObj.DataTotalNumPerChan = size(NewData,1) ;
			ChanObj.DataLastTime =(ChanObj.DataTotalNumPerChan-1)/ChanObj.Rate ;
			ChanObj.DataTime = [0 : 1/ChanObj.Rate : ChanObj.DataLastTime ] ;
			ChanObj.DataStorage = NewData ;
			ChanObj.DataLastPartNum = ChanObj.DataTotalNumPerChan ;
			%ChanObj.stop ;
		case 'Continuous'
			% Adapted buffer.
			if  size(NewData,1) > ChanObj.SampleNum*0.8 % read speed slow then NI daqmx.
				ChanObj.SampleNum = ceil( ChanObj.SampleNum * 1.2 ) ;
			end
			ChanObj.DataTotalNumPerChan = ChanObj.DataTotalNumPerChan + size(NewData,1) ;
			ChanObj.DataLastTime=(ChanObj.DataTotalNumPerChan-1)/ChanObj.Rate  ; % time of last data
			ChanObj.DataStorage=[ChanObj.DataStorage ; NewData ];

			DataWindow_y=size(ChanObj.DataStorage , 1) ;
			if DataWindow_y > ChanObj.DataStorageLen
				ChanObj.DataStorage=ChanObj.DataStorage(end-ChanObj.DataStorageLen+1 : end , :) ;
				DataWindow_y=ChanObj.DataStorageLen;
			end
			ChanObj.DataLastPartNum=size(NewData,1); % for get last part data (last NewData) by index.

			ChanObj.DataTime=[ ChanObj.DataLastTime- (DataWindow_y-1) /ChanObj.Rate   : 1/ChanObj.Rate   : ChanObj.DataLastTime ]' ;
	end
	if ~isempty(ChanObj.CallbackFunc)
		feval(ChanObj.CallbackFunc, ChanObj) % call user's function
	end
	
end

% ======== NI Buffer size ========
% Buffered writes require a minimum buffer size of 2 samples. If you do not configure the buffer size using DAQmxCfgOutputBuffer, NI-DAQmx automatically configures the buffer when you configure sample timing.
% If the acquisition is finite , NI-DAQmx allocates a buffer equal in size to the value of samples per channel. 
% If the acquisition is continuous, NI-DAQmx will allocate a buffer according to the following table: (S == Scan)
% Sample Rate			Buffer Size
% 0 - 100 S/s				1 kS
% 100 - 10,000 S/s 			10 kS
% 10,000 - 1,000,000 S/s 	100 kS
% > 1,000,000 S/s 			1 MS

% Background analog outout
function aobg(TimerObj,event,ChanObj)
	% suppose mod(numel(ChanObj.DataStorage), ChanObj.ChanNum) == 0
	% Only write from .DataStorage in this function.
	% For performance reason, .DataStorage should prepared in call function (write() )
	switch ChanObj.Mode
		case {'Single' , 'Finite'}
			%if numel(ChanObj.DataStorage) < ChanObj.ChanNum
			%	ChanObj.DataStorage=[ChanObj.DataStorage, zeros(1,ChanObj.ChanNum-numel(ChanObj.DataStorage))] ;
			%else
			%	ChanObj.DataStorage=ChanObj.DataStorage(1:ChanObj.ChanNum); ;
			%end
			WrittenNum = DAQmxWriteAnalogF64(ChanObj.LibAlias, ChanObj.NITaskHandle, ChanObj.ChanNum, ChanObj.Timeout ,ChanObj.DataLayout, ChanObj.DataStorage);
		case 'Continuous'
			if ChanObj.CircBuf
				BufLen=length(ChanObj.DataStorage);
				WrittenNum = DAQmxWriteAnalogF64(ChanObj.LibAlias, ChanObj.NITaskHandle, ChanObj.ChanNum, ChanObj.Timeout ,ChanObj.DataLayout, circshift(ChanObj.DataStorage,-ChanObj.BufHead) );
				ChanObj.BufHead = mod(ChanObj.BufHead+WrittenNum,BufLen);
			else
				WrittenNum = DAQmxWriteAnalogF64(ChanObj.LibAlias, ChanObj.NITaskHandle, ChanObj.ChanNum, ChanObj.Timeout ,ChanObj.DataLayout, ChanObj.DataStorage(ChanObj.BufHead:end,:) );
				ChanObj.BufHead = ChanObj.BufHead + WrittenNum ;
			end
	end
	% TODO : should reshape or sort data ?
	if ~isempty(ChanObj.CallbackFunc)
		feval(ChanObj.CallbackFunc, ChanObj) % call user's function
	end
end

% set Task timing and make matlab timer.
function setTiming(obj)
	switch obj.Mode
		case 'Single'
			return ;
		case 'Finite'
			DAQmxCfgSampClkTiming(obj.LibAlias, obj.NITaskHandle, 10178, obj.Rate ,obj.SampleNum); % DAQmx_Val_FiniteSamps = 10178 % Finite Samples , Total data number set in SampleNum
		case 'Continuous'
			if obj.ProcPeriod % ~= 0
				if isempty(obj.TimerHandle)
					switch obj.ChanType
						case 'ai'
							TimerFcn_Handle=@aibg ;
						case 'ao'
							TimerFcn_Handle=@aobg ;
					end
					obj.TimerHandle = timer('TimerFcn',{TimerFcn_Handle,obj},'ExecutionMode','fixedRate','Period',obj.ProcPeriod,'StopFcn',@(~,~)obj.stop) ;
				else
					set(obj.TimerHandle , ...
						'ExecutionMode','fixedRate', ...
						'Period',obj.ProcPeriod, ...
						'StopFcn',@(~,~)obj.stop);
				end
			else
				if ~isempty(obj.TimerHandle)
					delete(obj.TimerHandle);
					obj.TimerHandle = [] ;
				end
			end
			DAQmxCfgSampClkTiming(obj.LibAlias, obj.NITaskHandle, 10123, obj.Rate ,obj.SampleNum); % DAQmx_Val_ContSamps = 10123 % Continuous Samples
	end
end

% Localize selected channel column from read data set. 
function DataColumnLgc = selectChan(obj,varargin)
	if nargin > 1
		%DataColumnLgc = logical(zeros(1,obj.ChanNum)) ;
		DataColumnLgc = false(1,obj.ChanNum) ;
		for arg_i = 1:(nargin-1)
			DataColumnLgc = DataColumnLgc | (sort(obj.ChanOccupancy) == obj.ChanOccupancy(strcmpi(obj.ChanAlias,varargin{arg_i} )) ) ;
		end
	else
		DataColumnLgc = true(1,obj.ChanNum) ;
		%DataColumnLgc = logical(ones(1,obj.ChanNum)) ;
	end
end