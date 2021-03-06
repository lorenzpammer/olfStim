function h = olfactometerSettings(h,instruction,panelPosition,varargin)
% h = olfactometerSettings(h,instruction,additionalSettings,panelPosition)
% This function is private to the protocols and adds a panel to the bottom
% of the gui where the settings specifying the olfactometer behavior are
% defined. The code will add x settings options to the gui, which are
% described below.
% instruction is either 
% 'setUp' - when building the gui at the beginning of
%       a session this option will add the panel and all the user
%       defineable settings to the gui.
% 'setUpStructure' - only olfactometerInstructions structure is set up.
%       or 'get' - which is called at the beginning of every trial from the
%       stimulation protocol functions, before calling buildSmell('update')
%       and commands are sent to the LASOM. The instruction 'get' will
%       cause the function to extract all values from the user defineable
%       settings and update the global olfactometerInstructions structure.
%       Also it will check whether the times defined by the user make sense
%       and whether the MFC flow rates are below the maximum flow rate.
% 'get' - extract the values in the gui fields and 
%
% 'updateStructure' - eg. protocolUtilities.olfactometerSettings([],'updateStructure',[],'powerFinalValve', {'value' [1 3]},{'used' 1})
%       olfactometerSettings([],'updateStructure',[],instructionNameToUpdate,{fieldName value}, {fieldName value}, instructionNameToUpdate,{fieldName value})
%       
%
% olfactometerInstructions(h,instruction, panelPosition)
% If you do not want to use the default position for the panel - at the
% bottom of the gui - you can specify a position [x y width height] where
% the panel should be placed.
%
%
% Default settings:
%
% MFC total flow - default 1 liter/min
%
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
    
    if strncmp(instruction, 'setUp',5) || strncmp(instruction,'get',3) || strncmp(instruction,'setUpStructure',3) || strcmp(instruction,'updateStructure')
        % Fine
    else
        error('Second input to the function must be a string "setUp", "setUpStructure" "updateStructure" or "get". See the help.')
    end
end

if nargin < 4
    varargin = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up panel and all settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(instruction,'setUp') || strcmp(instruction,'setUpStructure')
    
    %% Set up olfactometerInstructions structure
    
%     olfactometerInstructions = struct('name',{'mfcTotalFlow' 'powerGatingValve' 'unpowerGatingValve' ,...
%         'powerFinalValve' 'unpowerFinalValve' 'closeSuctionValve' 'openSuctionValve',...
%         'openSniffingValve' 'closeSniffingValve' 'powerHumidityValve' 'unpowerHumidityValve',...
%         'purge' 'cleanNose'},...
%         'value',cell(1,13),...
%         'unit',{ 'l/m' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's' 's'},...
%         'used',{1 1 1 1 1 0 0 1 1 0 0 1 1},...
%         'timeStampID',[]);

olfactometerInstructions = struct('name',{'mfcTotalFlow' 'purge'},...
    'value', {1 NaN},...
    'unit',{ 'l/m' ''},...
    'used',{1 1},...
    'timeStampID',[]);

useEditField = [true false]; % whether or not an editing field should be added to the gui for each setting
useCheckBox = [false true]; % whether or not a checkbox indicating used/non-used should be added to the gui
dependentOnSetting = {0 0}; % on which setting (written as a string) a given setting (sequence) is dependent.

% Get the values from the general configurations file:
[names, values, used, timestamps, useEditFieldUser, useCheckBoxUser, dependentOnSettingUser] = ...
    olfStimConfiguration('valves');

% all units are in seconds
for i = 1 : length(names)
    unit{i} = 's';
end

tmp = struct('name',names,...
    'value',values,...
    'unit',unit,...
    'used',used,...
    'timeStampID',timestamps);

% append olfactometerInstructions by user configurations:
olfactometerInstructions = [olfactometerInstructions tmp];
useEditField = [useEditField useEditFieldUser];
useCheckBox = [useCheckBox useCheckBoxUser];
dependentOnSetting = [dependentOnSetting dependentOnSettingUser];

    %         settingValue = [1 0 5 3 5 3.25 5 3.5 5 9 12 NaN 10]; % value for the different settings (in the according units)
    %% Hard code time stamp code for the different events
    % timeStampDefinitions holds the definitions for the mapping of
    % olfactometer events to time stamp values, and adds this information
    % to the olfactometerInstructions structure.
    
    %olfactometerInstructions = timeStampDefinitions(olfactometerInstructions);
    
    
    if strcmp(instruction,'setUp')
        
        %% Define panelPosition if it wasn't defined in inputs
        if nargin < 4
            sessionNotesPanel = get(h.sessionNotes.panel,'Position');
            figurePosition = get(h.guiHandle,'Position');
            if isfield(h,'endSession')
                rightButtonPosition = get(h.endSession,'Position');
                subtractDistance = rightButtonPosition(3);
            elseif isfield(h,'startSession')
                rightButtonPosition = get(h.startSession,'Position');
                subtractDistance = rightButtonPosition(3);
            elseif isfield(h,'saveSessionInstructions')
                rightButtonPosition = get(h.saveSessionInstructions,'Position');
                subtractDistance = rightButtonPosition(3);
            elseif isfield(h,'loadSessionInstructions')
                rightButtonPosition = get(h.loadSessionInstructions,'Position');
                subtractDistance = rightButtonPosition(3);
            else
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
            'Callback',{@trialSeqButton,dependentOnSetting}); % give input to function handle: 'Callback',{@trialSeqButton, olfactometerInstructions}
        
        
        %% Define the options which can be set to control the olfactometer
        

        for settingNumber = 1 : length(olfactometerInstructions)
            
            % Set up some missing parameters for the current setting:
            userSettingNumber = settingNumber;
            %olfactometerInstructions(settingNumber).userSettingNumber = userSettingNumber;
            %olfactometerInstructions(settingNumber).value = settingValue(settingNumber);
            
            % Set up the user controls for the current setting in the GUI:
            
            % Text label:
            position = [positions{userSettingNumber}(1)+spacing positions{userSettingNumber}(2)+20 textWidth textHeight];
            
             % only if there's a unit associated with a setting, will we
             % write the unit in brackets 
            if ~isempty(olfactometerInstructions(settingNumber).unit)
                h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
                    'Style','text','String',[olfactometerInstructions(settingNumber).name ' (' olfactometerInstructions(settingNumber).unit ')'],...
                    'Position', position,'Tag',olfactometerInstructions(settingNumber).name,...
                    'Fontsize',7.5);
            else
                h.olfactometerSettings.text(userSettingNumber) = uicontrol('Parent',h.guiHandle,...
                    'Style','text','String',[olfactometerInstructions(settingNumber).name],...
                    'Position', position,'Tag',olfactometerInstructions(settingNumber).name,...
                    'Fontsize',7.5);
            end
            
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
        
        
        
        %% Color code the setting fields
        
        % Get the field names from the gui:
        guiFieldNames = get(h.olfactometerSettings.edit,'Tag');
        % Get the instruction names:
        instructionNames = {olfactometerInstructions.name};
        
        % Define which of the gui fields should be colorized (this is
        % needed to show the sequence of trials):
        for i = 1 : length(guiFieldNames)
            % Change the dependentOnSetting cell array, so it can be used
            % in the function strmatch:
            if dependentOnSetting{i}==0
                dependentOnSetting{i} = '';
            end
            
            % If the setting doesn't have an edit field or is a setting
            % that should not be colored, index it in the colorize variable:
            if ~isempty(strmatch(guiFieldNames{i},{'purge','mfcTotalFlow'},'exact')) || h.olfactometerSettings.edit(i) == 0
                colorize(i) = false;
            else
                colorize(i) = true;
            end
        end
        
        % Create indices for coloring the fields: 
        counter = 0;
        for i = 1:length(instructionNames)
            if isempty(dependentOnSetting{i}) && colorize(i)
                counter = counter + 1;
                % index for progressing coloring
                index1(counter) = strmatch(instructionNames{i},guiFieldNames);
                tmpind = strmatch(instructionNames{i},dependentOnSetting);
                if ~isempty(tmpind)
                    % index for coloring the dependent setting in the same
                    % color as the sister setting:
                    index2(counter) = tmpind;
                else 
                    index2(counter) = 0;
                end
                
            end
        end
%         
        color = hot(length(index1)+1);
        color(1,:) = [];
        
        for i = 1 : length(color(:,1))
            set(h.olfactometerSettings.edit(index1(i)),'BackgroundColor',color(i,:));
            if index2(i) ~= 0
                set(h.olfactometerSettings.edit(index2(i)),'BackgroundColor',color(i,:));
            end
        end
        
        clear names; clear index1; clear index2; clear color
        
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Update olfactometerInstructions adequately
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(instruction,'updateStructure')
    
    %% Input checking
    % Check whether fields to update are part of olfactometerInstructions,
    % otherwise give an error
    for i = 1: length(varargin)
        if isstr(varargin{i})
            instructionsToUpdate(i) = true;
        end
    end
    instructionsToUpdate = find(instructionsToUpdate);
    
    % Check whether the instruction and fields are defined correctly by the
    % user
    for i = 1:length(instructionsToUpdate)
        instructionsIndex = strcmp(varargin(instructionsToUpdate(i)),{olfactometerInstructions.name});    
        % The instruction exists in the olfactometerInstructions
        % structure. Everything is fine. If the user provided instruction
        % isn't found in the olfactometerInstructions structure give an
        % error.
        if ~any(instructionsIndex)
            msg = sprintf('The user provided instruction %s is not part of the olfactometerInstructions structure.',varargin{instructionsToUpdate(i)});
            error(msg)
        end
        
        % Check whether the fields of the instruction are correctly defined
        if i == length(instructionsToUpdate)
            fieldsToUpdate = instructionsToUpdate(i)+1 : length(varargin);
        else
            fieldsToUpdate = instructionsToUpdate(i)+1 : instructionsToUpdate(i+1)-1;
        end
        for j = 1 : length(fieldsToUpdate)
            temp = strcmp(varargin{fieldsToUpdate(j)}{1},fields(olfactometerInstructions));
            if ~any(temp)
                msg = sprintf('The user provided instruction field %s is not part of the olfactometerInstructions structure.',varargin{fieldsToUpdate(j)}{1});
            error(msg)
            end
        end
        clear temp 
    end
    

    %% Update the olfactometerInstructions structure
    
    for i = 1 : length(olfactometerInstructions)
        if any(strcmpi(olfactometerInstructions(i).name,varargin))
            index = find(strcmpi(olfactometerInstructions(i).name,varargin)); % Find the index of the current instruction
            for j = 1 : length(varargin)
                temp(j) = iscell(varargin{j});
            end
            
            % Extract the fields and their values of the instruction
            nextInstructionIndex = find(temp(index+1:end)==0);
            if isempty(nextInstructionIndex)
                currentInstructionValues = varargin(index+1:end);
            else
                currentInstructionValues = varargin(index+1:index+nextInstructionIndex - 1);
            end
            
            % Update the values of the fields of the olfactometer instruction
            for j = 1 : length(currentInstructionValues)
               olfactometerInstructions(i).(currentInstructionValues{j}{1}) = currentInstructionValues{j}{2}; 
            end
        end
        clear temp;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract instructions from the GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strncmp(instruction,'get',3)
    % Get the information in the Gui prior to sending the commands to the
    % olfactometer.

    olfactometerInstructions = extractOlfactometerSettings(olfactometerInstructions,h);

end

end




%% SUBFUNCTIONS


function olfactometerInstructions = extractOlfactometerSettings(olfactometerInstructions,h)

% Extract field from gui and update olfactometerInstructions structure
% As not all necessary olfactometer settings are present in the gui, the
% name of the olfactometerInstruction has to be found in the gui element
% tags.
pointersToGui = {olfactometerInstructions(:).name}; % Get all the names of the instructions
for i = 1 : length(h.olfactometerSettings.edit)
    % finds the corresponding olfactometerInstructions index to the current gui field
    
    % Some settings only have edit fields, other only check fields, others
    % have both.
    if h.olfactometerSettings.edit(i)~=0
        fieldName = get(h.olfactometerSettings.edit(i),'Tag'); % get the tag of the edit field
        indexStruct2GuiField = find(strcmp(fieldName,pointersToGui)); % The tag has the same name as the 
    elseif h.olfactometerSettings.check(i)~=0
        fieldName = get(h.olfactometerSettings.check(i),'Tag');
        indexStruct2GuiField = find(strcmp(fieldName,pointersToGui));
    else
        indexStruct2GuiField = [];
    end
    if ~isempty(indexStruct2GuiField)
        
        % Extract whether the timepoint of triggering the current action:
        % only if there is a edit field for the current action in the
        % olfactometer settings update the olfactometerInstructions
        if h.olfactometerSettings.edit(i) ~= 0 % settings fields which don't have a possibility to check have a 0 entry
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


function trialSeqButton(src, event,dependentOnSetting)

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
    
    instructionNames = {olfactometerInstructions.name}; % Extract names of the parameters in the structure
    guiFieldNames = get(h.olfactometerSettings.edit,'Tag'); % Extract names of the parameters in the gui
    
    % Go through every user settable parameter
    % Find it in the olfactometerInstructions structure, and extract the
    % value
    
    
    % Define which of the gui fields should be colored (this is
    % needed to show the sequence of trials):
    for i = 1 : length(guiFieldNames)
        % Change the dependentOnSetting cell array, so it can be used
        % in the function strmatch:
        if dependentOnSetting{i}==0
            dependentOnSetting{i} = '';
        end
        
        % If the setting doesn't have an edit field or is a setting
        % that should not be plotted, index it in the coloring variable:
        if ~isempty(strmatch(guiFieldNames{i},{'purge','mfcTotalFlow'},'exact')) || h.olfactometerSettings.edit(i) == 0
            plotSetting(i) = false;
        else
            plotSetting(i) = true;
        end
    end
    
    % Create indices for coloring the fields:
    counter = 0;
    for i = 1:length(instructionNames)
        if isempty(dependentOnSetting{i}) && plotSetting(i)
            counter = counter + 1;
            % index for progressing coloring
            
            index1(counter) = strmatch(instructionNames{i},guiFieldNames);
            tmpind = strmatch(instructionNames{i},dependentOnSetting);
            if ~isempty(tmpind)
                % index for coloring the dependent setting in the same
                % color as the sister setting:
                index2(counter) = tmpind;
            else
                % If no dependent setting, we don't know what to plot.
                % Ignore this 
                index1(counter) = [];
                counter = counter - 1;
                warnstr = sprintf('Valve setting %s: You have to provide on and off values for all valves.\nGraphical depiction of sequence of trial might not be shown correctly.',instructionNames{i});
                warning(warnstr)
            end
        end
    end
    
    
    
    
%% Now check wether problems exist
%     % a. Are all valves turned off after they have been turned on?
%     % b. purge starting after end of sniffing and unpowering final valve?
%     % c. Warn if none of the three presentation valves are used: final,
%     % suction & sniffing
%     % d. Is nose cleaning done after the end of presentation?
%
for j = 1 : length(index1)
    if olfactometerInstructions(index1(j)).used == 1
        for i=1:length(olfactometerInstructions(index1(j)).value)
            if any(olfactometerInstructions(index1(j)).value(i) >= olfactometerInstructions(index2(j)).value(i) | ... % if powering of gating valve is later or at the same time than unpowering
                    isempty(olfactometerInstructions(index1(j)).value(i)) | isempty(olfactometerInstructions(index1(j)).value(i)) | ... % if powering or unpowering values are not defined
                    ~isreal(olfactometerInstructions(index1(j)).value(i)) | ~isreal(olfactometerInstructions(index1(j)).value(i)) | ... % if any of the values is not a real number also works for vector elements
                    olfactometerInstructions(index1(j)).value(i) < 0 | olfactometerInstructions(index1(j)).value(i) < 0) % if any of the values is negative
                warnstr = sprintf('Valve setting %s and %s: Only real positive values. Powering must precede unpowering. Change settings!',instructionNames{index1(j)},instructionNames{index2(j)});
                warning(warnstr)
                cla
                % Plot that something's wrong
                xPosition = get(gca(h.olfactometerSettings.trialSeqFig),'xlim');
                xPosition = sum(xPosition)/2 - 2;
                currentYlim = get(gca(h.olfactometerSettings.trialSeqFig),'ylim');
                yPosition = (currentYlim(2)-currentYlim(1)) * 0.33;
                width=4;height = 3;
                rectangle('Parent',gca(h.olfactometerSettings.trialSeqFig),...
                    'Position',[xPosition yPosition width height],'FaceColor', [0.8 0.8 0.8]); % plot rectangle in the progress figure
                warnstr = sprintf('Wrong in values in valve setting %s or %s.',instructionNames{index1(j)},instructionNames{index2(j)});
                text(xPosition+0.2,yPosition+1.5,warnstr,'Fontsize',18,'Color','r');
                message = sprintf('\n \n Is claning solution in the vials? \n \n');
                return
            end
        end
    end
end
    
    %% If no problems exist plot the actions
    
    axisHandle = gca(h.olfactometerSettings.trialSeqFig);
    cla(axisHandle); % clear all children (=plotted data) of the axis
    hold(axisHandle,'on')
    
    for i = 1 : length(index1)
        clear xvalues yvalues
        color = get(h.olfactometerSettings.edit(index1(i)),'BackgroundColor');
        xvalues = 0;
        yvalues = i;
        for j = 1 : length(olfactometerInstructions(index1(i)).value)
            xvalues(end+1:end+4) = [olfactometerInstructions(index1(i)).value(j) olfactometerInstructions(index1(i)).value(j) olfactometerInstructions(index2(i)).value(j) olfactometerInstructions(index2(i)).value(j)];
            yvalues(end+1:end+4) = [i i+0.5 i+0.5 i];
        end
        xvalues(end+1) = 100;
        yvalues(end+1) = i;
        if olfactometerInstructions(index1(i)).used == 1
            plot(axisHandle,xvalues,yvalues,'-k','Linewidth',1.5,'Color',color)
            value{i} = olfactometerInstructions(index2(i)).value;
        end
    end
    
    % Get I/O data and plot it
    i=i+1;
    io = appdataManager('olfStimGui','get','io');  
    if ~isempty(io)
        color = [0 0 0];
        xvalues = {io(logical([io.used])).time};
        xvalues = cell2mat(xvalues);
        yvalues = i;
        for j = 1 : length(xvalues)
            plot(axisHandle,xvalues(j),yvalues,'*','Color',color)
        end
    else
        i=i-1;
    end
    
    
    % Indicate the timing of the end of the trial with a vertical broken
    % line
    allTerminatingValues = cell2mat(value);
    finalAction = nanmax(allTerminatingValues);
    plot(axisHandle,[finalAction finalAction], get(axisHandle,'Ylim') + [-1 +1],'--k','Linewidth',1.2)
    
    % Set the figure limits:
    ylim(axisHandle,[0 i+1])
    xlim(axisHandle,[0 max(cell2mat(value))+1])
    
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
path=[path filesep 'Documentation' filesep 'Olfactometer_Schematic.jpg'];
helpImage = imread(path);
h.olfactometerSettings.helpSchematicWindow = figure('ToolBar','none','Name','Layout & nomenclature','MenuBar','none');
imshow(helpImage,'Border','tight')
clear callingFunctionName; clear path;

%% Update h structure in the appdata
% Write the structure h containing all handles for the figure as appdata:
appdataManager('olfStimGui','set',h)
end