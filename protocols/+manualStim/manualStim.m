function manualStim
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


% 3. End session button
h = quitSession(h); % endSession is a function in the protocolUtilities package. Sets up a functional button to end the session, save the smell structure, disconnect from LASOM etc.

% 2. Notes field
h = notes.setupGui(h); % setupGui is a function in the protocolUtilities.notes package. Sets up a new figure and panel with possibilities for note taking

% % 4. Start session button % not necessary for manualStim
% h = startSession(h,'manualSessionProgrammingStim.startSessionCallback');

% 5. Olfactometer Settings
h = olfactometerSettings(h,'setUp'); % sets up all controls the user has over the olfactometer (valve times, MFC flow rates)

% 6. Session Settings
% All controls a user has over session parameters (inter trial interval etc)
h = sessionSettingsPanel(h,0); % sessionSettingsPanel(h,guiEnlarge). 
usedSettingNames = {'scientist' 'animalName' 'I/O'};
h = sessionSettings(h,'setUp',usedSettingNames);
clear usedSettingNames;

% 7. Progress panel
h = progressPanel(h,'setUp'); % progressPanel is a function in the protocolUtilities package

% 8. Pause session button % not necessary for manualStim
% pauseSession; % pauseSession is a function in the protocolUtilities package. Sets up a functional button to pause the session

% 9. Put a log window on top of the gui
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