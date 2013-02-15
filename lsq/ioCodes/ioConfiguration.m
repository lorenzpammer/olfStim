function io = ioConfiguration()
% lorenzpammer 2013/02

%% Example
% i = i+1;
% io(i).label = 'nameOfIOAction';
% io(i).type = 'string'; % indicate IO type by 'input' or 'output'
% io(i).value = 1; % the value which should 
% io(i).time = 0;
% io(i).used = 1;

%%
i = 0;
%% IO #1
i = i+1;
io(i).label = 'waitForTrigger';
io(i).type = 'input';
io(i).value = 1;
io(i).time = 0;
io(i).used = 1;

%% IO #2
i = i+1;
io(i).label = 'sendTimestamp';
io(i).type = 'output';
io(i).value = 2;
io(i).time = 0;
io(i).used = 0;


%% Paste new io entries above this end:
end

