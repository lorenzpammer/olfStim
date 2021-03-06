function manualStim
%
% The manualStim stimulation protocol is simple and a good starting point
% to test the olfactometer but also for exploratory experiments. It allows
% setting the concentration of the odor presentation, control the total
% flow rate and the opening and closing times of all relevant valves. Every
% odor that has been defined in the odorSelectionGui will show up in form
% of a button, where vial numbers ascend from left to right. Beneath every
% odor button a concentration field is present. In the concentration field
% one can set the concentration at which the odor will be presented. If you
% have set the dilution of the odorant in the vial correctly in the Odorant
% Library or the odorSelectionGui, olfStim will automatically adjust the
% flow rates accordingly to reach the desired concentration. Pressing the
% odor button will start the trial. Executed trials are shown in the
% progress panel and during the trials users can enter notes which will be
% saved to the smell structure.
% 
% It can also serve as a template for creating your own simple protocol.
% 
% To do: 
% - Add possibility to change concentration for each trial.
% - At the beginning of session set MFC flow rate, and close MFCs at the
% end of session.
%
% lorenzpammer 2011/09

%% Set up needed variables

global smell
global trialNum

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Import function packages

% Import all functions of the current stimulation protocol
import manualStim.*
import protocolUtilities.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These variables have to be defined in every stimulation paradigm
trialNum = 0;
stimProtocol = 'manualStim';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up common gui components for all stimulation paradigms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The order of setting up the components is important, because the
% placement of the components is relative to other components.


% 1. End session button
h = quitSession(h); % endSession is a function in the protocolUtilities package. Sets up a functional button to end the session, save the smell structure, disconnect from LASOM etc.

% 2. Notes field
h = notes.setupGui(h); % setupGui is a function in the protocolUtilities.notes package. Sets up a new figure and panel with possibilities for note taking

% % 3. Start session button % not necessary for manualStim this is used in manualProgrammingStim for instance.
% h = startSession(h,'manualSessionProgrammingStim.startSessionCallback');

% 4. Olfactometer Settings
h = olfactometerSettings(h,'setUp'); % sets up all controls the user has over the olfactometer (valve times, MFC flow rates)

% 5. Session Settings
% All controls a user has over session parameters (inter trial interval etc)
h = sessionSettingsPanel(h,0); % sessionSettingsPanel(h,guiEnlarge). 
usedSettingNames = {'scientist' 'animalName' 'I/O'};
h = sessionSettings(h,'setUp',usedSettingNames);
clear usedSettingNames;

% 6. Progress panel
h = progressPanel(h,'setUp'); % progressPanel is a function in the protocolUtilities package

% 7. Pause session button % not necessary for manualStim
% pauseSession; % pauseSession is a function in the protocolUtilities package. Sets up a functional button to pause the session

% 8. Put a log window on top of the gui
h = logWindow.setup(h,h.guiHandle); % Add a log window on top of the gui.

% Add protocol specific handles"
h.protocolSpecificHandles = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up gui components for particular stimulation paradigm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set up push buttons for triggering odor presentation
% Set up the push buttons for triggering odorants and the edit fields for
% specifying the concentration of the odorant.
h = setUpOdorPushButtons(h,smell,stimProtocol);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mixtures fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if smell.olfactometerOdors.mixtures.used
    numberOfMixtures = length(find(mixtures));
    pushButtonWidth = (pushButtonArea(3) - ((numberOfMixtures-1)*spacing)) / numberOfMixtures; % Define pushbutton width depending on the number of mixtures
    h.staticText.mixture = uicontrol(h.guiHandle,'Style','text','String','Mixture','Position',textPosition);
    pushButtonPosition(3) = pushButtonWidth;
    odorCounter=0;
    j=3;
    for i = 1 : numberOfMixtures % go through every position of the olfactometer
        odorCounter = odorCounter+1;
        % Define name for mixture
        a = cell(1,length(smell.olfactometerOdors.mixtures.sessionOdors(odorCounter).odorName));
        for k = 1 : length(smell.olfactometerOdors.mixtures.sessionOdors(odorCounter).odorName)
            a{k} = smell.olfactometerOdors.mixtures.sessionOdors(odorCounter).odorName{k};
            a{k}(4:end)=[];
        end
        mixtureName = cell2mat(a);
        clear a;
        
        h.trigger(j,i) = uicontrol(h.guiHandle,'Style','pushbutton',...
            'String',mixtureName,...
            'Units','pixels','Position',pushButtonPosition,...
            'Callback',{@triggerOdorCallback,smell.olfactometerOdors.mixtures.sessionOdors(odorCounter),stimProtocol});
        
        pushButtonPosition(1) = pushButtonPosition(1)+pushButtonWidth+spacing; % redefine pushButtonPosition for next loop iteration
        
        clear mixtureName;
    end
end

clear pushButtonWidth; clear pushButtonHeight;clear i
clear position;clear pushButtonPosition; clear spacing; clear usedVials;
clear mixtures;clear activeSlaves;clear j

% uiwait(h.guiHandle)
%% Update h structure in the appdata
% Write the structure h containing all handles for the figure as appdata:
appdataManager('olfStimGui','set',h)

end


function closeGuiCallback
uiresume(h.guiHandle)
end