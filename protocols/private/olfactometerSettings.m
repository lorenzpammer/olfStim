function olfactometerSettings(instruction,additionalSettings,panelPosition)
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
% Resolve: 
% - the variable olfactometerInstructions is 
% - 
%

% lorenzpammer 2011/09

global h
% global smell
global olfactometerInstructions

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
    olfactometerInstructions = struct('name',{'mfcTotalFlow' 'powerGatingValve' 'powerFinalValve' 'closeSuctionValve',...
        'openSniffingValve' 'closeSniffingValve' 'openSuctionValve' 'unpowerFinalValve',...
        'unpowerGatingValve' 'purge' 'cleanNose'},...
        'value',cell(1,11),...
        'unit',{ 'l/m' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's'},...
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
    h.olfactometerSettings.trialSeqButton = uicontrol(h.guiHandle,'Position',position,'String','Trial Seq',...
        'Callback',@trialSeqButton); % give input to function handle: 'Callback',{@trialSeqButton, olfactometerInstructions}
   
    position = get(h.guiHandle,'Position');
    position = [(position(1:3) - [0 160 0]) 130];
    h.olfactometerSettings.trialSeqFig = figure('Position',position,'menubar','none',...
        'Visible','off','Name','Sequence of events in a trial'); %'CloseRequestFcn',@close_trialSeqFig
    
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
%     
%     % Which lsq file is used for the paradigm
%     settingNumber = 1;
%     userSettingNumber = 1;
%     olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
%     olfactometerInstructions(settingNumber).value = 1;
%     
%     position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
%     h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
%         'Style','text','String',[olfactometerInstructions(settingNumber).name],...
%         'Position', position);
%     
%     position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
%     h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
%         'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position);

    
    % total flow at presentation of both MFCs combined in l/min 
    settingNumber = 1;
    userSettingNumber = 1;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 1.0;
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],...
        'Position', position,'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
        'Tag',olfactometerInstructions(settingNumber).name);

    
    % Time of opening odor gating valves & closing empty vial gating valves
    settingNumber = 2;
    userSettingNumber = 2;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 0; % Default power the gating valves at t=0s
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],...
        'Position', position,'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
        'Tag',olfactometerInstructions(settingNumber).name);
    
    
    
    
    % Odor concentration settling time (finalValve) in seconds
    % Defines the timepoint at which final valve is powered - time odor
    % concentration can settle in the line between the vial and the final
    % valve.
    settingNumber = 3;
    userSettingNumber = 3;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 3.0; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position,...
        'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
        'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [position(1)+position(3)+spacing position(2)+10 15 15];
    h.olfactometerSettings.check(userSettingNumber) = uicontrol('Parent',h.guiHandle,... % check to define whether the final valve should be used
        'Style','checkbox','String','','Value',olfactometerInstructions(settingNumber).used,'Position', position,...
        'Tag',olfactometerInstructions(settingNumber).name);
    
    
    % Timepoint closing suction valve in seconds
    % Dead volume purge time. Dead volume between final valve and 
    settingNumber = 4;
    userSettingNumber = 4;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 3.25; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position,...
        'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
        'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [position(1)+position(3)+spacing position(2)+10 15 15];
    h.olfactometerSettings.check(userSettingNumber) = uicontrol('Parent',h.guiHandle,...% check to define whether the suction valve should be used
        'Style','checkbox','String','','Value',olfactometerInstructions(settingNumber).used,'Position', position,...
        'Tag',olfactometerInstructions(settingNumber).name);
    
    
    % Timepoint opening sniffing valve + optional sniffing valve
    settingNumber = 5;
    userSettingNumber = 5;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 3.5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [position(1)+position(3)+spacing position(2)+10 15 15];
    h.olfactometerSettings.check(userSettingNumber) = uicontrol('Parent',h.guiHandle,... % check to define whether the sniffing valve should be used
        'Style','checkbox','String','','Value',olfactometerInstructions(settingNumber).used,'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    
    
    % Odor Presentation Time ends:
    
        % Close sniffing valve
    settingNumber = 6;
    userSettingNumber = 6;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
   
    
        % Open suction valve
    settingNumber = 7;
    userSettingNumber = 7;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    
        % Unpower final valve
    settingNumber = 8;
    userSettingNumber = 8;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    
        % Unpower gating valve
    settingNumber = 9;
    userSettingNumber = 9;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
        
    
        % Start purge
    settingNumber = 10;
    userSettingNumber = 10;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 5; % in seconds   
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    
    % Clean nose
    settingNumber = 11;
    userSettingNumber = 11;
    olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
    olfactometerInstructions(settingNumber).value = 10; % in seconds   
    
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
    h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
    h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);
    
    position = [position(1)+position(3)+spacing position(2)+10 15 15];
    h.olfactometerSettings.check(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
        'Style','checkbox','String','','Value',olfactometerInstructions(settingNumber).used,'Position', position,...
    'Tag',olfactometerInstructions(settingNumber).name);


% Color the describing text
names = get(h.olfactometerSettings.edit,'Tag');

i = 1;
index1(i) = strmatch('powerGatingValve',names);
index2(i) = strmatch('unpowerGatingValve',names);

i = 2;
index1(i) = strmatch('powerFinalValve',names);
index2(i) = strmatch('unpowerFinalValve',names);

i = 3;
index1(i) = strmatch('closeSuctionValve',names);
index2(i) = strmatch('openSuctionValve',names);

i = 4;
index1(i) = strmatch('openSniffingValve',names);
index2(i) = strmatch('closeSniffingValve',names);

i = 5;
index1(i) = strmatch('purge',names);
index2(i) = 0;

i = 6; 
index1(i) = strmatch('cleanNose',names);
index2(i) = 0;


color = hsv(length(index1));

for i = 1 : length(color(:,1))
    set(h.olfactometerSettings.edit(index1(i)),'BackgroundColor',color(i,:));
    if index2(i) ~= 0
        set(h.olfactometerSettings.edit(index2(i)),'BackgroundColor',color(i,:));
    end
end

clear names; clear index1; clear index2; clear color
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


%% SUBFUNCTIONS


function olfactometerInstructions = extractOlfactometerSettings(olfactometerInstructions)

% global olfactometerInstructions
global h

% Extract field from gui and update olfactometerInstructions structure
pointersToGui = [olfactometerInstructions(:).userSettingNumber]; % As not all necessary olfactometer settings are present in the gui, these numbers allow cross referencing
for i = 1 : length(h.olfactometerSettings.edit)
    indexStruct2GuiField = find(pointersToGui==i); % finds the corresponding olfactometerInstructions index to the current gui field
    if ~isempty(indexStruct2GuiField)
        olfactometerInstructions(indexStruct2GuiField).value = str2num(get(h.olfactometerSettings.edit(i),'String')); % entry in the field is a string therefore change to number
        
        % Extract whether the current valve should be used:
        % only if there is a checkbox for the current field in the
        % olfactometer settings update the olfactometerInstructions
        if h.olfactometerSettings.check(i) ~= 0 % settings fields which don't have a possibility to check have a 0 entry
            olfactometerInstructions(indexStruct2GuiField).used = get(h.olfactometerSettings.check(i),'Value');
        end
    else
        error(['olfactometerInstructions structure has no matching entry for field # ' num2str(i)])
    end
end
clear pointersToGui; clear indexStruct2GuiField;
end


function trialSeqButton(~,~)%,olfactometerInstructions)
global h
global olfactometerInstructions


% switch graphical trialSequence figure from visible to non visible and
% back when clicking the button
if strncmp(get(h.olfactometerSettings.trialSeqFig,'Visible'),'on',2)
    set(h.olfactometerSettings.trialSeqFig,'Visible','off');
elseif strncmp(get(h.olfactometerSettings.trialSeqFig,'Visible'),'off',3)
    set(h.olfactometerSettings.trialSeqFig,'Visible','on');
    cla(gca(h.olfactometerSettings.trialSeqFig));
    
    olfactometerInstructions = extractOlfactometerSettings(olfactometerInstructions);
       
    names = {olfactometerInstructions.name}; % Extract names of the parameters in the structure
    settingsName = get(h.olfactometerSettings.edit,'Tag'); % Extract names of the parameters in the gui
    
    % Go through every user settable parameter
    % Find it in the olfactometerInstructions structure, and extract the
    % value
    lookFor = 'powerGatingValve'; % define parameter to check
    pgv = strcmp(lookFor,names); % Find the entry of the structure corresponding to the parameter
    lookFor = 'unpowerGatingValve'; % define parameter to check
    ugv = strcmp(lookFor,names'); % Find the entry of the structure corresponding to the parameter
    
    lookFor = 'powerFinalValve';
    pfv = strcmp(lookFor,names);
    lookFor = 'unpowerFinalValve';
    ufv = strcmp(lookFor,names);
    
    lookFor = 'closeSuctionValve';
    csv = strcmp(lookFor,names);
    lookFor = 'openSuctionValve';
    osv = strcmp(lookFor,names);
    
    lookFor = 'openSniffingValve';
    osnv = strcmp(lookFor,names);
    lookFor = 'closeSniffingValve';
    csnv = strcmp(lookFor,names);
    
    lookFor = 'purge';
    purge = strcmp(lookFor,names);
    
    lookFor = 'cleanNose';
    cn = strcmp(lookFor,names);
     
    clear names;
    
    % Now check wether problems exist
    % a. Are all valves turned off after they have been turned on?
    % b. purge starting after end of sniffing and unpowering final valve?
    % c. Warn if none of the three presentation valves are used: final,
    % suction & sniffing
    % d. Is nose cleaning done after the end of presentation?
    
    
    % a. 
    
    % Gating valve
    if olfactometerInstructions(pgv).used == 1
        for i=1:length(olfactometerInstructions(pgv).value)
            if olfactometerInstructions(pgv).value(i) >= olfactometerInstructions(ugv).value(i) || ... % if powering of gating valve is later or at the same time than unpowering
                    isempty(olfactometerInstructions(pgv).value(i)) || isempty(olfactometerInstructions(ugv).value(i)) || ... % if powering or unpowering values are not defined
                    ~isreal(olfactometerInstructions(pgv).value(i)) || ~isreal(olfactometerInstructions(ugv).value(i)) || ... % if any of the values is not a real number also works for vector elements
                    olfactometerInstructions(pgv).value(i) < 0 || olfactometerInstructions(pgv).value(i) < 0 % if any of the values is negative
                warning('Gating valve settings: Only real positive values. Powering must precede unpowering. Change settings!')
                cla
                return
            end
        end
    end
    
    % Final valve
    if olfactometerInstructions(pfv).used == 1
        if olfactometerInstructions(pfv).value >= olfactometerInstructions(ufv).value || ... % if powering of final valve is later or at the same time than unpowering
            isempty(olfactometerInstructions(pfv).value) || isempty(olfactometerInstructions(ufv).value) || ... % if powering or unpowering values are not defined
            ~isreal(olfactometerInstructions(pfv).value) || ~isreal(olfactometerInstructions(ufv).value) || ... % if any of the values is not a real number
            olfactometerInstructions(pfv).value < 0 || olfactometerInstructions(ufv).value < 0 % if any of the values is negative
            warning('GOnly positive values allowed. Change settings!')
            cla
            return
        end
    end
    
    
    
    % conditional that no problems exist otherwise 
    
    axisHandle = gca(h.olfactometerSettings.trialSeqFig);
    cla(axisHandle); % clear all children (=plotted data) of the axis
    hold(axisHandle,'on')
    
    i=1;
    index = strcmp('powerGatingValve',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    
    xvalues = 0;
    yvalues = i;
    for j = 1 : length(olfactometerInstructions(pgv).value)
        xvalues(end+1:end+4) = [olfactometerInstructions(pgv).value(j) olfactometerInstructions(pgv).value(j) olfactometerInstructions(ugv).value(j) olfactometerInstructions(ugv).value(j)];
        yvalues(end+1:end+4) = [i i+0.5 i+0.5 i];
    end
    xvalues(end+1) = 100;
    yvalues(end+1) = i;
    
    plot(axisHandle,xvalues,yvalues,'-k','Linewidth',1.5,'Color',color)
    value{i} = olfactometerInstructions(ugv).value;
    
    i=2;
    index = strcmp('powerFinalValve',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    plot(axisHandle,[0 olfactometerInstructions(pfv).value olfactometerInstructions(pfv).value olfactometerInstructions(ufv).value olfactometerInstructions(ufv).value 100],...
        [i i i+0.5 i+0.5 i i],'-k','Linewidth',1.5,'Color',color)
    value{i} = olfactometerInstructions(ufv).value;
    
    i=3;
    index = strcmp('closeSuctionValve',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    plot(axisHandle,[0 olfactometerInstructions(csv).value olfactometerInstructions(csv).value olfactometerInstructions(osv).value olfactometerInstructions(osv).value 100],...
        [i i i+0.5 i+0.5 i i],'-k','Linewidth',1.5,'Color',color)
    value{i} = olfactometerInstructions(osv).value;
    
    i=4;
    index = strcmp('openSniffingValve',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    plot(axisHandle,[0 olfactometerInstructions(osnv).value olfactometerInstructions(osnv).value olfactometerInstructions(csnv).value olfactometerInstructions(csnv).value 100],...
        [i i i+0.5 i+0.5 i i],'-k','Linewidth',1.5,'Color',color)
    value{i} = olfactometerInstructions(csnv).value;
    
    i=5;
    index = strcmp('purge',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    plot(axisHandle,[0 olfactometerInstructions(purge).value olfactometerInstructions(purge).value 100],[i i i+0.5 i+0.5],'-k','Linewidth',1.5,'Color',color)
    value{i} = olfactometerInstructions(purge).value;
    
    i=6;
    index = strcmp('cleanNose',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    plot(axisHandle,[0 olfactometerInstructions(cn).value olfactometerInstructions(cn).value olfactometerInstructions(cn).value+3 olfactometerInstructions(cn).value+3 100],...
        [i i i+0.5 i+0.5 i i],'-k','Linewidth',1.5,'Color',color)
    value{i} = olfactometerInstructions(cn).value+3;
    
    
    ylim([0 i+1])
    xlim([0 max(cell2mat(value))+1])
    
    clear axisHandle
end

end

% 
% function close_trialSeqFig(~,~)
% global h
% 
%     set(h.olfactometerSettings.trialSeqFig,'Visible','off'); 
% end


function helpButton_Callback(~,~)
global h

callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function in the highest
path = which(callingFunctionName);
path(length(path)-length(callingFunctionName):length(path))=[];
path=[path '/Documentation/Olfactometer_Schematic.tif'];
helpImage = imread(path);
h.olfactometerSettings.helpSchematicWindow = figure('ToolBar','none','Name','Layout & nomenclature','MenuBar','none');
imshow(helpImage,'Border','tight')
clear callingFunctionName; clear path;
end
 

function close_helpSchematicWindow(~,~)
% set(h.olfactometerSettings.helpSchematicWindow,'Visible','off'
% close(gcf)
end




      
%% Add subfunctions to add additional settings