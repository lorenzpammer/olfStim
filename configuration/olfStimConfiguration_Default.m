function varargout = olfStimConfiguration(requestedConfiguration,varargin)
% varargout = olfStimConfiguration(requestedConfiguration)
%
% - 'generalInformation'
% - 'odorants'
% - 'valves'
% - 'io'
%
% lorenzpammer 2013/03

%% 
if nargin < 2
    varargin = [];
end

%% General information
% This option will only return the general information in the
% olfStimConfigurations file, such as the name of the experimenter (user).

if strmatch(requestedConfiguration,'generalInformation')
    userName = ''; % ADD YOUR USERNAME HERE
    varargout={userName};
end

%% Valves Options
% Define the name of the valve actions you want to be able to use.
% Define the default time values in seconds, when they should be triggered.
% Define whether they should be active by default (you can change this from
% the gui for every trial).

if strmatch(requestedConfiguration,'valves')
% Each of these actions has to have a corresponding block of sequencer code in the
% olfStim/lsq/ folder. These sequencer code snippets must have the same filename as
% the names defined in the cell array below. Therefore if you add a new
% action or change the name of the action, you have to add or change the
% name of a sequencer code snippet in the olfStim/lsq/ folder.
% It is not advisable to alter the gating valve and final valve names. You
% would have to alter the cleanOlfactometerStim.m file for the
% olfactometerCleaning protocol to continue working.
actionNames = {'powerGatingValve' 'unpowerGatingValve' ,...
    'powerFinalValve' 'unpowerFinalValve' 'closeSuctionValve' 'openSuctionValve',...
    'openSniffingValve' 'closeSniffingValve' 'powerHumidityValve' 'unpowerHumidityValve',...
    'cleanNose'};

% % Names of involved valve. For prettier Gui labelling. Currently not used.
% valveNames = {'gatingValve' 'gatingValve' 'finalValve' 'finalValve',...
%     'suctionValve' 'suctionValve' 'sniffingValve' 'sniffingValve',...
%     'humidityValve' 'humidityValve' ''};


% Define default values and gui behaviors for each of the actions:
% Each action has one entry in the variables below. The order of the entries
% has to match the order of the actions in the actionNames variable.

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


varargout = {actionNames values used timestamps useEditField useCheckBox dependentOnSetting};

end

%% I/O Options
% Timestamps, triggers, etc.

if strmatch(requestedConfiguration,'io')

% Each of these actions has to have a corresponding block of sequencer code in the
% olfStim/lsq/io/ folder. These sequencer code snippets must have the same
% filename as the names defined in the cell array below. Therefore if you
% add a new action or change the name of the action, you have to add or change the
% name of a sequencer code snippet in the olfStim/lsq/io/ folder.
label = {'waitForTrigger' 'DigOut1High' 'DigOut1Low' 'DigOut2High' 'DigOut2Low' 'DigOut3High' 'DigOut3Low'}; % CHANGE FOR NEW I/O ACTION

% Define which type of I/O this is.
type = {'input' 'output' 'output' 'output' 'output' 'output' 'output'}; % CHANGE FOR NEW I/O ACTION

% Should the I/O action be used by default?
used = {false true true false false false false}; % CHANGE FOR NEW I/O ACTION

% This is currently not used. 
value = {1 1 0 1 0 1 0}; % CHANGE FOR NEW I/O ACTION

% Time point after the start of the trial at which the action is triggered.
time = {0 0 3 3 5 3 5}; % CHANGE FOR NEW I/O ACTION

if strcmp(varargin,'structure')
    % if 'structure' is requested in the inputs, output the I/O information
    % as the io structure
    io = struct('label',label,'type',type,'value',value,'used',used,'time',time);
    varargout = {io};
else
    % otherwise output the individual variables
    varargout = {label type value used time};
end
end

%% Odor Selection Options
% Define the default values for the odorSelectionGui.

if strmatch(requestedConfiguration,'odorSelectionGui')
% The number of odor vials used in all slaves. The default value can be set here.
numberOfVialsPerSlave = 10;

% Number of slaves that should be shown in the odorSelectionGui by default.
numberOfSlavesTables = 1;

% Whether the mixture table should be shown in the odorSelectionGui by default.
showMixtureTables = 0;

varargout = {numberOfVialsPerSlave,numberOfSlavesTables,showMixtureTables};
end

end