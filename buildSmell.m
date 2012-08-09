function  buildSmell(instruction,trialOdor,trialNum,stimProtocol,protocolSpecificInfo)
% buildSmell(instruction,trialOdor,trialNum,stimProtocol) creates or
% updates the smell structure.
% The smell structure contains the relevant information about every trial
% for odor presentation. However it does not contain accurate timing
% information.
%
% stimProtocol does not have to be given as an input argument. If
% buildSmell is called from the stimulation protocol m-file, the function
% can extract the name of the protocol and write it into the smell
% structure.
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
%
% lorenzpammer 2011/09


global olfactometerOdors
global smell 
global olfactometerInstructions


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



%% Set up smell structure

if strcmp(instruction,'setUp')
   smell = setUpSmellStructure(smell, stimProtocol,protocolSpecificInfo); 
end
    

%% Update smell structure for every trial

if strcmp(instruction,'update')
    
    smell = updateSmellStructure(smell, trialOdor,trialNum,stimProtocol,protocolSpecificInfo);
end

end



function smell = setUpSmellStructure(smell, stimProtocol,protocolSpecificInfo)

global olfactometerOdors
global olfactometerInstructions

%%
    
 % Basic information about the current trial
    smell.olfactometerOdors = olfactometerOdors; % structure containing information which odors are loaded into olfactometer
    smell.version = 0; % Define here which version of the smell structure was used - if anything has to change in the future downstream algorithms know what to do.
    
    % Get this from the olfactometer
    smell.olfactometerSettings.maxFlowRateMfcAir = 1.5; % in liters/minute
    smell.olfactometerSettings.maxFlowRateMfcNitrogen = 0.1; % in liters/minute
    
    odorFields = fields(olfactometerOdors.sessionOdors(1));
    smell.trial(1) = cell2struct(cell(length(odorFields),1),odorFields,1); % all fields for each used odor are written to the smell structure: odorName,iupacName,CASNumber,producingCompany,odorantPurity,state,odorantDilution,dilutedIn,concentrationAtPresentation,inflectionPointResponseCurve,slave,vial,mixture,sessionOdorNumber
    smell.trial(1).trialNum = []; % Trial number in the current session
    smell.trial(1).stimProtocol = []; % which stimulation protocol was used for this session
    smell.trial(1).time = []; % time at time of start of a new trial (not the time of actual odor presentation)
    smell.trial(1).notes = []; % Notes that are taken during the session will be saved here. Every trial the notes are extracted from the field and written into this field in form of a string.\
    smell.trial(1).flowRateMfcAir = [];
    smell.trial(1).flowRateMfcN = [];
    
    % User defined times to instruct the olfactometer.
    % olfactometerInstructions structure is handled by
    % olfactometerSettings.m function
    smell.trial(1).olfactometerInstructions = olfactometerInstructions; 
        
    % Field for storing the event log from the LASOM after the execution of
    % the trial:
    smell.trial(1).lasomEventLog = [];
    % Field for storing the lsq file (lasom sequencer script) for each
    % trial:
    smell.trial(1).trialLsqFile = []; 
   
    % Here any information specific for the current protocol can be dumped
    smell.trial(1).protocolSpecificInfo = []; 
end

function smell = updateSmellStructure(smell, trialOdor,trialNum,stimProtocol,protocolSpecificInfo)

global olfactometerOdors
global olfactometerInstructions

% Extract the gui handle structure from the appdata of the figure:
    h=appdataManager('olfStimGui','get','h');
    

%%
    smell.trial(trialNum).odorName = []; % to set up a new struct array (1xtrialNum)
    % Find out how to extract information which function called buildSmell
    trialOdorFields = fields(trialOdor); % get name of fields in trialOdor (also present in smell
    % update first couple of fields (same as in trialOdor) with the data for the current trial.
    for i = 1 : length(trialOdorFields)
        smell.trial(trialNum) = setfield(smell.trial(trialNum),trialOdorFields{i},getfield(trialOdor,trialOdorFields{i})); 
    end
    smell.trial(trialNum).trialNum = trialNum;
    smell.trial(trialNum).stimProtocol = stimProtocol;
    smell.trial(trialNum).time = clock; % This only gives an approximate time, as the odor might be presented to the animal multiple seconds later.
    smell.trial(trialNum).protocolSpecificInfo = protocolSpecificInfo;
    try
        smell.trial(trialNum).notes = get(h.sessionNotes.notesFigureField,'String'); % Extract text in the notes field.
    catch
        dbstack
        disp(': No session notes available. Setting field blank.')
        smell.trial(trialNum).notes = [];
    end
    
    % olfactometerInstructions structure is updated in the
    % olfactometerSettings function prior to calling build smell. Now write
    % the updated instructions into the smell structure.
    smell.trial(trialNum).olfactometerInstructions = olfactometerInstructions;    

end