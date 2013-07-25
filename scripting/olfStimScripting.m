function olfStimScripting(currentProtocol,numberOfTrials,scientistName,animalName,interTrialInterval)
% olfStimScripting(currentProtocol,numberOfTrials,scientistName,animalName,interTrialInterval)
% This script sets up all necessary variables, paths, etc. to allow
% scripting olfStim without a gui. It has be edited before executing. 
%
% lorenzpammer 2013/05

%% Set up globals

global olfStimScriptMode
global smell
global olfStimTestMode
global olfactometerInstructions

%% Set variables & paths

olfStimSetPath(); % Set the paths to all necessary functions
import scriptingProtocols.* % Import the scripting protocols

olfStimScriptMode = true;
olfStimTestMode = true;

%% Load odorant configuration of the olfactometer
% In order to define which odorants are present in which dilution in which
% vial of the olfactometer, we have to load the olfactometerOdors
% configuration file.
%
% To create an olfactometerOdors file, use the gui. Execute 
% >> odorSelectionGui
% and save your configuration.

% Set the path of the file:
path = ('/Users/lpammer/Documents/Wissenschaft/Dissertation/Code/olfStim/User Data/olfactometerOdors/defaultOdors.mat'); % < CHANGE!
% Load the file
load(path)

clear path

%% Set up the basic smell structure
% This will create the smell structure, guaranteeing the right fields, etc.

buildSmell('setUp',olfactometerOdors);

%% Set up the olfactometerInstructions structure
% 

protocolUtilities.olfactometerSettings([],'setUpStructure');

%% Set up the sessionsInstructions structure

[~,sessionInstructions]=protocolUtilities.sessionSettings([],'setUpStructure');

%% Set up session settings
%In case these were not provided in the inputs to the function, fall back on the defaults

if nargin < 3
    % The name of the scientist performing the experiment
    [~,sessionInstructions]=protocolUtilities.sessionSettings([],'updateStructure',[],sessionInstructions,...
        'scientist',{'value' 'LP'}); % < CHANGE!
else
    % The name of the scientist performing the experiment
    [~,sessionInstructions]=protocolUtilities.sessionSettings([],'updateStructure',[],sessionInstructions,...
        'scientist',{'value' scientistName});
end
if nargin < 4
    % Set the scientist's name
    [~,sessionInstructions]=protocolUtilities.sessionSettings([],'updateStructure',[],sessionInstructions,...
        'animalName',{'value' 'A01'}); % < CHANGE!
else
    % Set the scientist's name
    [~,sessionInstructions]=protocolUtilities.sessionSettings([],'updateStructure',[],sessionInstructions,...
        'animalName',{'value' animalName});
end

if nargin < 5
    % Set the intertrial interval
    [~,sessionInstructions]=protocolUtilities.sessionSettings([],'updateStructure',[],sessionInstructions,...
        'interTrialInterval', {'value' 5},{'used' 1}); % < CHANGE!
else
    % Set the intertrial interval
    [~,sessionInstructions]=protocolUtilities.sessionSettings([],'updateStructure',[],sessionInstructions,...
        'interTrialInterval', {'value' interTrialInterval},{'used' 1});
end


%% Now transfer control to the scripting protocol

% Create function handle to the protocol
fh = str2func([currentProtocol '.' currentProtocol]); % use the input to the function
% fh = str2func('randomOdorPresentation'); % or just define the name of the scripting protocol  < CHANGE!

% Execute the scripting protocol
fh(numberOfTrials,sessionInstructions);

clear fh




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% After the end of the stimulation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Save the resulting smell structure

% Define the path to the directory where you want to save smell to
directoryName = protocolUtilities.getOlfStimRootDirectory;
directoryName = [directoryName filesep 'User Data' fileSep 'data' filesep];  % < CHANGE!

% Give a  title for the file
title = [datestr(date,'yyyy.mm.dd') '_smell'];  % < CHANGE!
fn = [directoryName title '.mat'];

% Save the smell structure
save(fn,'smell')

clear directoryName title fn

%% Clean up everything

flush

end