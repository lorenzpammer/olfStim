function h = olfactometerSettings(h,instruction,additionalSettings,panelPosition)
% olfactometerInstructions(instruction)
% This function is private to the protocols and adds a panel to the bottom
% of the gui where the settings specifying the olfactometer behavior are
% defined. The code will add x settings options to the gui, which are
% described below.
% instruction is either 'setUp' - when building the gui at the beginning of
% a session this option will add the panel and all the user defineable
% settings to the gui.
% 'setUpStructure' - only olfactometerSettingsStructure is set up.
% or 'get' - which is called at the beginning of every trial from the
% stimulation protocol functions, before calling buildSmell('update') and
% commands are sent to the LASOM. The instruction 'get' will cause the
% function to extract all values from the user defineable settings and
% update the global olfactometerInstructions structure. Also it will
% check whether the times defined by the user make sense and whether the
% MFC flow rates are below the maximum flow rate.
%
% olfactometerInstructions(instruction, additionalSettings)
% If you want to allow the user to define further settings, you have to
% specify a cell array of strings with the name of each new settings per
% cell. Then add a new subfunction which can set 'setUp' or extract 'get'
% these settings.
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
% To do:
% - Let user define how the digital timestamps are sent from the
% olfactometer.
% - Let user define new valves to be used. 
%
% lorenzpammer 2011/09

global olfactometerInstructions

%% Import function packages

% Import all functions of the current stimulation protocol
import protocolUtilities.*


%% Check inputs

if nargin < 2
    error('You have to give instructions, whether to set up the panel or get information.')
end

if nargin < 3
    additionalSettings = []; % Set additional settings to empty. Only default settings will be set up and extracted.
    
    if strncmp(instruction, 'setUp',5) || strncmp(instruction,'get',3) || strncmp(instruction,'setUpStructure',3)
        % Fine
    else
        error('First input to the function must be a string "setUp", "setUpStructure" or "get". See the help.')
    end
end

if nargin < 4
    % if additional settings are specified but not correctly, give errors.
    if nargin > 2 && ~iscell(additionalSettings)
        error('Third input to function, "additionalSettings" must be a cell array of strings.')
    end
end



%% Set up panel and all settings

if strcmp(instruction,'setUp') || strcmp(instruction,'setUpStructure')
    
    %% Set up olfactometerInstructions structure
    
%     olfactometerInstructions = struct('name',{'mfcTotalFlow' 'powerGatingValve' 'unpowerGatingValve' ,...
%         'powerFinalValve' 'unpowerFinalValve' 'closeSuctionValve' 'openSuctionValve',...
%         'openSniffingValve' 'closeSniffingValve' 'powerHumidityValve' 'unpowerHumidityValve',...
%         'purge' 'cleanNose' 'startOnExternalTrigger'},...
%         'value',cell(1,14),...
%         'unit',{ 'l/m' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's' 'type'},...
%         'userSettingNumber',[],...
%         'used',{1 1 1 1 1 0 0 1 1 0 0 1 1 1},...
%         'timeStampID',[]);
%     

 olfactometerInstructions = struct('name',{'mfcTotalFlow' 'powerGatingValve' 'unpowerGatingValve' ,...
        'powerFinalValve' 'unpowerFinalValve' 'closeSuctionValve' 'openSuctionValve',...
        'openSniffingValve' 'closeSniffingValve' 'powerHumidityValve' 'unpowerHumidityValve',...
        'purge' 'cleanNose'},...
        'value',cell(1,13),...
        'unit',{ 'l/m' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's'},...
        'userSettingNumber',[],...
        'used',{1 1 1 1 1 0 0 1 1 0 0 1 1},...
        'timeStampID',[]);
    
    %% Hard code time stamp code for the different events
    % timeStampDefinitions holds the definitions for the mapping of
    % olfactometer events to time stamp values, and adds this information
    % to the olfactometerInstructions structure.
    
    olfactometerInstructions = timeStampDefinitions(olfactometerInstructions);
    
    
    if strcmp(instruction,'setUp')
        
        %% Define panelPosition if it wasn't defined in inputs
        if nargin < 4
            sessionNotesPanel = get(h.sessionNotes.panel,'Position');
            figurePosition = get(h.guiHandle,'Position');
            try
                endSessionPosition = get(h.endSession,'Position');
                subtractDistance = endSessionPosition(3);
            catch
                subtractDistance = 0;
            end
            spacing = 3;
            panelPosition(1) = sessionNotesPanel(1) + sessionNotesPanel(3) + spacing;
            panelPosition(2) = spacing;
            panelPosition(3) = figurePosition(3) - sessionNotesPanel(1) - sessionNotesPanel(3) - subtractDistance - spacing*3;
            panelPosition(4) = sessionNotesPanel(2) + sessionNotesPanel(4);
        end
        clear sessionNotesPanel;clear figurePosition;clear quitSessionPosition;
        
        
        h.olfactometerSettings.panel = uipanel('Parent',h.guiHandle,'Title','Olfactometer Settings',...
            'Tag','olfactometerSettingsPanel','FontSize',8,'TitlePosition','centertop',...
            'Units','pixels','Position',panelPosition); % 'Position',[x y width height]
        
        %% Define positions for the controls:
        % Total of 14 possible positions in the panel: 2x7
        
        numberOfColumns = ceil(length(olfactometerInstructions)/2);
        numberOfRows = 2;
        
        positions = cell(numberOfRows,numberOfColumns); % One cell for each of the x positions in the panel
        width = panelPosition(3) / numberOfColumns;
        height = (panelPosition(4)-15) / numberOfRows; % -10 because the text of the panel is included in the height
        
        
        
        for j = 1 : numberOfRows
            counter = 0;
            for i = j : numberOfRows : length(olfactometerInstructions)
                counter = counter+1;
                tempYPosition = panelPosition(2) + (height*(numberOfRows - j));
                positions{i} = [panelPosition(1) + (counter-1)*width,...
                    tempYPosition,...
                    width, height];
                
                
                
            end
        end
        clear counter; clear width; clear height
        
        
        %% Define the size of the edit field ('edit') and its descriptor ('text')
        textHeight = 30; textWidth = 70;
        editHeight = 20; editWidth = 50;
        
        %% Graphical depiction of a sequence of events in a trial
        
        % First create a button which allows one to open and close the
        % graphical depiction of the sequence of events, but also checks
        % whether the sequence makes sense (eg when one valve is opened it must
        % be closed as well)
        position = [panelPosition(1)+panelPosition(3)-53 panelPosition(2)+spacing 50 25];
        h.olfactometerSettings.trialSeqButton = uicontrol(h.guiHandle,'Position',position,'String','Trial Seq',...
            'Callback',@trialSeqButton); % give input to function handle: 'Callback',{@trialSeqButton, olfactometerInstructions}
        
        
        %% Define the options which can be set to control the olfactometer
        
        % Order of Olfactometer settings fields
        %     {'mfcTotalFlow' 'powerGatingValve' 'unpowerGatingValve' ,...
        %     'powerFinalValve' 'unpowerFinalValve' 'closeSuctionValve' 'openSuctionValve',...
        %     'openSniffingValve' 'closeSniffingValve' 'powerHumidityValve'
        %     'unpowerHumidityValve',...
        %          'purge' 'cleanNose'}
        settingValue = [1 0 5 3 5 3.25 5 3.5 5 9 12 NaN 10]; % value for the different settings (in the according units)
        useEditField = logical([1 1 1 1 1 1 1 1 1 1 1 0 1]); % whether or not an editing field should be added to the gui for each setting
        useCheckBox = logical([0 1 0 1 0 1 0 1 0 1 0 1 1]); % whether or not a checkbox indicating used/non-used should be added to the gui
        dependentOnSetting = {0 0 'powerGatingValve' 0 'powerFinalValve' 0 ... % on which setting (written as a string) a given setting (sequence) is dependent.
            'closeSuctionValve' 0 'openSniffingValve' 0 'powerHumidityValve' 0 0};
        
        
        for settingNumber = 1 : length(olfactometerInstructions)
            
            % Set up some missing parameters for the current setting:
            userSettingNumber = settingNumber;
            olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
            olfactometerInstructions(settingNumber).value = settingValue(settingNumber);
            
            % Set up the user controls for the current setting in the GUI:
            
            % Text label:
            position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
            h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
                'Style','text','String',[olfactometerInstructions(settingNumber).name ' ' olfactometerInstructions(settingNumber).unit],...
                'Position', position,'Tag',olfactometerInstructions(settingNumber).name,...
                'Fontsize',7.5);
            
            % Field for editing the value of the setting:
            if useEditField(settingNumber)
                position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+spacing editWidth editHeight];
                h.olfactometerSettings.edit(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
                    'Style','edit','String',num2str(olfactometerInstructions(settingNumber).value),'Position', position,...
                    'Tag',olfactometerInstructions(settingNumber).name);
            end
            
            % Check field whether to use the valve or not:
            if useCheckBox(settingNumber)
                position = [positions{userSettingNumber}(1)+position(3)+spacing positions{userSettingNumber}(2)+10 15 15];
                h.olfactometerSettings.check(userSettingNumber) = uicontrol('Parent',h.guiHandle,... % check to define whether the final valve should be used
                    'Style','checkbox','String','','Value',olfactometerInstructions(settingNumber).used,'Position', position,...
                    'Tag',olfactometerInstructions(settingNumber).name);
                % if there's  a setting for which only the checkbox is set
                % change the position.
                if ~useEditField(settingNumber)
                    position = [positions{userSettingNumber}(1)+editWidth/2 positions{userSettingNumber}(2)+(editHeight/2) 15 15];
                   set(h.olfactometerSettings.check(userSettingNumber),'Position', position);
                end
                
            end
            
            
            % Use the same handle for the used setting in the opening and
            % closing of a valve
            if all(dependentOnSetting{settingNumber} ~= 0)
                tagName = get(h.olfactometerSettings.text, 'Tag');
                relatedSettingIndex = find(strcmp(dependentOnSetting{settingNumber},tagName));
                h.olfactometerSettings.check(userSettingNumber) = h.olfactometerSettings.check(relatedSettingIndex);
            end
            
        end
        
        clear settingValue userSettingNumber settingNumber useCheckBox tagName relatedSettingIndex dependentOnSetting
        
        
        % Set Callback function
        % Get tag names:
        for i = 1 : length(h.olfactometerSettings.edit)
           tagNames{i} = get(h.olfactometerSettings.edit(i),'Tag');
        end
        % Find the index of the mfcTotalFlow field
        index = find(strcmp('mfcTotalFlow',tagNames));
        % Set the callback function for the field found:
        set(h.olfactometerSettings.edit(index),'Callback',@mfcTotalFlowEditCallback);
        clear tagNames index
        
        
        
        % Color code the setting fields
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
        index1(i) = strmatch('powerHumidityValve',names);
        index2(i) = strmatch('unpowerHumidityValve',names);
        
%         i = 6;
%         index1(i) = strmatch('purge',names);
%         index2(i) = 0;
        
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
        % If additional settings are necessary for the particular protocol
        if ~isempty(additionalSettings)
            for i = 1 : length(additionalSettings)
                fh = str2func(additionalSettings(i)); % make string of selected additional Setting to function handle
                fh(instruction,olfactometerInstructions); % evaluate function handle, i.e. call function
            end
        end
    end
end

%% 

if strncmp(instruction,'get',3)
    % Get the information in the Gui prior to sending the commands to the
    % olfactometer.

    olfactometerInstructions = extractOlfactometerSettings(olfactometerInstructions,h);

end

end




%% SUBFUNCTIONS


function olfactometerInstructions = extractOlfactometerSettings(olfactometerInstructions,h)

% Extract field from gui and update olfactometerInstructions structure
% As not all necessary olfactometer settings are present in the gui, these numbers allow cross referencing
pointersToGui = [olfactometerInstructions(:).userSettingNumber]; 
for i = 1 : length(h.olfactometerSettings.edit)
    % finds the corresponding olfactometerInstructions index to the current gui field
    indexStruct2GuiField = find(pointersToGui==i); 
    if ~isempty(indexStruct2GuiField)
        
        % Extract whether the timepoint of triggering the current action:
        % only if there is a edit field for the current action in the
        % olfactometer settings update the olfactometerInstructions
        if h.olfactometerSettings.edit(i) ~= 0
            olfactometerInstructions(indexStruct2GuiField).value = str2num(get(h.olfactometerSettings.edit(i),'String')); % entry in the field is a string therefore change to number
        end
        
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


function trialSeqButton(src, event)

global olfactometerInstructions

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%%
% switch graphical trialSequence figure from visible to non visible and
% % back when clicking the button
 try ishandle(h.olfactometerSettings.trialSeqFig);
    close(h.olfactometerSettings.trialSeqFig);
 catch 
%     set(h.olfactometerSettings.trialSeqFig,'Visible','on');
%     cla(gca(h.olfactometerSettings.trialSeqFig));
    
%% Set up the figure

        position = get(h.guiHandle,'Position');
        position = [(position(1:3) - [0 160 0]) 130];
        h.olfactometerSettings.trialSeqFig = figure('Position',position,'menubar','none',...
            'Visible','on','Name','Sequence of events in a trial'); %'CloseRequestFcn',@close_trialSeqFig
        
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
        
    %% Plot the trial structure
    
    olfactometerInstructions = extractOlfactometerSettings(olfactometerInstructions,h);
       
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
    
    lookFor = 'powerHumidityValve';
    phv = strcmp(lookFor,names);
    lookFor = 'unpowerHumidityValve';
    uhv = strcmp(lookFor,names);
     
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
            if any(olfactometerInstructions(pgv).value(i) >= olfactometerInstructions(ugv).value(i) | ... % if powering of gating valve is later or at the same time than unpowering
                    isempty(olfactometerInstructions(pgv).value(i)) | isempty(olfactometerInstructions(ugv).value(i)) | ... % if powering or unpowering values are not defined
                    ~isreal(olfactometerInstructions(pgv).value(i)) | ~isreal(olfactometerInstructions(ugv).value(i)) | ... % if any of the values is not a real number also works for vector elements
                    olfactometerInstructions(pgv).value(i) < 0 | olfactometerInstructions(pgv).value(i) < 0) % if any of the values is negative
                warning('Gating valve: Only real positive values. Powering must precede unpowering. Change settings!')
                cla
                return
            end
        end
    end
    
    % Final valve
    if olfactometerInstructions(pfv).used == 1
        if any(olfactometerInstructions(pfv).value >= olfactometerInstructions(ufv).value | ... % if powering of final valve is later or at the same time than unpowering
            isempty(olfactometerInstructions(pfv).value) | isempty(olfactometerInstructions(ufv).value) | ... % if powering or unpowering values are not defined
            ~isreal(olfactometerInstructions(pfv).value) | ~isreal(olfactometerInstructions(ufv).value) | ... % if any of the values is not a real number
            olfactometerInstructions(pfv).value < 0 | olfactometerInstructions(ufv).value < 0) % if any of the values is negative
            warning('Final valve: Only positive, real values allowed. Powering must precede unpowering. Change settings!')
            cla
            return
        end
    end
    
    % Purging
    if olfactometerInstructions(purge).used == 1
        if any(~isreal(olfactometerInstructions(purge).value) | ... % if any of the values is not a real number
            isempty(olfactometerInstructions(purge).value) | ... % if powering or unpowering values are not defined
            olfactometerInstructions(purge).value < 0 | ... % if any of the values is negative
            length(olfactometerInstructions(purge).value) > 1)
            warning('Purge: Only positive, real, single values allowed. Change settings!')
            cla
            return
        end
    end
    
    
    
    %% If no problems exist plot the following:
    
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
    if olfactometerInstructions(pgv).used == 1
        plot(axisHandle,xvalues,yvalues,'-k','Linewidth',1.5,'Color',color)
    end
    value{i} = olfactometerInstructions(ugv).value;
    
    i=2;
    index = strcmp('powerFinalValve',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    xvalues = 0;
    yvalues = i;
    for j = 1 : length(olfactometerInstructions(pfv).value)
        xvalues(end+1:end+4) = [olfactometerInstructions(pfv).value(j) olfactometerInstructions(pfv).value(j) olfactometerInstructions(ufv).value(j) olfactometerInstructions(ufv).value(j)];
        yvalues(end+1:end+4) = [i i+0.5 i+0.5 i];
    end
    xvalues(end+1) = 100;
    yvalues(end+1) = i;
    if olfactometerInstructions(pfv).used == 1
        plot(axisHandle,xvalues,yvalues,'-k','Linewidth',1.5,'Color',color)
    end
    value{i} = olfactometerInstructions(ufv).value;
    
    i=3;
    index = strcmp('closeSuctionValve',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    xvalues = 0;
    yvalues = i;
    for j = 1 : length(olfactometerInstructions(csv).value)
        xvalues(end+1:end+4) = [olfactometerInstructions(csv).value(j) olfactometerInstructions(csv).value(j) olfactometerInstructions(osv).value(j) olfactometerInstructions(osv).value(j)];
        yvalues(end+1:end+4) = [i i+0.5 i+0.5 i];
    end
    xvalues(end+1) = 100;
    yvalues(end+1) = i;
    if olfactometerInstructions(csv).used == 1
    plot(axisHandle,xvalues,yvalues,'-k','Linewidth',1.5,'Color',color)
    end
    value{i} = olfactometerInstructions(osv).value;
    
    i=4;
    index = strcmp('openSniffingValve',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    xvalues = 0;
    yvalues = i;
    for j = 1 : length(olfactometerInstructions(osnv).value)
        xvalues(end+1:end+4) = [olfactometerInstructions(osnv).value(j) olfactometerInstructions(osnv).value(j) olfactometerInstructions(csnv).value(j) olfactometerInstructions(csnv).value(j)];
        yvalues(end+1:end+4) = [i i+0.5 i+0.5 i];
    end
    xvalues(end+1) = 100;
    yvalues(end+1) = i;
    if olfactometerInstructions(osnv).used == 1
        plot(axisHandle,xvalues,yvalues,'-k','Linewidth',1.5,'Color',color)
    end
    value{i} = olfactometerInstructions(csnv).value;
    
    i=5;
    index = strcmp('powerHumidityValve',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    xvalues = 0;
    yvalues = i;
    for j = 1 : length(olfactometerInstructions(phv).value)
        xvalues(end+1:end+4) = [olfactometerInstructions(phv).value(j) olfactometerInstructions(phv).value(j) olfactometerInstructions(uhv).value(j) olfactometerInstructions(uhv).value(j)];
        yvalues(end+1:end+4) = [i i+0.5 i+0.5 i];
    end
    xvalues(end+1) = 100;
    yvalues(end+1) = i;
    if olfactometerInstructions(phv).used == 1
        plot(axisHandle,xvalues,yvalues,'-k','Linewidth',1.5,'Color',color)
    end
    value{i} = olfactometerInstructions(uhv).value;
    
%     i=6;
%     index = strcmp('purge',settingsName);
%     color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
%     if olfactometerInstructions(purge).used == 1
%     plot(axisHandle,[0 olfactometerInstructions(purge).value olfactometerInstructions(purge).value 100],[i i i+0.5 i+0.5],'-k','Linewidth',1.5,'Color',color)
%     end
%     value{i} = olfactometerInstructions(purge).value;
    
    i=6;
    index = strcmp('cleanNose',settingsName);
    color = get(h.olfactometerSettings.edit(index),'BackgroundColor');
    xvalues = 0;
    yvalues = i;
    for j = 1 : length(olfactometerInstructions(cn).value)
        xvalues(end+1:end+4) = [olfactometerInstructions(cn).value(j) olfactometerInstructions(cn).value(j) olfactometerInstructions(cn).value(j)+2 olfactometerInstructions(cn).value(j)+2];
        yvalues(end+1:end+4) = [i i+0.5 i+0.5 i];
    end
    xvalues(end+1) = 100;
    yvalues(end+1) = i;
    if olfactometerInstructions(cn).used == 1
    plot(axisHandle,xvalues,yvalues,'-k','Linewidth',1.5,'Color',color)
    end
    value{i} = olfactometerInstructions(cn).value+2;
    
    
    ylim([0 i+1])
    xlim([0 max(cell2mat(value))+1])
    
    clear axisHandle
 end

%% Update h structure in the appdata
% Write the structure h containing all handles for the figure as appdata:
appdataManager('olfStimGui','set',h);
end


function helpButton_Callback(~,~)

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');
%%

callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function in the highest
path = which(callingFunctionName);
path(length(path)-length(callingFunctionName):length(path))=[];
path=[path filesep 'Documentation' filesep 'Olfactometer_Schematic.tif'];
helpImage = imread(path);
h.olfactometerSettings.helpSchematicWindow = figure('ToolBar','none','Name','Layout & nomenclature','MenuBar','none');
imshow(helpImage,'Border','tight')
clear callingFunctionName; clear path;

%% Update h structure in the appdata
% Write the structure h containing all handles for the figure as appdata:
appdataManager('olfStimGui','set',h)
end
      
%% Add subfunctions to add additional settings