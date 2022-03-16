classdef monitor < handle
    % note : get figure number > numel(findobj('Type','figure'))
    properties
        %CheckArg = 1 ;
    end
    properties (SetAccess = private)
        x ;
        y ;
        y2 ;
        cm=colormap('lines');
        ParentHandle ;
        AxesHandle ;
        LineHandle ;
        title = {};
        xlabel = {};
        ylabel = {};
        ylim = {'auto'};
    end
    methods
        function obj=monitor(varargin)
            ArgParser(obj,varargin{:});
            
            if isempty(obj.AxesHandle) % parent of axes
                obj.AxesHandle = axes('XGrid','on','YGrid','on');
            end
            if ~isempty(obj.y)
                obj.new ;
                obj.plot;
            end
        end

        % Creat new axes/line object include data .
        function new(obj)
            %obj.AxesHandle=[];
            MaxPlotAxes = max([numel(obj.y),numel(obj.y2)]);
            if (numel(obj.AxesHandle) ~= MaxPlotAxes && ~isempty(obj.AxesHandle))% & ishghandle(obj.AxesHandle)
                delete(obj.LineHandle);
                delete(obj.AxesHandle);
                obj.AxesHandle=[];
                obj.LineHandle=[];
            end
            % auto delete 
            %if ~isempty(obj.LineHandle)
            %    delete(obj.LineHandle) ;
            %end
            
            for axes_i= 1:MaxPlotAxes
                obj.AxesHandle(axes_i)=subplot(MaxPlotAxes,1,axes_i,'Parent',obj.ParentHandle, ...
                    'XGrid','on','YGrid','on');
            end
            obj.ylim=repmat({'auto'},1,numel(obj.AxesHandle));
            
            %TODO: Did not write y2 code.
            if numel(obj.x) == 1
                for line_i=1:MaxPlotAxes        % Share x for each y set.
                    obj.LineHandle(line_i)=line(obj.x{1},obj.y{line_i}, ...
                        'LineStyle',':','Marker','+','Color',obj.cm(line_i,:),...
                        'Parent',obj.AxesHandle(line_i));
                    set(obj.AxesHandle(line_i),'XLim',[obj.x{1}(1),obj.x{1}(end)] ) ;
                end
            else
                for line_i=1:MaxPlotAxes
                    obj.LineHandle(line_i)=line(obj.x{line_i},obj.y{line_i}, ...
                        'LineStyle',':','Marker','+','Color',obj.cm(line_i,:),...
                        'Parent',obj.AxesHandle(line_i));
                        % 'DisplayName',num2str(line_i), <-- for legend , will slow.
                    if obj.x{line_i}(1) < obj.x{line_i}(end)
                        set(obj.AxesHandle(line_i),'XLim',[obj.x{line_i}(1),obj.x{line_i}(end)] ) ;
                    end
                end
            end
        end

        % Updata data for line object.
        function plot(obj,varargin)
            if nargin > 1
                ArgParser(obj,varargin{:});
                if numel(obj.AxesHandle) ~= max([numel(obj.y),numel(obj.y2)])
                    obj.new ;
                end
                if numel(obj.x) == 1        % "for" inside of "if" for speed.
                    for line_i=1:numel(obj.LineHandle)
                        set(obj.LineHandle(line_i),'XData',obj.x{1},'YData',obj.y{line_i}) ;
                        
                        if obj.x{1}(1) < obj.x{1}(end)
                            set(obj.AxesHandle(line_i),'XLim',[obj.x{1}(1),obj.x{1}(end)] ) ;
                        end
                    end
                else
                    for line_i=1:numel(obj.LineHandle)
                        set(obj.LineHandle(line_i),'XData',obj.x{line_i},'YData',obj.y{line_i}) ;
                        if obj.x{line_i}(1) < obj.x{line_i}(end)
                            set(obj.AxesHandle(line_i),'XLim',[obj.x{line_i}(1),obj.x{line_i}(end)] ) ;
                        end
                    end
                end
            end
            drawnow ;
        end
    end
end

function ArgParser(obj,varargin)
    %if obj.CheckArg
    if nargin > 1
        arg_i = 1 ;
        ResetLabel = 0;
        ArgTypeCelNum = zeros ;
        while arg_i <= numel(varargin)
            if ishghandle(varargin{arg_i}) %&& isempty(obj.AxesHandle) % parent of axes
                %obj.AxesHandle = axes('Parent', varargin{arg_i} ,'XGrid','on','YGrid','on');
                obj.ParentHandle = varargin{arg_i};
            elseif isnumeric(varargin{arg_i})
                ArgTypeCelNum (arg_i) = 1;
            elseif iscell(varargin{arg_i})
                for fi = 1 : numel(varargin{arg_i})
                    if ~isnumeric( varargin{arg_i}{fi})
                        error('error');
                    end
                end
                ArgTypeCelNum (arg_i) = 1;
            else
                switch lower( varargin{arg_i} )
                    case 'title'
                        if isstr(varargin{arg_i+1})
                            obj.title={ varargin{arg_i+1} };
                        elseif iscellstr(varargin{arg_i+1})
                            obj.title=varargin{arg_i+1} ;
                        else
                            error('Only allow string.');
                        end
                        ResetLabel = 1 ;
                        arg_i=arg_i +1;
                    case 'xlabel'
                        if isstr(varargin{arg_i+1})
                            obj.xlabel={ varargin{arg_i+1} };
                        elseif iscellstr(varargin{arg_i+1})
                            obj.xlabel=varargin{arg_i+1} ;
                        else
                            error('Only allow string.');
                        end
                        ResetLabel = 1 ;
                        arg_i=arg_i +1;
                    case 'ylabel'
                        if isstr(varargin{arg_i+1})
                            obj.ylabel={ varargin{arg_i+1} };
                        elseif iscellstr(varargin{arg_i+1})
                            obj.ylabel=varargin{arg_i+1} ;
                        else
                            error('Only allow string.');
                        end
                        ResetLabel = 1 ;
                        arg_i=arg_i +1;
                    case 'cll' % clear all label,title
                        obj.title=cell(1,numel(obj.AxesHandle));
                        obj.xlabel=cell(1,numel(obj.AxesHandle));
                        obj.ylabel=cell(1,numel(obj.AxesHandle));
                        ResetLabel = 1 ;
                    case 'ylim'
                        if isstr(varargin{arg_i+1}) 
                            if strcmpi(varargin(arg_i+1),'auto')
                                obj.ylim=repmat({'auto'},1,numel(obj.AxesHandle));
                            end
                        elseif iscellstr(varargin{arg_i+1})
                            % todo : did not check cell input.
                            obj.ylim=varargin{arg_i+1} ;
                        end
                        ChangeValueRange(obj);
                        arg_i=arg_i +1;
                    %otherwise
                end
            end
            arg_i = arg_i +1 ;
        end
        if ResetLabel
            SetLabel(obj) ;
        end
        % Store data to .x .y
        DataSet=find(ArgTypeCelNum) ;
        switch numel(DataSet)
            case 1
                %covert to cell , save to y1 , make x
                
                if isnumeric(varargin{DataSet})
                    obj.x={[ 1:numel(varargin{DataSet}) ]} ;
                    obj.y={ varargin{DataSet}  };
                else
                    for fi=1:numel(varargin{DataSet})
                        obj.x{fi}=[1:numel(varargin{DataSet}{fi}) ] ;
                    end
                    obj.y=varargin{DataSet} ;
                end
                
            case 2
                % I keep use x,y,y2 not x(1:3) for readability , and not eval.
                if isnumeric(varargin{DataSet(1)})
                    obj.x={ varargin{DataSet(1)} } ;
                else
                    obj.x=varargin{DataSet(1)} ;
                end
                if isnumeric(varargin{DataSet(2)})
                    obj.y={ varargin{DataSet(2)} } ;
                else
                    obj.y=varargin{DataSet(2)} ;
                end
            case 3
                % TODO : When y2 plot code finish ,delete below error line.
                error('This script did not support y2 data.')
                if isnumeric(varargin{DataSet(1)})
                    obj.x={ varargin{DataSet(1)} } ;
                else
                    obj.x=varargin{DataSet(1)} ;
                end
                if isnumeric(varargin{DataSet(2)})
                    obj.y={ varargin{DataSet(2)} } ;
                else
                    obj.y=varargin{DataSet(2)} ;
                end
                if isnumeric(varargin{DataSet(3)})
                    obj.y2={ varargin{DataSet(3)} } ;
                else
                    obj.y2=varargin{DataSet(3)} ;
                end
            otherwise
                error('Too many data set.')
        end
    end
end

function SetLabel(obj)
    for fi=1:numel(obj.AxesHandle)
        if fi <= numel(obj.title)
            title(obj.AxesHandle(fi),obj.title{fi});
        end
        if fi <= numel(obj.xlabel)
            xlabel(obj.AxesHandle(fi),obj.xlabel{fi});
        end
        if fi <= numel(obj.ylabel)
            ylabel(obj.AxesHandle(fi),obj.ylabel{fi});
        end
    end
end

function ChangeValueRange(obj)
    for fi=1:numel(obj.AxesHandle)
        if fi <= numel(obj.ylim)
            if ~isempty(obj.ylim{fi})
                ylim(obj.AxesHandle(fi),obj.ylim{fi});
            end
        end
    end
end
