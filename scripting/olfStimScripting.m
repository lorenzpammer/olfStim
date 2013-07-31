function olfStimScripting(currentProtocol,numberOfTrials,scientistName,animalName,interTrialInterval)
% olfStimScripting(currentProtocol,numberOfTrials,scientistName,animalName,interTrialInterval)
% This script sets up all necessary variables, paths, etc. to allow
% scripting olfStim without a gui. It has to be adapted for one's needs
% before executing. 
% 
% Go through the script and change the lines marked with '% < CHANGE!'
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
olfStimTestMode = true; % < CHANGE! Depending whether you want to use olfStim in test mode ('true') or control the hardware ('false')

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
% Load the file which is the olfactometerOdors structure
load(path)

clear path

%% Set up the basic smell structure
% This will create the smell structure in the correct way

buildSmell('setUp',olfactometerOdors);

%% Set up the olfactometerInstructions structure
% The olfactometerInstructions structure contains the instructions when to
% open and close valves, and flow rates of the mass flow controllers.

protocolUtilities.olfactometerSettings([],'setUpStructure');

%% Set up the sessionsInstructions structure
% The sessionInstructions structure contains information regarding the
% session and the I/O instructions.

[~,sessionInstructions]=protocolUtilities.sessionSettings([],'setUpStructure');

%% Populate the session settings with data
% The content for the sessionInstructions are provided as inputs to this
% function.
% In case they are not provided in the inputs, fall back on the defaults:

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
    % Set the identifier of the animal
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

% Define a  title for the file
title = [datestr(date,'yyyy.mm.dd') '_smell'];  % < CHANGE!
fn = [directoryName title '.mat'];

% Save the smell structure
save(fn,'smell')

clear directoryName title fn

%% Clean up everything

flush

end