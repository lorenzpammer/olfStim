function [h, sessionInstructions] = sessionSettings(h,instruction,usedSettingNames,sessionInstructions,varargin)
%  [h, sessionInstructions] = sessionSettings(h,instruction,usedSettingNames,varargin)
%
% instruction is either 
% 'setUp' - when building the gui at the beginning of a session this option
%       will all the user defineable settings to the gui.
% 'setUpStructure' - only sessionInstructions structure is set up.
% 'updateStructure' - will do a couple of checks whether all provided
%       parameters are actually part of the sessionInstructions structure,
%       and will then update the fields. Necessary to give information on
%       what settings to update and what fields to update in varargin. 
%       'updateStructure' - eg. protocolUtilities.sessionSettings([],sessionInstructions,'updateStructure',[],'interTrialInterval', {'value' 15},{'used' 1})
%       sessionSettings([],'updateStructure',[],sessionInstructions,instructionNameToUpdate,{fieldName value}, {fieldName value}, instructionNameToUpdate,{fieldName value})
% 'get' - which is called at the beginning of every trial from the
%        stimulation protocol functions, before calling
%        buildSmell('update') and commands are sent to the LASOM. The
%        instruction 'get' will cause the  function to extract all values
%        from the user defineable settings and give them as an output in
%        the sessionInstructions structure. Also it will check whether the
%        times defined by the user make sense and whether the MFC flow
%        rates are below the maximum flow rate. 
%
% usedSettingNames - cell array of strings with the tags of possible
% settings.
%   Possible Settings:
%       - 'scientist'
%       - 'animalName'
%       - 'interTrialInterval'
%       - 'I/O'
%
%
% lorenzpammer september 2012

%% Check inputs

if nargin < 1
    error('You have to provide the gui handle.')
end

if nargin < 2
    error('You have to give instructions, whether to set up the settings or extract the settings.')
end

if nargin < 3
    if strncmp(instruction, 'setUp',5) || strcmp(instruction,'get') || strcmp(instruction,'setUpStructure')
        % Fine
    else
        error('First input to the function must be a string "setUp", "setUpStructure" or "get". See the help.')
    end
    
    if strcmp(instruction, 'setUp')
        error('Third input to function, "usedSettingNames" must be a cell array of strings.')
    end
end

if nargin < 5
    varargin = [];
end

if nargin < 5 && strcmp(instruction, 'setUp')
    % if additional settings are specified but not correctly, give errors.
    if ~iscell(usedSettingNames)
        error('Third input to function, "usedSettingNames" must be a cell array of strings.')
    end
end



%% Set up

if strcmp(instruction,'setUpStructure') || strcmp(instruction,'setUp')
    % Check if there is still a session structure available in the gui
    % appdata:
    oldSessionInstructions = appdataManager('olfStimGui','get','sessionInstructions');
    if ~isempty(oldSessionInstructions)
        % If there's still old sessionInstructions structure left, use the
        % active settings information. This can happen if the session
        % inforamtion is cleared, and a new session is started.
        activeSettings = {oldSessionInstructions.activeSettingNumber}; 
    else
        % At the beginning of a session, the active settings will be
        % defined below. The instruction is then 'setUp'
        activeSettings = [];
    end
    
    % Create the sessionInstructions structure
    sessionInstructions = struct('name',{'scientist' 'animalName',...
        'interTrialInterval','I/O'},...
        'value',{'' '' '' ''},...
        'unit',{ 'ID' 'ID' 's' ''},...
        'activeSettingNumber',activeSettings,...
        'used',{false false false false});  % for every setting put the default of not used, depending on which settings were provided in usedSettingNames, this will be overridden below.
    % Which user interface type for each entry
    uiType = {'edit' 'edit' 'edit' 'button'}; % Does the setting require a button or edit field
    checkBox = [false false false false]; % whether or not a checkbox indicating used/non-used should be added to the gui
    dependentOnSetting = {0 0 0 0}; % on which setting (written as a string) a given setting (sequence) is dependent.
    callbackFunction = {'' '' '' 'protocolUtilities.ioControl.setUpGui'};
    
    clear activeSettings;
    
    
    
    
    %%
    
    if strcmp(instruction,'setUp')
        
        %% Find which of the possible sessionInstructions should be used in this session
        % Update the 'used' property of the sessionInstructions if a
        % setting
        
        for i = 1: length(usedSettingNames)
            index = find(strcmp(usedSettingNames{i}, {sessionInstructions.name}));
            if ~isempty(index)
                sessionInstructions(index).used = true; % If the setting provided in the inputs to the function exists, mark that it is used.
            else
                error(['The provided setting "' usedSettingNames{i} '" isn''t configured. Change to an existing setting or add a new setting in sessionSettings.m.'])
                % setting doesn't exist in sessionInstructions structure.
                % If you want to add a new setting add it to the code above
                % creating the sessionInstuctions structure.
            end
        end
        
        
        %% Define positions for the controls:
        % Total of 14 possible positions in the panel: 2x7
        
        panelPosition = get(h.sessionSettings.panel,'Position');
        
        % Create necessary number of rows. One row can only  have 7
        % settings:
        numberOfRows = ceil(length(find([sessionInstructions.used])) / 7);
        % Calculate the necessary number of columns per row
        numberOfColumns = ceil(length(find([sessionInstructions.used]))/numberOfRows);
        
        positions = cell(numberOfRows,numberOfColumns); % One cell for each of the x positions in the panel
        width = panelPosition(3) / numberOfColumns;
        height = (panelPosition(4)-15) / numberOfRows; % -10 because the text of the panel is included in the height
        
        % Divide the settings panel into the appropriate fields for the
        % number of settings.
        counter = 0;
        for j = 1 : numberOfRows
            for i = 1 : numberOfColumns
                counter = counter+1;
                tempYPosition = panelPosition(2) + (height*(numberOfRows - j));
                positions{i} = [panelPosition(1) + (i-1)*width,...
                    tempYPosition,...
                    width, height];
            end
        end
        clear counter; clear width; clear height
        
        %% Define the size of the edit field ('edit') and its descriptor ('text')
        textHeight = 30; textWidth = 70;
        editHeight = 20; editWidth = 50;
        spacing = 3;
        
        %% Add the options which can be set from the gui
        
        % Order of Olfactometer settings fields
        %     {'scientist' 'animalName', 'interTrialInterval'}
        %         settingValue = {'' '' 30}; % value for the different settings (in the according units)
        useEditField = strcmp('edit',uiType); % whether or not an editing field should be added to the gui for each setting
        useButton = strcmp('button',uiType); % whether or not a button should be added instead of the the edit field
        useCheckBox = checkBox; % whether or not a checkbox indicating used/non-used should be added to the gui
        numberOfActiveSettings = length(find([sessionInstructions.used])); % Get the number of active sessionInstructions.
        usedSettingNames = {sessionInstructions(find([sessionInstructions.used])).name}; % extract the names of the active settings
        
        for activeSettingNumber = 1 : numberOfActiveSettings
            
            settingNumber = find(strcmp(usedSettingNames(activeSettingNumber),{sessionInstructions.name}));
            
            % Set up some missing parameters for the current setting:
            sessionInstructions(settingNumber).activeSettingNumber = activeSettingNumber;
            
            % Set up the user controls for the current setting in the GUI:
            
            % Text label:
            position = [positions{activeSettingNumber}(1)+spacing positions{activeSettingNumber}(2)+15 textWidth textHeight];
            h.sessionSettings.text(activeSettingNumber) = uicontrol('Parent',h.guiHandle,...
                'Style','text','String',[sessionInstructions(settingNumber).name ' ' sessionInstructions(settingNumber).unit],...
                'Position', position,'Tag',sessionInstructions(settingNumber).name,...
                'Fontsize',7.5);
            
            % Field for editing the value of the setting:
            if useEditField(settingNumber)
                position = [positions{activeSettingNumber}(1)+spacing positions{activeSettingNumber}(2)+spacing editWidth editHeight];
                h.sessionSettings.edit(activeSettingNumber) = uicontrol('Parent',h.guiHandle,...
                    'Style','edit','String',num2str(sessionInstructions(settingNumber).value),'Position', position,...
                    'Tag',sessionInstructions(settingNumber).name);
            end
            
            if useButton(settingNumber)
                position = [positions{activeSettingNumber}(1)+spacing positions{activeSettingNumber}(2)+spacing editWidth editHeight];
                h.sessionSettings.edit(activeSettingNumber) = uicontrol('Parent',h.guiHandle,...
                    'Style','pushbutton','String',num2str(sessionInstructions(settingNumber).name),'Position', position,...
                    'Tag',sessionInstructions(settingNumber).name,'Callback',{callbackFunction{settingNumber},h});
            end
            
            % Check field whether to use the setting or not:
            if useCheckBox(settingNumber)
                position = [positions{activeSettingNumber}(1)+position(3)+spacing positions{activeSettingNumber}(2)+10 15 15];
                h.sessionSettings.check(activeSettingNumber) = uicontrol('Parent',h.guiHandle,... % check to define whether the final valve should be used
                    'Style','checkbox','String','','Value',sessionInstructions(settingNumber).used,'Position', position,...
                    'Tag',sessionInstructions(settingNumber).name);
                % if there's  a setting for which only the checkbox is set
                % change the position.
                if ~useEditField(settingNumber)
                    position = [positions{activeSettingNumber}(1)+editWidth/2 positions{activeSettingNumber}(2)+(editHeight/2) 15 15];
                    set(h.sessionSettings.check(activeSettingNumber),'Position', position);
                end
            else
                h.sessionSettings.check(activeSettingNumber) = false;
            end
            
        end
        
    end
end



%% Extract the information
% If function is called with 'get' as instruction

if strcmp(instruction,'get')
    
    % Extract the sessionInstructions structure from the appdata of the figure:
    sessionInstructions=appdataManager('olfStimGui','get','sessionInstructions');
    
    % Extract the session settings from the gui:
    sessionInstructions = extractSessionSettings(h,sessionInstructions); 
end



%% Update the structure


if strcmp(instruction,'updateStructure')
%% Input checking

if isempty(sessionInstructions)
    [~, sessionInstructions] = protocolUtilities.sessionSettings([],'setUpStructure')
end

    % Check whether fields to update are part of olfactometerInstructions,
    % otherwise give an error
    for i = 1: length(varargin)
        if isstr(varargin{i})
            settingsToUpdate(i) = true;
        end
    end
    settingsToUpdate = find(settingsToUpdate);
    
    % Check whether the instruction and fields are defined correctly by the
    % user
    for i = 1:length(settingsToUpdate)
        instructionsIndex = strcmp(varargin(settingsToUpdate(i)),{sessionInstructions.name});    
        % The instruction exists in the olfactometerInstructions
        % structure. Everything is fine. If the user provided instruction
        % isn't found in the olfactometerInstructions structure give anda
        % error.
        if ~any(instructionsIndex)
            msg = sprintf('The user provided instruction %s is not part of the olfactometerInstructions structure.',varargin{settingsToUpdate(i)});
            error(msg)
        end
        
        % Check whether the fields of the instruction are correctly defined
        if i == length(settingsToUpdate)
            fieldsToUpdate = settingsToUpdate(i)+1 : length(varargin);
        else
            fieldsToUpdate = settingsToUpdate(i)+1 : settingsToUpdate(i+1)-1;
        end
        for j = 1 : length(fieldsToUpdate)
            temp = strcmp(varargin{fieldsToUpdate(j)}{1},fields(sessionInstructions));
            if ~any(temp)
                msg = sprintf('The user provided instruction field %s is not part of the olfactometerInstructions structure.',varargin{fieldsToUpdate(j)}{1});
            error(msg)
            end
        end
    end

    clear temp;
        
    %% Update the olfactometerInstructions structure
    
    for i = 1 : length(sessionInstructions)
        if any(strcmpi(sessionInstructions(i).name,varargin))
            index = find(strcmpi(sessionInstructions(i).name,varargin)); % Find the index of the current instruction
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
               sessionInstructions(i).(currentInstructionValues{j}{1}) = currentInstructionValues{j}{2}; 
            end
        end
    end
end

%% Update sessionInstructions structure in the appdata
% Write the structure h containing all handles for the figure as appdata:
appdataManager('olfStimGui','set',sessionInstructions);


end

function sessionInstructions = extractSessionSettings(h,sessionInstructions)

% Extract field from gui and update sessionInstructions structure
% As not all necessary session settings are present in the gui, these numbers allow cross referencing
pointersToGui = [sessionInstructions.activeSettingNumber]; 
for i = 1 : length(pointersToGui)
    % finds the corresponding sessionInstructions index to the current gui field
    indexStruct2GuiField = find(pointersToGui==i); 
    if ~isempty(indexStruct2GuiField)
        
        % Extract whether the timepoint of triggering the current action:
        % only if there is a edit field for the current action in the
        % olfactometer settings update the sessionInstructions
        if h.sessionSettings.edit(i) ~= 0
            sessionInstructions(indexStruct2GuiField).value = get(h.sessionSettings.edit(i),'String'); % entry in the field is a string. Later functions must deal with this.
        end
        
        % Extract whether the current valve should be used:
        % only if there is a checkbox for the current field in the
        % olfactometer settings update the sessionInstructions
        if h.sessionSettings.check(i) ~= 0 % settings fields which don't have a possibility to check have a 0 entry
            sessionInstructions(indexStruct2GuiField).used = get(h.sessionSettings.check(i),'Value');
        end
        
    else
        error(['sessionInstructions structure has no matching entry for field # ' num2str(i)])
    end
end
clear pointersToGui; clear indexStruct2GuiField;
end