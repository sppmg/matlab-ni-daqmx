function DemoProc_flit(obj)
	persistent mon fig;
	if nargin == 0
		% Action by direct run this function file.
		close all;
        %delete(timerfindall);
%         clear classes;
        try
            unloadlibrary nidaqmx;
        end

		
		daq = daqmx_Task('chan','dev3/ai0','alias',{'a'},'rate',100,'callbackfunc','DemoProc','ProcPeriod',0.3);
        cutFreq_real = DAQmxAILowpass(daq.LibAlias, daq.NITaskHandle, 'dev3/ai0', 10) ;
		daq.DataStorageLen = 500 ;
		daq.resetDev;
		daq.start;
		pause(10);
		%figure; plot(daq.DataTime , daq.data); % plot 3 lines of each channel .
		%figure; plot(daq.DataTime , daq.data('a') ); % plot ecg_ra only .
		daq.stop;
	else
		% Careful , this section variable scope is different with above.
		if obj.DataTotalNumPerChan > 0
			if ~isa(mon,'monitor')
				% Initialization
				fig=figure('Renderer','OpenGL') ;
				mon=monitor(fig,obj.DataTime,obj.data('a'));
			else
				% Action when every loop , call by timer .
				mon.plot(obj.DataTime,obj.data('a'));
			end
		end
	end
end