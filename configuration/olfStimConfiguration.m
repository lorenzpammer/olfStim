function varargout = olfStimConfiguration(requestedConfiguration)
% varargout = olfStimConfiguration(requestedConfiguration)
%
% lorenzpammer 2013/03


%% Valves
%
% Define the name of the valve actions you want to be able to use.
% Define the default time values in seconds, when they should be triggered.
% Define whether they should be active by default (you can change this from
% the gui for every trial).

if strmatch(requestedConfiguration,'valves')
% Each of these actions has a respective block of sequencer code in the
% /lsq folder. These sequencer code snippets must have the same filename as
% the names defined in the cell array below. Therefore if you add a new
% action or change the name of the action, you have to add or change the
% name of a sequencer code snippet in the /lsq folder.
names = {'powerGatingValve' 'unpowerGatingValve' ,...
    'powerFinalValve' 'unpowerFinalValve' 'closeSuctionValve' 'openSuctionValve',...
    'openSniffingValve' 'closeSniffingValve' 'powerHumidityValve' 'unpowerHumidityValve',...
    'cleanNose'}; % removed 'mfcTotalFlow' 'purge'


% Default time values (in seconds) for the actions defined above. The order
% of values has to match the order of names defined above.
values = {0 5 3 5 3.25 5 3.5 5 9 12 10};

% Define below whether an action should be used in a trial by default. Set
% 1 for use. Set 0 for not used. The order of values has to match the order
% of names defined above.
used = {1 1 1 1 0 0 1 1 0 0 1};

% whether (1) or not (0) an editing field should be added to the gui for
% the respective setting:
useEditField = logical([1 1 1 1 1 1 1 1 1 1 1]);

% whether (1) or not (0) a checkbox indicating used/non-used should be
% added to the gui for the respective setting.
useCheckBox = logical([1 0 1 0 1 0 1 0 1 0 1]); % whether or not a checkbox indicating used/non-used should be added to the gui

% On which setting (written as a string) a given setting (sequence) is
% dependent. 
dependentOnSetting = {0 'powerGatingValve' 0 'powerFinalValve' 0 ... 
    'closeSuctionValve' 0 'openSniffingValve' 0 'powerHumidityValve' 0};

% Timestamps 
timestamps = [];


varargout = {names values used timestamps useEditField useCheckBox dependentOnSetting};

end


%%


end