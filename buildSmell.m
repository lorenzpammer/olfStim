function  buildSmell(instruction,olfactometerOdors,trialOdor,trialNum,stimProtocol,protocolSpecificInfo,varargin)
% buildSmell(instruction,trialOdor,trialNum,stimProtocol,protocolSpecificInfo,varargin) creates or
% updates the smell structure.
% The smell structure contains the relevant information about every trial
% for odor presentation. However it does not contain accurate timing
% information.
%
% Instruction:
% - 'setUp'
% - 'update': assumes there is a gui
% - 'updateFields'
%
% stimProtocol does not have to be given as an input argument. If
% buildSmell is called from the stimulation protocol m-file, the function
% can extract the name of the protocol and write it into the smell
% structure.
% 
% Possible fields to update in 'updateFields' option:
%     - 'trialOdor': will update all fields from the trial odor
%     - 'maxFlowRateMfc': no property value necessary.
%     - 'trialNum': no propertyValue necessary.
%     - 'stimProtocol': no propertyValue necessary.
%     - 'time': no propertyValue necessary.
%     - 'notes': no propertyValue necessary. Will extract notes
%        automatically from gui.
%     - 'log': no propertyValue necessary. Will extract the log messages
%        for the previous trial from the gui.
%     - 'olfactometerInstructions': no propertyValue necessary. Will
%        extract instructions automatically from gui.
%     - 'protocolSpecificInfo': no propertyValue necessary.
%     - 'sessionInstructions' - Is extracted from the gui. If we're in
%       olfStimSriptMode you have to provide the sessionInstructions
%       structure after 'sessionInstructions' option
%     - 'scientist' - Is extracted from the gui. If we're in
%       olfStimSriptMode you have to provide the sessionInstructions
%       structure after 'scientist' option
%     - 'animalName' - Is extracted from the gui. If we're in
%       olfStimSriptMode you have to provide the animalName
%       structure after 'sessionInstructions' option
%     - 'interTrialInterval' - Is extracted from the gui. If we're in
%       olfStimSriptMode you have to provide the animalName
%       structure after 'interTrialInterval' option
%     - 'io' : If no property value is provided, this option will pull the
%       current io variable from the appdata.
%
% NOTICE: If you want to add a new field to smell, remember to check:
% - If the new field will be populated during a trial with information
% about a trial, or in general if there's a for loop somewhere populating
% it incrementally, remember to append the
% removeHistoricalTrialDataFromSmell.m to clear the contents of the field.
% Otherwise if there's old data in the fields there might be problems
% overwriting them in a manualSessionProgramming stimulation protocol session. 
%
%
%
% TO DO: 
% - check whether it's possible to "lock" the structure of smell. ie no new
% fields are allowed to be added after the structure is once defined when
% calling buildSmell('update').
% - Write the numbers which will be output as 8-bit digital timestamps to
% the recording software for each valve and for each trial into the smell structure.
% - Document for every field of smell, in which step of an olfactory
% session it should be populated, updated etc.
%
% lorenzpammer 2011/09


global smell 
global olfactometerInstructions
global olfStimScriptMode

smellVersion = '0.1'; % version of smell structure

%% Import function packages

% Import all utility functions
import protocolUtilities.*


%% Check whether inputs are correct
if nargin < 1
    error('No instruction defined.')
elseif strcmp('setUp',instruction) && nargin < 3
    trialOdor = [];
    trialNum = [];
    %stimProtocol = dbstack;
    %stimProtocol = stimProtocol(2).file(1:end-2); % 
    stimProtocol = [];
    protocolSpecificInfo =[];
elseif ~isempty(strmatch('update',instruction)) && nargin<3
    error('For updating smell structure, trial odor information is necessary.')
elseif ~isempty(strmatch('update',instruction)) && nargin<4
    error('For updating smell structure, trial number is necessary.')
elseif ~isempty(strmatch('update',instruction)) && nargin<5
    stimProtocol = dbstack; % dbstack gives the function call stack, which function called the present function
    stimProtocol = stimProtocol(2).file(1:end-2); % 
elseif ~isempty(strmatch('update',instruction)) && nargin<6
    protocolSpecificInfo = []; % if no data is handed to the function for protocolSpecific Information this is set empty.
end

if nargin < 6
    protocolSpecificInfo =[];
end

%% Set up smell structure

if strcmp(instruction,'setUp')
   smell = setUpSmellStructure(smell, olfactometerOdors, stimProtocol,protocolSpecificInfo,smellVersion); 
end


%% Update all relevant elements of smell structure for the current trial
% 
if strcmp(instruction,'update')
    smell = updateSmellStructure(smell, trialOdor,trialNum,stimProtocol,protocolSpecificInfo,smellVersion);
end


%% Update a defined set of parameters in smell.

if strcmp(instruction,'updateFields')
     smell = updateFields(smell,trialOdor,trialNum,stimProtocol,protocolSpecificInfo,smellVersion,varargin);
end


end



function smell = setUpSmellStructure(smell, olfactometerOdors, stimProtocol,protocolSpecificInfo,smellVersion)

%global olfactometerOdors
global olfactometerInstructions
global olfStimTestMode

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Import function packages

% Import all utility functions
import protocolUtilities.*

%%

% Basic information about the current trial
smell.olfactometerOdors = olfactometerOdors; % structure containing information which odors are loaded into olfactometer
smell.version = smellVersion; % Define here which version of the smell structure was used - if anything has to change in the future downstream algorithms know what to do.

% Get the maximum flow rate of the mass flow controllers from the olfactometer
% If more than two MFCs are conntected, this code has to be adapted:
usedSlaves = find([smell.olfactometerOdors.slave.used]);
for i = usedSlaves
    if ~olfStimTestMode
        olfactometerH = olfactometerAccess.connect(false);
        [smell.olfactometerSettings.slave(i).maxFlowRateMfcAir, ~] = olfactometerAccess.getMaxFlowRateMfc(false, olfactometerH, i,1); % in liters/minute probably 1.5
        [smell.olfactometerSettings.slave(i).maxFlowRateMfcNitrogen,~] = olfactometerAccess.getMaxFlowRateMfc(false, olfactometerH, i,2); % in liters/minute probably 0.1
        % Field for storing information about LASOM (firmware, etc.)
        smell.olfactometerSettings.olfactometerID = olfactometerAccess.getID(false,olfactometerH);
        release(olfactometerH);
    else % if we're in the test mode write some default values into the olfactometerSettings. Otherwise downstream code will break.
        smell.olfactometerSettings.slave(i).maxFlowRateMfcAir = 1.5;
        smell.olfactometerSettings.slave(i).maxFlowRateMfcNitrogen = 0.1;
        smell.olfactometerSettings.olfactometerID = [];
    end
end

odorFields = fields(olfactometerOdors.sessionOdors(1));
smell.trial(1) = cell2struct(cell(length(odorFields),1),odorFields,1); % all fields for each used odor are written to the smell structure: odorName,iupacName,CASNumber,producingCompany,odorantPurity,state,odorantDilution,dilutedIn,concentrationAtPresentation,inflectionPointResponseCurve,slave,vial,mixture,sessionOdorNumber
smell.trial(1).isSequence = []; % Whether multiple different odors are presented sequentially within one trial.
smell.trial(1).trialNum = []; % Trial number in the current session
smell.trial(1).stimProtocol = []; % which stimulation protocol was used for this session
smell.trial(1).time = []; % time at time of start of a new trial (not the time of actual odor presentation)
%     smell.trial(1).interTrialInterval = 0; % First trial has a intertrial-interval of 0 seconds.
smell.trial(1).notes = []; % Notes that are taken during the session will be saved here. Every trial the notes are extracted from the field and written into this field in form of a string.\
smell.trial(1).flowRateMfcAir = []; % Field contains the target flow rate for the air mass flow controller 
smell.trial(1).flowRateMfcN = []; % Field contains the target flow rate for the Nitrogen mass flow controller
smell.trial(1).log = []; % field for storing log messages

% User defined times to instruct the olfactometer.
% olfactometerInstructions structure is handled by
% olfactometerSettings.m function
smell.trial(1).olfactometerInstructions = olfactometerInstructions;

% User defined settings for the current session. sessionInstructions
% structure is produced by sessionSettings.m and written into the
% appdata of the gui.
sessionSettings(h,'setUpStructure'); % Create structure and write into appdata
% Extract the sessionInstructions structure from the appdata of the figure:
sessionInstructions=appdataManager('olfStimGui','get','sessionInstructions');
smell.trial(1).sessionInstructions = sessionInstructions;

% Field for storing the event log from the LASOM after the execution of
% the trial:
smell.trial(1).olfactometerEventLog.flowRateMfcAir = [];
smell.trial(1).olfactometerEventLog.flowRateMfcN = [];
% Field for storing the lsq file (lasom sequencer script) for each
% trial:
smell.trial(1).trialLsqFile = [];

% Set up the structure containing information about I/O io (triggers, timestamps, etc.).
smell.trial(1).io = ioControl.ioConfiguration;

% Here any information specific for the current protocol can be dumped
smell.trial(1).protocolSpecificInfo = [];

end

function smell = updateSmellStructure(smell,trialOdor,trialNum,stimProtocol,protocolSpecificInfo,smellVersion)

global olfactometerInstructions

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Import function packages

% Import all utility functions
import protocolUtilities.*

%% Update the relevant fields for the current trial

smell.version = smellVersion; % Define which version of the smell structure was used - if anything has to change in the future downstream algorithms know what to do.
smell.trial(trialNum).odorName = []; % to set up a new struct array (1xtrialNum)
% Find out how to extract information which function called buildSmell
trialOdorFields = fields(trialOdor); % get name of fields in trialOdor (also present in smell
% update first couple of fields (same as in trialOdor) with the data for the current trial.
for i = 1 : length(trialOdorFields)
    smell.trial(trialNum) = setfield(smell.trial(trialNum),trialOdorFields{i},getfield(trialOdor,trialOdorFields{i}));
end
if length(smell.trial(trialNum).odorName) > 1
    smell.trial(trialNum).isSequence = true;
else
    smell.trial(trialNum).isSequence = false;
end

smell.trial(trialNum).trialNum = trialNum;
smell.trial(trialNum).stimProtocol = stimProtocol;
smell.trial(trialNum).time = clock; % This only gives an approximate time, as the odor might be presented to the animal multiple seconds later.
smell.trial(trialNum).protocolSpecificInfo = protocolSpecificInfo;

% Only extract notes from gui if we're not in scripting mode:
%if isempty(olfStimScriptMode)
    smell.trial(trialNum).notes = protocolUtilities.notes.extract(h); % extract the notes
%end

if trialNum > 1
    % Extract the log messages for the last trial, because at the time of
    % calling update smell  the current trial hasn't even started yet.
    smell.trial(trialNum-1).log = protocolUtilities.logWindow.extract(1); 
end

% olfactometerInstructions structure is updated in the
% olfactometerSettings function prior to calling build smell. Now write
% the updated instructions into the smell structure.
smell.trial(trialNum).olfactometerInstructions = olfactometerInstructions;


% sessionInstructions structure is updated in the
% sessionSettings function prior to calling build smell. Now write
% the updated instructions into the smell structure.
sessionSettings(h,'get'); % Create structure and write into appdata
% Extract the sessionInstructions structure from the appdata of the figure:
sessionInstructions=appdataManager('olfStimGui','get','sessionInstructions');
smell.trial(trialNum).sessionInstructions = sessionInstructions;

% The list of I/O actions can be updated from the gui. If the user updated
% some actions, the io variable in the appdata will be updated. Pull the
% current io variable from the appdata and update the io field in
% smell.trial(trialNum):
smell.trial(trialNum).io = appdataManager('olfStimGui','get','io');

end

function smell = updateFields(smell,trialOdor,trialNum,stimProtocol,protocolSpecificInfo,smellVersion,fieldsToUpdate)

%global olfactometerOdors
global olfactometerInstructions
global olfStimTestMode
global olfStimScriptMode

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');
%% Import function packages

% Import all utility functions
import protocolUtilities.*

%% Update smell version
% Define here which version of the smell structure was used - if anything has to change in the future downstream algorithms know what to do.
smell.version = smellVersion; 
%% Update the fields specified in varargin
% varargin includes the information in the form
% 'PropertyName','PropertyValue'

if any(strcmpi('trialOdor',fieldsToUpdate))
    smell.trial(trialNum).odorName = []; % to set up a new struct array (1xtrialNum)
    % Find out how to extract information which function called buildSmell
    trialOdorFields = fields(trialOdor); % get name of fields in trialOdor (also present in smell
    % update first couple of fields (same as in trialOdor) with the data for the current trial.
    for i = 1 : length(trialOdorFields)
        smell.trial(trialNum) = setfield(smell.trial(trialNum),trialOdorFields{i},getfield(trialOdor,trialOdorFields{i}));
    end
end

if any(strcmpi('trialNum',fieldsToUpdate))
    smell.trial(trialNum).trialNum = trialNum;
end

if any(strcmpi('stimProtocol',fieldsToUpdate))
    smell.trial(trialNum).stimProtocol = stimProtocol;
end

if any(strcmpi('time',fieldsToUpdate))
    smell.trial(trialNum).time = clock; % This only gives an approximate time, as the odor might be presented to the animal multiple seconds later.
end

if any(strcmpi('notes',fieldsToUpdate))
    % Extract the notes from the gui
    smell.trial(trialNum).notes = protocolUtilities.notes.extract(h); % extract the notes
end

if any(strcmpi('log',fieldsToUpdate)) && trialNum > 1
    % Extract the log messages from the gui for the last trial, because at
    % the time of calling update smell  the current trial hasn't even started yet.
    smell.trial(trialNum-1).log = protocolUtilities.logWindow.extract(1); 
end

if any(strcmpi('olfactometerInstructions',fieldsToUpdate))
    smell.trial(trialNum).olfactometerInstructions = olfactometerInstructions;
end

if any(strcmpi('protocolSpecificInfo',fieldsToUpdate))
    smell.trial(trialNum).protocolSpecificInfo = protocolSpecificInfo;
end

if any(strcmpi('sessionInstructions',fieldsToUpdate))
    if isempty(olfStimScriptMode)
        % sessionInstructions structure is updated in the
        % sessionSettings function prior to calling build smell. Now write
        % the updated instructions into the smell structure.
        sessionSettings(h,'get'); % Create structure and write into appdata
        % Extract the sessionInstructions structure from the appdata of the figure:
        sessionInstructions=appdataManager('olfStimGui','get','sessionInstructions');
    else
        index = find(strcmp('sessionInstructions',fieldsToUpdate));
        sessionInstructions=fieldsToUpdate{index+1};
    end
    smell.trial(trialNum).sessionInstructions = sessionInstructions;
end
if any(strcmpi('scientist',fieldsToUpdate))
    if isempty(olfStimScriptMode)
        % sessionInstructions structure is updated in the
        % sessionSettings function prior to calling build smell. Now write
        % the updated instructions into the smell structure.
        sessionSettings(h,'get'); % Create structure and write into appdata
        % Extract the sessionInstructions structure from the appdata of the figure:
        sessionInstructions=appdataManager('olfStimGui','get','sessionInstructions');
        index = strmatch('scientist', {sessionInstructions.name});
        smell.trial(trialNum).sessionInstructions(index).value = sessionInstructions(index).value;
    else
        index = find(strcmp('scientist',fieldsToUpdate));
        smell.trial(trialNum).sessionInstructions(index).value = fieldsToUpdate{index+1};
    end
    
end
if any(strcmpi('animalName',fieldsToUpdate))
    if isempty(olfStimScriptMode)
        % sessionInstructions structure is updated in the
        % sessionSettings function prior to calling build smell. Now write
        % the updated instructions into the smell structure.
        sessionSettings(h,'get'); % Create structure and write into appdata
        % Extract the sessionInstructions structure from the appdata of the figure:
        sessionInstructions=appdataManager('olfStimGui','get','sessionInstructions');
        index = strmatch('animalName', {sessionInstructions.name});
        smell.trial(trialNum).sessionInstructions(index).value = sessionInstructions(index).value;
    else
        index = find(strcmp('animalName',fieldsToUpdate));
        smell.trial(trialNum).sessionInstructions(index).value = fieldsToUpdate{index+1};
    end
    
end
if any(strcmpi('interTrialInterval',fieldsToUpdate))
    if ~olfStimScriptMode
    sessionSettings(h,'get'); % Create structure and write into appdata
    % Extract the sessionInstructions structure from the appdata of the figure:
    sessionInstructions=appdataManager('olfStimGui','get','sessionInstructions');
    index = strmatch('interTrialInterval', {sessionInstructions.name});
    smell.trial(trialNum).sessionInstructions(index).value = sessionInstructions(index).value;
    else
        index = find(strcmp('animalName',fieldsToUpdate)); % This should give an error. Why is nothing happening?
        smell.trial(trialNum).sessionInstructions(index).value = fieldsToUpdate{index+1};;
    end
    
end

if any(strcmpi('maxFlowRateMfc',fieldsToUpdate))
    % Get the maximum flow rate of the mass flow controllers from the olfactometer
    % If more than two MFCs are conntected, this code has to be adapted:
    usedSlaves = find([smell.olfactometerOdors.slave.used]);
    for i = usedSlaves
        if ~olfStimTestMode
            olfactometerH = olfactometerAccess.connect(false);
            [smell.olfactometerSettings.slave(i).maxFlowRateMfcAir, ~] = olfactometerAccess.getMaxFlowRateMfc(false, olfactometerH, i,1); % in liters/minute probably 1.5
            [smell.olfactometerSettings.slave(i).maxFlowRateMfcNitrogen,~] = olfactometerAccess.getMaxFlowRateMfc(false, olfactometerH, i,2); % in liters/minute probably 0.1
            release(olfactometerH);
        else
            smell.olfactometerSettings.slave(i).maxFlowRateMfcAir = 1.5;
            smell.olfactometerSettings.slave(i).maxFlowRateMfcNitrogen = 0.1;
        end
    end
end
if any(strcmpi('olfactometerID',fieldsToUpdate))
    % Field for storing information about LASOM (firmware, etc.)\
    if ~olfStimTestMode
        olfactometerH = olfactometerAccess.connect(false);
        smell.olfactometerSettings.olfactometerID = olfactometerAccess.getID(false,olfactometerH);
        release(olfactometerH);
    else
        smell.olfactometerSettings.olfactometerID = '';
    end
end
if any(strcmpi('io',fieldsToUpdate))
    if isempty(olfStimScriptMode)
        index = find(strcmp('io',fieldsToUpdate));
        try
            io = fieldsToUpdate{index+1};
            if ~isstruct(io)
                error('jump to catch')
            end
        catch
            io = appdataManager('olfStimGui','get','io');
        end
    else
        io = olfStimConfiguration('io','structure');
    end
    smell.trial(trialNum).io = io;
end
    
end