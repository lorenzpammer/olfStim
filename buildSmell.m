function  buildSmell(instruction,trialOdor,trialNum,stimProtocol,protocolSpecificInfo,varargin)
% buildSmell(instruction,trialOdor,trialNum,stimProtocol,protocolSpecificInfo,varargin) creates or
% updates the smell structure.
% The smell structure contains the relevant information about every trial
% for odor presentation. However it does not contain accurate timing
% information.
%
% Instruction:
% - 'setUp'
% - 'update'
% - 'updateFields'
%
% stimProtocol does not have to be given as an input argument. If
% buildSmell is called from the stimulation protocol m-file, the function
% can extract the name of the protocol and write it into the smell
% structure.
%
% Possible properties:
%     - 'trialNum': no propertyValue necessary.
%     - 'stimProtocol': no propertyValue necessary.
%     - 'time': no propertyValue necessary.
%     - 'notes': no propertyValue necessary. Will extract notes
%     automatically from gui.
%     - 'olfactometerInstructions': no propertyValue necessary. Will
%     extract instructions automatically from gui.
%     - 'protocolSpecificInfo': no propertyValue necessary.
%     - 'interTrialInterval': propertyValue necessary. Give intertrial
%     interval in seconds.
%     - 'sessionInstructions'
%     - 'scientist'
%     - 'animalName'
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
% - Get accurate timing information after trial from LASOM module and
% write this into the smell structure, as a sanity check.
% - check whether it's possible to "lock" the structure of smell. ie no new
% fields are allowed to be added after the structure is once defined when
% calling buildSmell('update').
% - Write the numbers which will be output as 8-bit digital timestamps to
% the recording software for each valve and for each trial into the smell structure.
% - prompt LASOM to get the maximum flow rate of the Mfcs
% - add intertrial interval information to each smell.trial
% - Document for every field of smell, in which step of an olfactory
% session it should be populated, updated etc.
%
% lorenzpammer 2011/09


global olfactometerOdors
global smell 
global olfactometerInstructions

smellVersion = 0; % version of smell structure

%% Import function packages

% Import all utility functions
import protocolUtilities.*


%% Check whether inputs are correct
if nargin < 1
    error('No instruction defined.')
elseif strcmp('setUp',instruction) && nargin < 2
    trialOdor = [];
    trialNum = [];
    stimProtocol = dbstack;
    stimProtocol = stimProtocol(2).file(1:end-2); % 
    protocolSpecificInfo =[];
elseif ~isempty(strmatch('update',instruction)) && nargin<2
    error('For updating smell structure, trial odor information is necessary.')
elseif ~isempty(strmatch('update',instruction)) && nargin<3
    error('For updating smell structure, trial number is necessary.')
elseif ~isempty(strmatch('update',instruction)) && nargin<4
    stimProtocol = dbstack; % dbstack gives the function call stack, which function called the present function
    stimProtocol = stimProtocol(2).file(1:end-2); % 
elseif ~isempty(strmatch('update',instruction)) && nargin<5
    protocolSpecificInfo = []; % if no data is handed to the function for protocolSpecific Information this is set empty.
end

if nargin< 5
    protocolSpecificInfo =[];
end

%% Set up smell structure

if strcmp(instruction,'setUp')
   smell = setUpSmellStructure(smell, stimProtocol,protocolSpecificInfo,smellVersion); 
end
    

%% Update all relevant elements of smell structure for the current trial
% 
if strcmp(instruction,'update')
    smell = updateSmellStructure(smell, trialOdor,trialNum,stimProtocol,protocolSpecificInfo,smellVersion);
end


%% Update a defined set of parameters in smell.

if strcmp(instruction,'updateFields')
     smell = updateFields(smell,trialNum,stimProtocol,protocolSpecificInfo,smellVersion,varargin);
end


end



function smell = setUpSmellStructure(smell, stimProtocol,protocolSpecificInfo,smellVersion)

global olfactometerOdors
global olfactometerInstructions

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Import function packages

% Import all utility functions
import protocolUtilities.*

%%

% Basic information about the current trial
smell.olfactometerOdors = olfactometerOdors; % structure containing information which odors are loaded into olfactometer
smell.version = smellVersion; % Define here which version of the smell structure was used - if anything has to change in the future downstream algorithms know what to do.

% Get this from the olfactometer
smell.olfactometerSettings.maxFlowRateMfcAir = 1.5; % in liters/minute
smell.olfactometerSettings.maxFlowRateMfcNitrogen = 0.1; % in liters/minute
% Field for storing information about LASOM (firmware, etc.)
smell.olfactometerSettings.lasomID = [];

odorFields = fields(olfactometerOdors.sessionOdors(1));
smell.trial(1) = cell2struct(cell(length(odorFields),1),odorFields,1); % all fields for each used odor are written to the smell structure: odorName,iupacName,CASNumber,producingCompany,odorantPurity,state,odorantDilution,dilutedIn,concentrationAtPresentation,inflectionPointResponseCurve,slave,vial,mixture,sessionOdorNumber
smell.trial(1).isSequence = []; % Whether multiple different odors are presented sequentially within one trial.
smell.trial(1).trialNum = []; % Trial number in the current session
smell.trial(1).stimProtocol = []; % which stimulation protocol was used for this session
smell.trial(1).time = []; % time at time of start of a new trial (not the time of actual odor presentation)
%     smell.trial(1).interTrialInterval = 0; % First trial has a intertrial-interval of 0 seconds.
smell.trial(1).notes = []; % Notes that are taken during the session will be saved here. Every trial the notes are extracted from the field and written into this field in form of a string.\
smell.trial(1).flowRateMfcAir = [];
smell.trial(1).flowRateMfcN = [];

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
smell.trial(1).lasomEventLog.flowRateMfcAir = [];
smell.trial(1).lasomEventLog.flowRateMfcN = [];
% Field for storing the lsq file (lasom sequencer script) for each
% trial:
smell.trial(1).trialLsqFile = [];

% Here any information specific for the current protocol can be dumped
smell.trial(1).protocolSpecificInfo = [];
end

function smell = updateSmellStructure(smell, trialOdor,trialNum,stimProtocol,protocolSpecificInfo,smellVersion)

global olfactometerOdors
global olfactometerInstructions

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Import function packages

% Import all utility functions
import protocolUtilities.*

%%
smell.version = smellVersion; % Define here which version of the smell structure was used - if anything has to change in the future downstream algorithms know what to do.
smell.trial(trialNum).odorName = []; % to set up a new struct array (1xtrialNum)
% Find out how to extract information which function called buildSmell
trialOdorFields = fields(trialOdor); % get name of fields in trialOdor (also present in smell
% update first couple of fields (same as in trialOdor) with the data for the current trial.
for i = 1 : length(trialOdorFields)
    smell.trial(trialNum) = setfield(smell.trial(trialNum),trialOdorFields{i},getfield(trialOdor,trialOdorFields{i}));
end
smell.trial(trialNum).isSequence = false;
smell.trial(trialNum).trialNum = trialNum;
smell.trial(trialNum).stimProtocol = stimProtocol;
smell.trial(trialNum).time = clock; % This only gives an approximate time, as the odor might be presented to the animal multiple seconds later.
smell.trial(trialNum).protocolSpecificInfo = protocolSpecificInfo;
smell.trial(trialNum).notes = protocolUtilities.getUserNotes(h); % extract the notes

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

end

function smell = updateFields(smell,trialNum,stimProtocol,protocolSpecificInfo,smellVersion,fieldsToUpdate)

global olfactometerOdors
global olfactometerInstructions

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
    smell.trial(trialNum).notes = protocolUtilities.getUserNotes(h); % extract the notes
end

if any(strcmpi('olfactometerInstructions',fieldsToUpdate))
    smell.trial(trialNum).olfactometerInstructions = olfactometerInstructions;
end

if any(strcmpi('protocolSpecificInfo',fieldsToUpdate))
    smell.trial(trialNum).protocolSpecificInfo = protocolSpecificInfo;
end

if any(strcmpi('interTrialInterval',fieldsToUpdate))
    index = find(strcmp('interTrialInterval',varargin));
    value = fieldsToUpdate{index+1};
    smell.trial(trialNum).interTrialInterval = value;
end

if any(strcmpi('sessionInstructions',fieldsToUpdate))
    % sessionInstructions structure is updated in the
    % sessionSettings function prior to calling build smell. Now write
    % the updated instructions into the smell structure.
    sessionSettings(h,'get'); % Create structure and write into appdata
    % Extract the sessionInstructions structure from the appdata of the figure:
    sessionInstructions=appdataManager('olfStimGui','get','sessionInstructions');
    smell.trial(trialNum).sessionInstructions = sessionInstructions;
end
if any(strcmpi('scientist',fieldsToUpdate))
    % sessionInstructions structure is updated in the
    % sessionSettings function prior to calling build smell. Now write
    % the updated instructions into the smell structure.
    sessionSettings(h,'get'); % Create structure and write into appdata
    % Extract the sessionInstructions structure from the appdata of the figure:
    sessionInstructions=appdataManager('olfStimGui','get','sessionInstructions');
    index = strmatch('scientist', {sessionInstructions.name});
    smell.trial(trialNum).sessionInstructions(index).value = sessionInstructions(index).value;
end
if any(strcmpi('animalName',fieldsToUpdate))
    % sessionInstructions structure is updated in the
    % sessionSettings function prior to calling build smell. Now write
    % the updated instructions into the smell structure.
    sessionSettings(h,'get'); % Create structure and write into appdata
    % Extract the sessionInstructions structure from the appdata of the figure:
    sessionInstructions=appdataManager('olfStimGui','get','sessionInstructions');
    index = strmatch('animalName', {sessionInstructions.name});
    smell.trial(trialNum).sessionInstructions(index).value = sessionInstructions(index).value;
end

end