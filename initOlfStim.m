function initOlfStim(mode,olfStimUser)
% olfStim is the wrapper function calling the all necessary steps for odor
% stimulation. The action goes on in the called functions.
%
% mode - when left empty, olfStim is run in normal mode, interacting with
%           the olfactometer. 
%        optional one can provide 'test' or 'testing' as inputs, which will
%           start olfStim in the testing mode, without interaction with the
%           olfactometer. This is useful when playing around or developing
%           olfStim without an olfactometer connected.
%
% olfStimUser - optional. Supply your username, which will result in
%        olfStim looking for your personal configuration file in
%        olfStim/configuration/ Your username has to be suffixed to the
%        configuration file (eg olfStimConfiguration_lorenz).
% 
% To Do:
% - Check whether MFCs are connected to LASOM board.
% - Check how many slaves are connected. Depending on this build the
% odorSelectionGui.
% - Possibility to give digital triggers at arbitrary time points.
% - 
% - Change all paths from the unix way to an operating system independent
% way using filesep()
% - Make it possible to use more than 9 odor vials in the olfactometer.
% - Add the possibility to present multiple odors & multiple mixtures
% within one trial.
%
% lorenzpammer 2011/07
%%
% evalin('base','clear')

global smell % smell is the data structure containing all information relevant to the session
global olfStimTestMode

smell = [];

%% Set up relevant variables

if nargin > 0 && (strmatch(mode,'testing') || strmatch(mode,'test'))
    olfStimTestMode = true;
    disp('Entering test mode. No interactions with the olfactometer in this mode.')
else
    olfStimTestMode = false;
end

% If no user is provided
if nargin < 2
    olfStimUser=[];
end

%% Add olfStim folders to the matlab path

olfStimSetPath();

%% Check whether connection can be made to the olfactometer
if ~olfStimTestMode
    olfactometerAccess.checkConnection;
end

%% Decide which configuration file to use
olfStimChooseConfigFile(olfStimUser);

%% User has to define which odors are loaded into olfactometer
% start by opening the odorSelectionGui. User has to define which odorants
% are loaded in which concentration to which vial and which odors he want
% to use in the experiment.

olfactometerOdors = odorSelectionGui;

%% Set up the basic gui
setUpMainGui;

appdataManager('olfStimGui','set',olfactometerOdors);

%% Set up smell structure
buildSmell('setUp',olfactometerOdors);

%% Next start the gui for controlling 
protocolChooserSubGui;
% Extract selected protocol from appdata:
selectedProtocol=appdataManager('olfStimGui','get','selectedProtocol');

% %% Write data into the gui appdata
% % Write olfStimTestMode to the gui
% appdataManager('olfStimGui','set',olfStimTestMode);
%% Write some key variables to the gui
% List of I/O actions:
io = protocolUtilities.ioControl.ioConfiguration();
appdataManager('olfStimGui','set',io)

%% Execute selected protocol
functionHandle = str2func([selectedProtocol '.' selectedProtocol]); % make string of selected protocol to function handle
functionHandle(); % evaluate function handle, i.e. call function

end