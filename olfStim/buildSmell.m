function smell = buildSmell(instruction,trialOdor,trialNum,stimProtocol,protocolSpecificInfo)
% buildSmell(instruction,trialOdor,trialNum,stimProtocol) creates or
% updates the smell structure.
% The smell structure contains the relevant information about every trial
% odor presentation. However it does not contain accurate timing
% information.
%
% stimProtocol does not have to be given as an input argument. If
% buildSmell is called from the stimulation protocol m-file, the function
% can extract the name of the protocol and write it into the smell
% structure.
%
% TO DO: Get accurate timing information after trial from LASOM module and
% write this into the smell structure.

% lorenzpammer 2011/09


global olfactometerOdors
global h

%% Check whether inputs are correct
if nargin < 1
    error('No instruction defined.')
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

if ~isempty(strmatch(instruction,'setUp'))
smell.olfactometerOdors = olfactometerOdors; % structure containing information which odors are loaded into olfactometer
smell.version = 0; % Define here which version of the smell structure was used - if anything has to change in the future downstream algorithms know what to do.
odorFields = fields(olfactometerOdors.sessionOdors(1));
smell.trial(1) = cell2struct(cell(length(odorFields),1),odorFields,1); % all fields for each used odor are written to the smell structure: odorName,iupacName,CASNumber,producingCompany,odorantPurity,state,odorantDilution,dilutedIn,concentrationAtPresentation,inflectionPointResponseCurve,slave,vial,mixture,sessionOdorNumber
smell.trial(1).trialNum = []; % Trial number in the current session
smell.trial(1).stimProtocol = []; % which stimulation protocol was used for this session
smell.trial(1).time = []; % time at time of start of a new trial (not the time of actual odor presentation)
smell.trial(1).notes = []; % Notes that are taken during the session will be saved here. Every trial the notes are extracted from the field and written into this field in form of a string.

% User defined times to instruct the olfactometer
smell.trial(1).odorConcentrationSettlingTime = [];
smell.trial(1).deadVolumePurgeTime = [];
smell.trial(1).odorPresentationTime = [];
smell.trial(1).waitAfterOdorPresentation = [];
smell.trial(1).cleanNoseTime = [];
smell.trial(1).sniffValveUsed = [];
smell.trial(1).humidAirValveUsed = [];
smell.trial(1).noseCleaningUsed = [];
smell.trial(1).flowRate = []; % Flow rate that reaches the animal in % of combined max flow of the two MFCs

% Actual times of opening and closing valves. Times from LASOM
% MFC info, odorGatingValves, emptyVialGatingValves, finalValve,
% suctionValve, sniffingValve, humidAirValve
smell.trial(1).odorGatingValves = []; % Two element vector [powerOnTime,powerOffTime]
smell.trial(1).emptyVialGatingValves = []; % Two element vector [powerOnTime,powerOffTime]
smell.trial(1).finalValve = []; % Two element vector [powerOnTime,powerOffTime]
smell.trial(1).suctionValve = []; % Two element vector [powerOnTime,powerOffTime]. Suction valve is normally open (NO) valve. powerOn therefore means closing of the valve, powerOff means opening of the valve.
smell.trial(1).sniffingValve = []; % Two to four element vector [powerOnTime,powerOffTime,powerOnTime,powerOffTime]
smell.trial(1).humidAirValveUsed = [];  % Two element vector [powerOnTime,powerOffTime]
smell.trial(1).MFCAir = []; % Mass Flow Controller output voltage. Ie the mass flow meter data, indicates the percentage of total flow
smell.trial(1).MFCNitrogen = []; % Mass Flow Controller output voltage. Ie the mass flow meter data, indicates the percentage of total flow

smell.trial(1).maxFlowRateMFCAir = []; % TO DO: Can LASOM figure this out? 
smell.trial(1).maxFlowRateMFCNitrogen = []; % TO DO:  Can LASOM figure this out? 


smell.trial(1).protocolSpecificInfo = []; % Here any information specific for the current protocol can be dumped
end
    
%% Update smell structure for every trial

if ~isempty(strmatch(instruction,'update'))
    % Find out how to extract information which function called buildSmell
    smell.trial(trialNum) = trialOdor;
    smell.trial(trialNum).trialNum = trialNum;
    smell.trial(trialNum).stimProtocol = stimProtocol;
    smell.trial(trialNum).time = clock; % This only gives an approximate time, as the odor might be presented to the animal multiple seconds later.
    smell.trial(trialNum).protocolSpecificInfo = protocolSpecificInfo;
    smell.trial(trialNum).notes = get(h.sessionNotes.notesFigureField,'String'); % Extract text in the notes field.
    
end

end