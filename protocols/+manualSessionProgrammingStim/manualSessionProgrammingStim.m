function manualSessionProgrammingStim
%
%
% TO DO:
% - when importing an old smell structure, clear all information which 
% lorenzpammer august 2012


%% Set up needed variables

global smell
global olfactometerOdors
global trialNum

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Import function packages

% Import all functions of the current stimulation protocol
import manualSessionPorgammingStim.*
import protocolUtilities.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These variables have to be defined in every stimulation paradigm
trialNum = 0;
stimProtocol = 'manualSessionProgrammingStim';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up common gui components for all stimulation paradigms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The order of setting up the components is important, because the
% placement of the components is relative to other components.

% Check how many odors are used in order to decide whether to enlarge the gui.

% 1. Quit session button
h = quitSession(h); % endSession is a function in the protocolUtilities package. Sets up a functional button to end the session, save the smell structure, disconnect from LASOM etc.

% 2. Notes field
h = notes.setupGui(h); % setupGui is a function in the protocolUtilities.notes package. Sets up a panel with possibilities for note taking

% 3. End session button
h = endSession(h,'manualSessionProgrammingStim.endSessionCallback');

% 4. Start session button
h = startSession(h,'manualSessionProgrammingStim.startSessionCallback');

% 5. Save session instructions button
h = saveSequenceOfTrialsInstructions(h,'protocolUtilities.saveSequenceOfTrialsInstructionsCallback');

% 6. Load session instructions button
h = loadSequenceOfTrialsInstructions(h,'protocolUtilities.loadSequenceOfTrialsInstructionsCallback');

% 5. Olfactometer Settings
h = olfactometerSettings(h,'setUp'); % sets up all controls the user has over the olfactometer (valve times, MFC flow rates)

% 6. Session Settings
% All controls a user has over session parameters (inter trial interval etc)
h = sessionSettingsPanel(h,0); % sessionSettingsPanel(h,guiEnlarge). 
usedSettingNames = {'scientist' 'animalName' 'interTrialInterval' 'I/O'};
h = sessionSettings(h,'setUp',usedSettingNames);
clear usedSettingNames;

% 7. Progress panel
h = progressPanel(h,'setUp'); % progressPanel is a function in the protocolUtilities package

% 8. Pause session button
% h = pauseSession(h,'setUp','manualSessionProgrammingStim.pauseSessionCallback'); % pauseSession is a function in the protocolUtilities package. Sets up a functional button to pause the session

% 9. Put a log window on top of the gui
h = logWindow.setup(h,h.guiHandle); % Add a log window on top of the gui.

% 9. Clear seq button
h = clearSessionDataButton(h,'protocolUtilities.clearSessionDataCallback');



% Add protocol specific handles"
h.protocolSpecificHandles = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up gui components for particular stimulation paradigm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2. Buttons for triggering odor presentation
% Define positions:
figurePosition = get(h.guiHandle,'Position');
position = get(h.progress.panel,'Position');
protocolChooserPosition = get(h.panelProtocolChooser,'Position');
spacing = 3;
pushButtonArea(1) =  protocolChooserPosition(1)+protocolChooserPosition(3) + 40; % X position to the right of protocol chooser panel
pushButtonArea(3) = figurePosition(3)-pushButtonArea(1)-3; % Width of the area for the buttons
pushButtonWidth = (pushButtonArea(3) - (8*spacing)) / 9;
pushButtonHeight = 25;
pushButtonArea(2)= position(2) - pushButtonHeight - 3;
pushButtonArea(4)= pushButtonHeight;

%
%
% h.protocolSpecificHandles.triggerOdorPanel = uipanel('Parent',h.guiHandle,'Title','Protocol Controls',...
%         'FontSize',12,'TitlePosition','centertop',...
%         'Units','pixels','Position',panelPosition); % 'Position',[x y width height]


pushButtonPosition = [pushButtonArea(1) pushButtonArea(2) pushButtonWidth pushButtonHeight];
textPosition = [pushButtonArea(1)-40, pushButtonPosition(2)+5, 35, 15];

% Find which slaves are used
mixtures = [olfactometerOdors.sessionOdors.mixture]; % Find which session odors are mixtures
activeSlaves = {olfactometerOdors.sessionOdors.slave}; % Find for every session odor which slaves are used
activeSlaves = cell2mat(activeSlaves(~mixtures)); % Throw away the entries for the mixtures
activeSlaves = unique(activeSlaves); % Find all unique slaves which are used

% Set up gui controls for push buttons
for j = 1 : length(activeSlaves)
    odorCounter=0;
    % create the text saying which slave:
    h.staticText.slave(j) = uicontrol(h.guiHandle,'Style','text','String',['Slave ' num2str(j)],'Position',textPosition);
    usedVials = [olfactometerOdors.slave(j).sessionOdors(:).vial];
    for i = 1 : 9 % go through every position of the olfactometer
        
        if sum(ismember(usedVials,i))>0.1 % checks whether there is an odor vial in the current (i) position of the olfactometer
            odorCounter = odorCounter+1;
            h.protocolSpecificHandles.trigger(j,i) = uicontrol(h.guiHandle,'Style','pushbutton',...
                'String',olfactometerOdors.slave(j).sessionOdors(odorCounter).odorName,...
                'Units','pixels','Position',pushButtonPosition,...
                'Callback',{@triggerOdorCallback,olfactometerOdors.slave(j).sessionOdors(odorCounter),stimProtocol});
            
        else
            h.protocolSpecificHandles.trigger(j,i) = uicontrol(h.guiHandle,'Style','pushbutton',...
                'String','',...
                'Units','pixels','Position',pushButtonPosition,'Callback',@triggerEmptyOdorCallback);
            
        end
        
        pushButtonPosition(1) = pushButtonPosition(1)+pushButtonWidth+spacing; % redefine pushButtonPosition for next loop iteration
        
        
    end
    
    % Redefine position for concentration settings.
    pushButtonPosition(1) = pushButtonArea(1);
    pushButtonPosition(2) = pushButtonPosition(2) - pushButtonPosition(4) - 3;
    textPosition(2) = pushButtonPosition(2) + 5;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Concentration edit fields
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    odorCounter=0;
    % create the text declaring the row of concentration edit fields
    h.protocolSpecificHandles.staticText.concentration(j) = uicontrol(h.guiHandle,'Style','text','String','Concentrations','Position',textPosition);
    usedVials = [olfactometerOdors.slave(j).sessionOdors(:).vial];
    for i = 1 : 9 % go through every vial of the olfactometer
        
        if sum(ismember(usedVials,i))>0.1 % checks whether there is an odor vial in the current (i) position of the olfactometer
            odorCounter = odorCounter+1;
            % Calculate the maximum possible concentration given the MFC
            % flow rates, the user defined total flow and the dilution of
            % the odorant in the vial.
            settingNames = get(h.olfactometerSettings.text,'Tag');
            settingIndex = strcmp('mfcTotalFlow',settingNames);
            totalFlow = str2num(get(h.olfactometerSettings.edit(settingIndex),'String'));
            maximumPossibleConcentration = smell.olfactometerSettings.slave(j).maxFlowRateMfcNitrogen / totalFlow * smell.olfactometerOdors.slave(j).sessionOdors(odorCounter).odorantDilution;
            % Set up the fields, and append the gui handle structure
            h.protocolSpecificHandles.concentration(j,i) = uicontrol(h.guiHandle,'Style','edit',...
                'String',maximumPossibleConcentration,...
                'Units','pixels','Position',pushButtonPosition,'Callback',{@concentrationEditCallback,j,i});
        end
        
        pushButtonPosition(1) = pushButtonPosition(1)+pushButtonWidth+spacing; % redefine pushButtonPosition for next loop iteration
        
    end
    
    % Redefine pushButtonPosition for next slave
    pushButtonPosition(1) = pushButtonArea(1);
    pushButtonPosition(2) = pushButtonPosition(2) - pushButtonPosition(4) - 3;
    textPosition(2) = pushButtonPosition(2) + 5;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mixtures fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if olfactometerOdors.mixtures.used
    numberOfMixtures = length(find(mixtures));
    pushButtonWidth = (pushButtonArea(3) - ((numberOfMixtures-1)*spacing)) / numberOfMixtures; % Define pushbutton width depending on the number of mixtures
    h.staticText.mixture = uicontrol(h.guiHandle,'Style','text','String','Mixture','Position',textPosition);
    pushButtonPosition(3) = pushButtonWidth;
    odorCounter=0;
    j=3;
    for i = 1 : numberOfMixtures % go through every position of the olfactometer
        odorCounter = odorCounter+1;
        % Define name for mixture
        a = cell(1,length(olfactometerOdors.mixtures.sessionOdors(odorCounter).odorName));
        for k = 1 : length(olfactometerOdors.mixtures.sessionOdors(odorCounter).odorName)
            a{k} = olfactometerOdors.mixtures.sessionOdors(odorCounter).odorName{k};
            a{k}(4:end)=[];
        end
        mixtureName = cell2mat(a);
        clear a;
        
        h.trigger(j,i) = uicontrol(h.guiHandle,'Style','pushbutton',...
            'String',mixtureName,...
            'Units','pixels','Position',pushButtonPosition,...
            'Callback',{@triggerOdorCallback,olfactometerOdors.mixtures.sessionOdors(odorCounter),stimProtocol});
        
        pushButtonPosition(1) = pushButtonPosition(1)+pushButtonWidth+spacing; % redefine pushButtonPosition for next loop iteration
        
        clear mixtureName;
    end
end

clear pushButtonWidth; clear pushButtonHeight;clear i
clear position;clear pushButtonPosition; clear spacing; clear usedVials;
clear mixtures;clear activeSlaves;clear j


%% Update h structure in the appdata
% Write the structure h containing all handles for the figure as appdata:
appdataManager('olfStimGui','set',h)


end


function triggerOdorCallback(~,~,trialOdor,stimProtocol)
% This trial triggering function should be used in all stimulation
% protocols.

global trialNum
global smell

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Import function packages

% Import all utility functions
import protocolUtilities.*

%% First save the current smell file to the temp folder in case anything happens.
callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function
olfStimPath = which(callingFunctionName);
olfStimPath(length(olfStimPath)-length(callingFunctionName):length(olfStimPath))=[];
olfStimPath=[olfStimPath filesep 'User Data' filesep 'temp' filesep];
clear callingFunctionName

defaultTitle = [datestr(date,'yyyy.mm.dd') '_smell_temp'];
extendedPath = [olfStimPath defaultTitle '.mat'];
save(extendedPath,'smell')
clear olfStimPath defaultTitle

%% Now extract all the information for the trial, and write it into smell

trialNum = round(trialNum+1); % every time a odor is triggered a new trial is counted

% 1. extract the current olfactometerSettings. 
%   This will update the global olfactometerSettings structure to the
%   current instructions from the gui.
protocolUtilities.olfactometerSettings(h,'get');

% 2. extract the concentration from gui and update trialOdor
trialOdor.concentrationAtPresentation = str2num(get(h.protocolSpecificHandles.concentration(trialOdor.slave,trialOdor.vial),'string'));

% 3. extract the current sessionSettings & write the updated version in the
% appdata of the gui
sessionSettings(h,'get');

% 4. update the smell structure
 buildSmell('update',trialOdor,trialNum,stimProtocol); % update smell structure

% 5. update the progress panel on the gui
 protocolUtilities.progressPanel(h,'update',trialOdor,trialNum,'Color',[0.5 0.5 0.5]); % 

end


function triggerEmptyOdorCallback(~,~)
warning('No odor present in this position of the olfactometer. If you want to use this vial restart olfStim and change the information in the odorSelectionGui.')
end



function closeGuiCallback
uiresume(h.guiHandle)
end