# matlab ni daqmx
For easy control NI DAQ in Matlab by use NI dll.(Without Data Acquisition Toolbox)

## Why you should use this ?

1. Easy.
2. Stable. (See "why I create this".)

## How wasy ?

### Read a votage.

```
daq = daqmx_Task('dev1/ai0');  % create control object.
daq.read
```

### Monitor signal. (Read voltage and plot it.)

```
daq = daqmx_Task('chan','dev1/ai0','rate',1000); % create control object.
plot(daq.DataTime , daq.data);   % Plot data inside of object. Use loop or callback get continuous signal.
```

Compare with Matlab Data Acquisition Toolbox

```
s = daq.createSession('ni') ;
s.DurationInSeconds = 10.0 ;
addAnalogInputChannel(s,'Dev2','ai0','Voltage') ;
s.Rate=4000 ;

% data = startForeground(s); <-- Block mode

lh = addlistener(s,'DataAvailable', @proc) ;  % <-- Background mode
s.startBackground


% Below write in "proc" function
plot(event.TimeStamps, event.Data,'+:')
```

## Why I create this ?

Because Data Acquisition Toolbox in Matlab 2011b has a bug, it can not read complete signal in continuous mode.

And I know peoples love this tool so I separate daqmx tool from my matlab repository.

## Usage
Read manual*.html. *.t2t is source write by txt2tags format. Read demo/ also.

If you need english manual, make a issue :D 

## Install
1. Download DAQmxMidLib/ and daqmx_Task.m . 
2. Make sure above files under your matlab search path.

## Thanks
Thanks **Nathan Tomlin** write "daqmx example" first.
