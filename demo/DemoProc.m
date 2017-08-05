function DemoProc(obj)
	persistent mon fig;
	if nargin == 0
		% Action by direct run this function file.
		close all;
		clear classes;
		daq = daqmx_Task('chan','dev1/ai0:2','alias',{'a','b','c'},'rate',100,'callbackfunc','DemoProc','ProcPeriod',0.3);
		daq.DataWindowLen = 500 ;
		daq.ResetDev;
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