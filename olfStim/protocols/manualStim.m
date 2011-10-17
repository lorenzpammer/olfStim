function manualStim

% lorenzpammer 2011/09

global smell
global olfactometerOdors
global h
global trialNum


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define some variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These variables have to be defined in every stimulation paradigm
trialNum = 0;
stimProtocol = 'manualStim';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up common gui components for all stimulation paradigms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Progress panel
progressPanel('setUp'); % progressPanel is a function private to the stimulation protocols

% 2. Button for closing the gui
closeGui; %

% 3. Notes field
sessionNotes('setUp'); % sessionNotes is a function private to the stimulation protocols. Sets up a panel with possibilities for note taking

% 4. End session button
endSession; % endSession is a function private to the stimulation protocols. Sets up a functional button to end the session, save the smell structure, disconnect from LASOM etc.

% % 5. Pause session button
% pauseSession; % pauseSession is a function private to the stimulation protocols. Sets up a functional button to pause the session

% 6. OlfactometerInstructions
olfactometerInstructions('setUp');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up gui components for particular stimulation paradigm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set up push buttons for triggering odor presentation

% 2. Buttons for triggering odor presentation
% Define positions
figurePosition = get(h.guiHandle,'Position');
position = get(h.progressPanel,'Position');
protocolPosition = get(h.panelProtocol,'Position');
spacing = 3;
pushButtonArea(1) =  protocolPosition(1)+protocolPosition(3) + 40; % X position to the right of protocol panel
pushButtonArea(3) = figurePosition(3)-pushButtonArea(1)-3; % Width of the area for the buttons 
pushButtonWidth = (pushButtonArea(3) - (8*spacing)) / 9;
pushButtonHeight = 25;
pushButtonArea(2)= position(2) - pushButtonHeight - 3;
pushButtonArea(4)= pushButtonHeight;

pushButtonPosition = [pushButtonArea(1) pushButtonArea(2) pushButtonWidth pushButtonHeight];
textPosition = [pushButtonArea(1)-40, pushButtonPosition(2)+5, 35, 15];

% Find which slaves are used
mixtures = [olfactometerOdors.sessionOdors.mixture]; % Find which session odors are mixtures
activeSlaves = {olfactometerOdors.sessionOdors.slave}; % Find for every session odor which slaves are used
activeSlaves = cell2mat(activeSlaves(~mixtures)); % Throw away the entries for the mixtures
activeSlaves = unique(activeSlaves); % Find all unique slaves which are used

% Set up gui controls
for j = 1 : length(activeSlaves)
    odorCounter=0;
    h.staticText.slave(j) = uicontrol(h.guiHandle,'Style','text','String',['Slave ' num2str(j)],'Position',textPosition);
    usedVials = [olfactometerOdors.slave(j).sessionOdors(:).vial];
    for i = 1 : 9 % go through every position of the olfactometer
        
        if sum(ismember(usedVials,i))>0.1 % checks whether there is an odor vial in the current (i) position of the olfactometer
            odorCounter = odorCounter+1;
            h.trigger(j,i) = uicontrol(h.guiHandle,'Style','pushbutton',...
                'String',olfactometerOdors.slave(j).sessionOdors(odorCounter).odorName,...
                'Units','pixels','Position',pushButtonPosition,...
                'Callback',{@triggerOdorCallback,olfactometerOdors.slave(j).sessionOdors(odorCounter),stimProtocol});
            
        else
            h.trigger(j,i) = uicontrol(h.guiHandle,'Style','pushbutton',...
                'String','',...
                'Units','pixels','Position',pushButtonPosition,'Callback',@triggerEmptyOdorCallback);
            
        end
        
        pushButtonPosition(1) = pushButtonPosition(1)+pushButtonWidth+spacing; % redefine pushButtonPosition for next loop iteration
        
        
    end
    
    % Redefine pushButtonPosition for next slave
    pushButtonPosition(1) = pushButtonArea(1);
    pushButtonPosition(2) = pushButtonPosition(2) - pushButtonPosition(4) - 3;
    textPosition(2) = pushButtonPosition(2) + 5;
end

% Set up controls for mixtures
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

% uiwait




end


function triggerOdorCallback(source,eventdata,trialOdor,stimProtocol)
global trialNum

trialNum = round(trialNum+1); % every time a odor is triggered a new trial is counted
smell = buildSmell('update',trialOdor,trialNum,stimProtocol); % update smell structure
progressPanel('update',trialOdor,trialNum)

end

function triggerEmptyOdorCallback(source,eventdata)
    warning('No odor present in this position of the olfactometer. If you want to use this vial restart olfStim and change the information in the odorSelectionGui.')
end

function closeGuiCallback
uiresume
end