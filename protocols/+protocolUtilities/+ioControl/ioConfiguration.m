function io = ioConfiguration()
% lorenzpammer 2013/02

%% Example
% io(i).label = 'nameOfIOAction';
% io(i).type = 'string'; % indicate IO type by 'input' or 'output'
% io(i).value = 1; % the value which should 
% io(i).time = 0;
% io(i).used = 1;

% Fetch the user's configuration settings:
[label type value used time] = olfStimConfiguration('io');

% Create the structure
io = struct('label',label,'type',type,'value',value,...
    'used',used,'time',time);

end