function olfactometerInstructions = olfactometerSettings(instruction,additionalSettings,panelPosition)
% olfactometerInstructions(instruction)
% This function is private to the protocols and adds a panel to the bottom
% of the gui where the settings specifying the olfactometer behavior are
% defined. The code will add x settings options to the gui, which are
% described below. 
% instruction is either 'setUp' - when building the gui at the beginning of
% a session this option will add the panel and all the user defineable
% settings to the gui. 
% or 'get' - which is called at the beginning of every trial before
% commands are sent to the LASOM. The instruction 'get' will cause the
% function to extract all values from the user defineable settings and give
% them as a output in the olfactometerInstructions structure.
%
% olfactometerInstructions(instruction, additionalSettings)
% If you want to allow the user to define further settings, you have to
% specify a cell array of strings with the name of each new settings per
% cell. Then add a new subfunction which can set 'setUp' or extract 'get' 
% 
% olfactometerInstructions(instruction, additionalSettings, panelPosition)
% If you do not want to use the default position for the panel - at the
% bottom of the gui - you can specify a position [x y width height] where
% the panel should be placed.
%
% 
% Default settings:
%
% MFC total flow - default 1 liter/min
% Odor concentration settling time - default 3s
% Dead volume purge time - default 0.25 s
% open sniffing valve time - default 0.25 s
% odor presentation time - default 1s
% 
% 
%
%

% lorenzpammer 2011/09

global h
global smell

%% Check inputs

if nargin < 1
    error('You have to give instructions, whether to set up the panel or get information.')
end

if nargin < 2
    additionalSettings = []; % Set additional settings to empty. Only default settings will be set up and extracted.
    
    if strncmp(instruction, 'setUp',5) || strncmp(instruction,'get',3)
        % Fine
    else 
        error('First input to the function must be a string "setUp" or "get". See the help.')
    end
end

if nargin < 3
    % if additional settings are specified but not correctly, give errors.
    if nargin > 1 && ~iscell(additionalSettings)
        error('Second input to function, "additionalSettings" must be a cell array of strings.')     
    end
end



%% Set up panel and all settings

if strncmp(instruction,'setUp',5)
    %% Define panelPosition if it wasn't defined in inputs
    if nargin < 3
        sessionNotesPanel = get(h.sessionNotes.panel,'Position');
        figurePosition = get(h.guiHandle,'Position');
        quitSessionPosition = get(h.quitSession,'Position');
        spacing = 3;
        panelPosition(1) = sessionNotesPanel(1) + sessionNotesPanel(3) + spacing;
        panelPosition(2) = spacing;
        panelPosition(3) = figurePosition(3) - sessionNotesPanel(1) - sessionNotesPanel(3) - quitSessionPosition(3) - spacing*3;
        panelPosition(4) = sessionNotesPanel(2) + sessionNotesPanel(4);
    end
    clear sessionNotesPanel;clear figurePosition;clear quitSessionPosition; 
    

    h.olfactometerSettings.panel = uipanel('Parent',h.guiHandle,'Title','Olfactometer Settings',...
        'FontSize',12,'TitlePosition','centertop',...
        'Units','pixels','Position',panelPosition); % 'Position',[x y width height]

    %% Define positions for the controls: 
    % Total of 12 possible positions in the panel: 2x6
    
    positions = cell(2,7); % One cell for each of the 12 positions in the panel
    width = panelPosition(3) / 7;
    height = (panelPosition(4)-15) / 2; % -10 because the text of the panel is included in the height
    
    counter = 0;
    for i = 1 : 2 : numel(positions)
        counter = counter+1;
       positions{i} = [panelPosition(1) + (counter-1)*width,...
           panelPosition(2) + height,...
           width, height];
    end
    counter = 0;
    for i = 2 : 2 : numel(positions)
        counter = counter+1;
       positions{i} = [panelPosition(1) + (counter-1)*width,...
           panelPosition(2),...
           width, height];
    end
    clear counter; clear width; clear height

    
    %% Set up olfactometerInstructions structure
    olfactometerInstructions = struct('name',{'lsq #' 'mfcTotalFlow' 'powerGatingValve' 'powerFinalValve' 'closeSuctionValve',...
        'openSniffingValve' 'closeSniffingValve' 'openSuctionValve' 'unpowerFinalValve',...
        'unpowerGatingValve' 'purge' 'cleanNose'},...
        'value',cell(1,12),...
        'unit',{ '' 'l/m' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's'},...
        'userSettingNumber',[],...
        'used',1);
        
        % Default: closeSniffingValveTime, openSuctionValveTime,
        % unpowerFinalValveTime, unpowerGatingValveTime, purgeTime are all
        % at the same time after "odorPresentationTime"
    
        %% Define the size of the edit field ('edit') and its descriptor ('text')
    textHeight = 30; textWidth = 70;
    editHeight = 25; editWidth = 50;
        
    %% Graphical depiction of a sequence of events in a trial
    
    % First create a button which allows one to open and close the
    % graphical depiction of the sequence of events, but also checks
    % whether the sequence makes sense (eg when one valve is opened it must
    % be closed as well)
    position = [panelPosition(1)+panelPosition(3)-53 panelPosition(2)+spacing 50 25];
    h.olfactometerSettings.trialSeqButton = uicontrol('Position',position,'String','Trial Seq',...
        'Callback',@trialSeqButton);
    
    position = get(h.guiHandle,'Position');
    position = [(position(1:3) - [0 160 0]) 130]
    h.olfactometerSettings.trialSeqFig = figure('Position',position,'menubar','none','CloseRequestFcn',@close_trialSeqFig,...
        'Visible','off');
    
    h.olfactometerSettings.trialSeqGraph = axes('Units','Pixels');
    position(1) = 5; % x
    position(2) = 35; % y
    position(3) = position(3)-10; % 
    position(4) = position(4)-40;
    set(h.olfactometerSettings.trialSeqGraph,'Ytick',[],'Position',position)
    xlabel(h.olfactometerSettings.trialSeqGraph,'Seconds');
    ylim([0 10])
    
    position = [position(3)-35 5 33 20];
    h.olfactometerSettings.help = uicontrol('Position',position,'String','Help',...
        'Callback',@helpButton_Callback);
    
    %% Define the options which can be set to control the olfactometer
    
    
%     numberOfUserDefinedSettings = 7 + length(additionalSettings); % default settings + number of additional settings required for the current protocol
    
    % Which lsq file is used for the paradigm
    settingNumber = 1;
    userSettingNumber = 1;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 1;
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name],...
        'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);

    
    % total flow at presentation of both MFCs combined in l/min 
    settingNumber = 2;
    userSettingNumber = 2;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 1.0;
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],...
        'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);

    
    % Time of opening odor gating valves & closing empty vial gating valves
    settingNumber = 3;
    userSettingNumber = 3;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 0; % Default power the gating valves at t=0s
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],...
        'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);
    
    
    
    
    % Odor concentration settling time (finalValve) in seconds
    % Defines the timepoint at which final valve is powered - time odor
    % concentration can settle in the line between the vial and the final
    % valve.
    settingNumber = 4;
    userSettingNumber = 4;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 3.0; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);
    
    position = [position(1)+position(3)+spacing position(2)+10 15 15];
    h.olfactometerSettings.check(userSettingNumber) = uicontrol('Parent',h.guiHandle,... % check to define whether the final valve should be used
        'Style','checkbox','String','','Value',olfactometerInstructions(settingNumber).used,'Position', position);
    
    
    % Timepoint closing suction valve in seconds
    % Dead volume purge time. Dead volume between final valve and 
    settingNumber = 5;
    userSettingNumber = 5;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 3.25; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);
    
    position = [position(1)+position(3)+spacing position(2)+10 15 15];
    h.olfactometerSettings.check(userSettingNumber) = uicontrol('Parent',h.guiHandle,...% check to define whether the suction valve should be used
        'Style','checkbox','String','','Value',olfactometerInstructions(settingNumber).used,'Position', position);
    
    
    % Timepoint opening sniffing valve + optional sniffing valve
    settingNumber = 6;
    userSettingNumber = 6;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 3.5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);
    
    position = [position(1)+position(3)+spacing position(2)+10 15 15];
    h.olfactometerSettings.check(userSettingNumber) = uicontrol('Parent',h.guiHandle,... % check to define whether the sniffing valve should be used
        'Style','checkbox','String','','Value',olfactometerInstructions(settingNumber).used,'Position', position);
    
    
    
    % Odor Presentation Time ends:
    
        % Close sniffing valve
    settingNumber = 7;
    userSettingNumber = 7;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);
   
    
        % Open suction valve
    settingNumber = 8;
    userSettingNumber = 8;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);
    
    
        % Unpower final valve
    settingNumber = 9;
    userSettingNumber = 9;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);
    
    
        % Unpower gating valve
    settingNumber = 10;
    userSettingNumber = 10;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);
        
    
        % Start purge
    settingNumber = 11;
    userSettingNumber = 11;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);
    
    
    % Clean nose
    settingNumber = 12;
    userSettingNumber = 12;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 10; % in seconds   
    
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);
    
    position = [position(1)+position(3)+spacing position(2)+10 15 15];
    h.olfactometerSettings.check(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','checkbox','String','','Value',olfactometerInstructions(settingNumber).used,'Position', position);

    
    %%
    % If additional settings are necessary for the particular protocol this
    if ~isempty(additionalSettings)
        for i = 1 : length(additionalSettings)
            fh = str2func(additionalSettings(i)); % make string of selected additional Setting to function handle
            fh(instruction,olfactometerInstructions); % evaluate function handle, i.e. call function
        end
    end
end

%% 

if strncmp(instruction,'get',3)
    % Get the information in the Gui prior to sending the commands to the
    % olfactometer.
   disp('To Do: code extract information from gui about olfactometerInstructions') 
   get(h.olfactometerSettings.edit,'string')
end
end


% 
function trialSeqButton(~,~)

if strncmp(get(h.olfactometerSettings.trialSeqFig,'Visible'),'on',2)
    set(h.olfactometerSettings.trialSeqFig,'Visible','off');
elseif strncmp(get(h.olfactometerSettings.trialSeqFig,'Visible'),'off',3)
    set(h.olfactometerSettings.trialSeqFig,'Visible','on');
    
    % Add here checking of the parameters
    
end

end

function close_trialSeqFig(~,~)
    set(h.olfactometerSettings.trialSeqFig,'Visible','off'); 
end

function helpButton_Callback(~,~)
callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function in the highest
path = which(callingFunctionName);
path(length(path)-length(callingFunctionName):length(path))=[];
path=[path '/Documentation/Olfactometer_Schematic.tif'];
helpImage = imread(path);
h.olfactometerSettings.helpSchematicWindow = figure;%('CloseRequestFcn',@close_helpSchematicWindow)
imshow(helpImage,'Border','tight')
clear callingFunctionName; clear path;
end
% 

function close_helpSchematicWindow(~,~)
% set(h.olfactometerSettings.helpSchematicWindow,'Visible','off'
% close(gcf)
end

% Add functions to add additional settings