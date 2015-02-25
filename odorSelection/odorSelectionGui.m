function olfactometerOdors = odorSelectionGui()

%% Set up some default variables

[numberOfVialsPerSlave,numberOfSlavesTables,showMixtureTables] = olfStimConfiguration('odorSelectionGui');

%% Set up main figure

figurePosition = [300 200 400 500];
handles.main = figure('Visible','on','Position',figurePosition,'NumberTitle','off',...
    'Name','odorSelectionGui', 'Tag', 'odorSelectionGui','MenuBar','none'); %'CloseRequestFcn',@myCloseFcn

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the gui components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Loading olfactometerOdors file
height=70;
panelPosition = [5 figurePosition(4)-height-5 figurePosition(3)-10 height];
% Note panel
handles.fileSelection.panel = uipanel('Parent',handles.main,'Title','Load olfactometer odors file',...
    'FontSize',8,'TitlePosition','righttop',...
    'Units','pixels','Position',panelPosition); % 'Position',[x y width height]

% Find button to search hard drive for olfactometerOdors file.
% Define position:
buttonPosition(3) = 50; % pushButtonWidth
buttonPosition(4) = 25; % pushButtonHeight
buttonPosition(1) = 5;
buttonPosition(2) = 5;
% Set up the push button:
handles.sessionNotes.pushButton = uicontrol('Parent',handles.fileSelection.panel,'Style','togglebutton',...
    'String','Find','Units','pixels','Position',buttonPosition,'Callback',@findCallback);

% Find button to search hard drive for olfactometerOdors file.
% Define position:
buttonPosition(3) = 50; % pushButtonWidth
buttonPosition(4) = 25; % pushButtonHeight
buttonPosition(1) = 60;
buttonPosition(2) = 5;
% Set up the push button:
handles.sessionNotes.pushButton = uicontrol('Parent',handles.fileSelection.panel,'Style','togglebutton',...
    'String','Load','Units','pixels','Position',buttonPosition,'Callback',@loadCallback);

% Edit field for the path
editFieldPosition = [5 buttonPosition(2)+buttonPosition(4)+5 panelPosition(3)-10 25];
handles.olfactometerOdorFilePath = uicontrol('Parent',handles.fileSelection.panel,'Style','edit',...
    'String','','Units','pixels','Position',editFieldPosition);


%% Set up the "add olfactometer odor table" and "add mixture table" buttons

width = 60;
height = 40;
spacing = 10;
pushButtonPosition = [spacing spacing width height];
handles.goButton = uicontrol('Parent',handles.main,...
    'Style','Pushbutton','String','Go', 'Tag','go',...
    'Callback',{@goCallback, handles},'Position',pushButtonPosition);

pushButtonPosition = [spacing spacing*2+height width height];
handles.saveButton = uicontrol('Parent',handles.main,...
    'Style','Pushbutton','String','Save', 'Tag','save',...
    'Callback',@saveCallback,'Position',pushButtonPosition);

pushButtonPosition = [spacing spacing*3+height*2 width height];

handles.addMixtureTableButton = uicontrol('Parent',handles.main,...
    'Style','Pushbutton','String','Add mix table', 'Tag','addMixtureTable',...
    'Callback',@addMixtureTable,'Position',pushButtonPosition);

pushButtonPosition = [spacing spacing*4+height*3 width height];
handles.addOlfactometerOdorTableButton = uicontrol('Parent',handles.main,...
    'Style','Pushbutton','String','Add table', 'Tag','addOdorTable',...
    'Callback',@addOdorTableForSlave,'Position',pushButtonPosition);

% Write updated handles to gui appdata
appdataManager('odorSelectionGui','set',handles);
appdataManager('odorSelectionGui','set',numberOfVialsPerSlave);


%% Set up the olfactometer odor tables for the default number of slaves 

for i = 1 : numberOfSlavesTables
    addOdorTableForSlave();
end

%%
% UIWAIT makes odorSelectionGui wait for user response (see UIRESUME)
uiwait(handles.main);

%% Extract the data from the gui and 

% Check whether the gui still exists. If it has been closed by the user
% don't try to extract
if ishandle(handles.main) % 
    olfactometerOdors = extractSlaveDataFromGui();
    olfactometerOdors = extractMixtureDataFromGui([],[],olfactometerOdors);
else 
    olfactometerOdors = [];
end

%% Close the gui

% Check whether the gui still exists. If it has been closed by the user
% don't try to close it again
if ishandle(handles.main)
    delete(handles.main)
end

end


%% SUBFUNCTIONS

function addOdorTableForSlave(~,~)
% This will add a table for describing which odorant is in which position
% in a slave module of the olfactometer.

handles = appdataManager('odorSelectionGui','get','handles');
numberOfVialsPerSlave = appdataManager('odorSelectionGui','get','numberOfVialsPerSlave');
%% Figure out which slave we have to set up

% See how many slaves we already have and set up a new one
if isfield(handles,'olfactometerOdorTableSlave')
    slaveNum = length(handles.olfactometerOdorTableSlave);
    slaveNum = slaveNum+1;
    position = get(handles.olfactometerOdorTableSlave(end).panel,'Position');
    width = position(3);
    height = position(4);
else
    slaveNum = 1;
    width = 200;
    height = 300;
end
    
%% Set up the gui components for the slave table

% Set up the panel
spacing = 5;
panelPosition(1) = width * (slaveNum-1) + spacing * (slaveNum-1) + spacing;
panelPosition(2) = 5;
panelPosition(3) = width;
panelPosition(4) = height;
handles.olfactometerOdorTableSlave(slaveNum).panel = uipanel('Parent',handles.main,...
    'Title',['Odorants in Slave #' num2str(slaveNum)],'tag',['slaveTablePanel' num2str(slaveNum)],...
    'Units','pixels','Position',panelPosition);

%% Set up the table and populate with data

handles.olfactometerOdorTableSlave(slaveNum).table = uitable('Parent',handles.olfactometerOdorTableSlave(slaveNum).panel,...
    'tag',['olfactometerOdorTable' num2str(slaveNum)],'Fontsize',10);

odorLibrary=odorLibraryGenerator; % load the odor database
popUpMenuOdors = {odorLibrary.odorName}; % List for the popupmenu
columnFormat = {'logical','numeric',popUpMenuOdors,'numeric','numeric'};
columnName =   {'Present', 'Vial', 'Odor','Dilution','Concentration'};
columnEditable = [true false true true true];
columnWidth = {40, 25, 95, 60,60};
set(handles.olfactometerOdorTableSlave(slaveNum).table, 'ColumnFormat',columnFormat, ...
    'ColumnName',columnName,'ColumnEditable',columnEditable, 'ColumnWidth', columnWidth, ...
    'CellEditCallback',@updateOlfactometerTable);
tableData = cell(numberOfVialsPerSlave,4);
for i = 1 : numberOfVialsPerSlave
    tableData{i,1} = false;
    tableData{i,2} = i;
    tableData{i,3} = '';
end
set(handles.olfactometerOdorTableSlave(slaveNum).table,'Data',tableData);

%% Reorder gui components

tableExtent = get(handles.olfactometerOdorTableSlave(slaveNum).table,'Extent');
spacing = 3;
tablePosition = tableExtent + [spacing spacing 0 0];
set(handles.olfactometerOdorTableSlave(slaveNum).table,'Position',tablePosition);

% Relocate position of panel
panelPosition = [panelPosition(1:2) tableExtent(3)+(spacing*3) tableExtent(4)+(spacing*2)+10];
set(handles.olfactometerOdorTableSlave(slaveNum).panel,'Position',panelPosition);

% Relocate olfactometer mixture table if it exists
if isfield(handles,'olfactometerMixtureTable')
    % Calculate new position for mixture table
    mixturePanelPosition = get(handles.olfactometerMixtureTable.panel,'Position');
    mixturePanelPosition(1) = panelPosition(1) + panelPosition(3) + 5;
    % Relocate position of panel
    set(handles.olfactometerMixtureTable.panel,'Position',mixturePanelPosition);
end

% Relocate Add Panel buttons and save & go button
if isfield(handles,'olfactometerMixtureTable')
    panelPosition = get(handles.olfactometerMixtureTable.panel,'Position');
else
    panelPosition = get(handles.olfactometerOdorTableSlave(end).panel,'Position');
end
spacing = 10;
% Move all buttons
buttonHandles = [handles.saveButton handles.goButton handles.addMixtureTableButton handles.addOlfactometerOdorTableButton];
for i = 1 : length(buttonHandles)
    buttonPosition = get(buttonHandles(i),'Position');
    buttonPosition(1) = panelPosition(1) + panelPosition(3) + spacing;
    set(buttonHandles(i),'Position',buttonPosition);
end

% Update the size of the figure
% Set the width of the main gui:
width = buttonPosition(1) + buttonPosition(3) + 10;
guiPosition = get(handles.main,'Position');
guiPosition(3) = width;
set(handles.main,'Position',guiPosition);

% Set the y position of the file selection panel
height = panelPosition(2) + panelPosition(4) + 10;
filePanelPosition = get(handles.fileSelection.panel,'Position');
filePanelPosition(2) = height;
set(handles.fileSelection.panel,'Position',filePanelPosition);

% Set the height of the main gui
height = filePanelPosition(2) + filePanelPosition(4) + 10;
guiPosition = get(handles.main,'Position');
guiPosition(4) = height;
set(handles.main,'Position',guiPosition);


%% Write updated handles to gui appdata
appdataManager('odorSelectionGui','set',handles);
end


function addMixtureTable(~,~)
% Add the table for defining the mixtures

handles = appdataManager('odorSelectionGui','get','handles');
%% See whether mixture table already exists

% See how many slaves we already have and set up a new one
if isfield(handles,'olfactometerMixtureTable')
    disp('There is already one mixture table present.')
    return
else % No mixture table is present 
    % Variable called slaveNum, but just means the # of table.
    slaveNum = length(handles.olfactometerOdorTableSlave);
    slaveNum = slaveNum+1;
    position = get(handles.olfactometerOdorTableSlave(end).panel,'Position');
    width = position(3);
    height = position(4);
end
    
%% Set up the gui components for the slave table

% Set up the panel
spacing = 5;
panelPosition(1) = width * (slaveNum-1) + spacing * (slaveNum-1) + spacing;
panelPosition(2) = 5;
panelPosition(3) = width;
panelPosition(4) = height;
handles.olfactometerMixtureTable.panel = uipanel('Parent',handles.main,...
    'Title',['Mixtures to present' num2str(slaveNum)],'tag','mixtureTablePanel',...
    'Units','pixels','Position',panelPosition);

%% Set up the table and populate with data

handles.olfactometerMixtureTable.table = uitable('Parent',handles.olfactometerMixtureTable.panel,...
    'tag','mixtureTable','Fontsize',10);

% Defining mixtures
vials = {'1' '2' '3' '4' '5' '6' '7' '8' '9'};
columnFormat = {'logical','numeric',vials,'numeric',vials,'numeric'};
columnName =   {'Present','Mix', 'S1 vial', 'Conc', 'S2 vial','Conc'};
columnEditable = [true false true true true true];
columnWidth = {25, 23, 40, 45, 40, 45};
set(handles.olfactometerMixtureTable.table, 'ColumnFormat',columnFormat, ...
    'ColumnName',columnName,'ColumnEditable',columnEditable, 'ColumnWidth', columnWidth, ...
    'CellEditCallback',@(x,y) updatedOdorMixtureTable(x,y,handles));

tableData = cell(50,6);
for i = 1 : 50
    tableData{i,1} = false;
    tableData{i,2} = i;
%     tableData{i,3} = '';
end
set(handles.olfactometerMixtureTable.table,'Data',tableData)

%% Reorder panel and figure

tableExtent = get(handles.olfactometerMixtureTable.table,'Extent');
odorTableExtent = get(handles.olfactometerOdorTableSlave(end).table,'Extent');
spacing = 3;
tablePosition(1:3) = tableExtent(1:3) + [spacing spacing 15];
tablePosition(4) = odorTableExtent(4);
set(handles.olfactometerMixtureTable.table,'Position',tablePosition);

% Relocate position of panel
panelPosition = [panelPosition(1:2) tablePosition(3)+(spacing*3) tablePosition(4)+(spacing*2)+10];
set(handles.olfactometerMixtureTable.panel,'Position',panelPosition);

% Relocate Add Panel buttons and save & go button
panelPosition = get(handles.olfactometerMixtureTable.panel,'Position');
spacing = 10;
% Move all buttons
buttonHandles = [handles.saveButton handles.goButton handles.addMixtureTableButton handles.addOlfactometerOdorTableButton];
for i = 1 : length(buttonHandles)
    buttonPosition = get(buttonHandles(i),'Position');
    buttonPosition(1) = panelPosition(1) + panelPosition(3) + spacing;
    set(buttonHandles(i),'Position',buttonPosition);
end

% Update the size of the figure
% Set the width of the main gui:
width = buttonPosition(1) + buttonPosition(3) + 10;
guiPosition = get(handles.main,'Position');
guiPosition(3) = width;
set(handles.main,'Position',guiPosition);

% Set the y position of the file selection panel
height = panelPosition(2) + panelPosition(4) + 10;
filePanelPosition = get(handles.fileSelection.panel,'Position');
filePanelPosition(2) = height;
set(handles.fileSelection.panel,'Position',filePanelPosition);

% Set the height of the main gui
height = filePanelPosition(2) + filePanelPosition(4) + 10;
guiPosition = get(handles.main,'Position');
guiPosition(4) = height;
set(handles.main,'Position',guiPosition);


%% Write updated handles to gui appdata
appdataManager('odorSelectionGui','set',handles)

end

function olfactometerOdors = extractSlaveDataFromGui(~,~)

handles = appdataManager('odorSelectionGui','get','handles');

%% 

for i = 1 : length(handles.olfactometerOdorTableSlave)
    olfactometerOdors.slave(i) = struct('used',[],'slaveTable',[]); % set up data structure which contains information what's loaded in olfactometer modules and which odor/mixture to present
    olfactometerOdors.slave(i).slaveTable = get(handles.olfactometerOdorTableSlave(i).table,'Data'); % extract all data from table
end
    
for i = 1 : length(olfactometerOdors.slave) % go through slaves
    present{i} = [olfactometerOdors.slave(i).slaveTable{:,1}]'; % extract 'Present' column - whether to present odor or not
    olfactometerOdors.slave(i).used = sum(present{i}) > 0.5; % see whether any vial is selected as to 'Present', if nothing to present, slave is not used
end

% For loop checks whether for every vial where 'Present' is chosen, also an
% odor is defined:
for j = 1 : length(olfactometerOdors.slave)
    tmp=size(olfactometerOdors.slave(j).slaveTable);
    for i = 1 : tmp(1) % go through every row of the table (ie every vial)
        if olfactometerOdors.slave(j).slaveTable{i,1}  && isempty(olfactometerOdors.slave(j).slaveTable{i,3})
            error(['In olfactometer slave ' num2str(j) 'no odor is defined in vial ' num2str(i) '. Please resolve, then save.'])
        end
    end
end

% Load data
odorLibrary = odorLibraryGenerator;
for i = 1 : length(odorLibrary)
   odorLibrary(i).slave = []; 
   odorLibrary(i).vial = [];
   odorLibrary(i).mixture = [];
end

% Go through every slave and create the sessionOdors field, which contains
% all odors which were chosen to be used.
for i = 1 : length(olfactometerOdors.slave)
    if olfactometerOdors.slave(i).used
        odorsToPresent = olfactometerOdors.slave(i).slaveTable(present{i},3); % odorsToPresent - odors which have been checked to present in the gui
        
        vial = [olfactometerOdors.slave(i).slaveTable{present{i},2}];
        odorantDilution = [olfactometerOdors.slave(i).slaveTable{present{i},4}];
        concentrationAtPresentation = [olfactometerOdors.slave(i).slaveTable{present{i},5}];
        
        for j = 1 : length(odorsToPresent)
            % find odorsToPresent in odorLibrary
            for k = 1 : length(odorLibrary)
                index(k) = ~isempty(strmatch(odorsToPresent{j},odorLibrary(k).odorName,'exact'));
            end
            index = logical(index);
            
            olfactometerOdors.slave(i).sessionOdors(j) = odorLibrary(index);
            olfactometerOdors.slave(i).sessionOdors(j).slave = i;
            olfactometerOdors.slave(i).sessionOdors(j).vial = vial(j);
            olfactometerOdors.slave(i).sessionOdors(j).odorantDilution = odorantDilution(j);
            olfactometerOdors.slave(i).sessionOdors(j).concentrationAtPresentation = concentrationAtPresentation(j);
            olfactometerOdors.slave(i).sessionOdors(j).mixture = logical(0);
%             olfactometerOdors.slave(i).sessionOdors(j).sessionOdorNumber = [];

            clear index;
        end
        
    end
    
end

% Concatenate odors from different slaves into one field
% olfactometerOdors.sessionOdors:
olfactometerOdors.sessionOdors = [];
try
    for i = 1 : length(olfactometerOdors.slave)
        olfactometerOdors.sessionOdors = [olfactometerOdors.sessionOdors olfactometerOdors.slave(i).sessionOdors];
    end
catch
    warning('No odors were chosen to be presented.')
end
end


function olfactometerOdors = extractMixtureDataFromGui(hObject,eventdata,olfactometerOdors)
% This function is written specifically for the table structure of the slave gui.
% It looks at columns of the tables by their number not names.
% To do:
% - index into columns by names so code becomes more general. Also
% - make more general for it to be able to handle more than two slaves.
% - Don't know whether the code will work if there are say three slaves,
% but mixtures are drawn only from slave 1 and 3

handles = appdataManager('odorSelectionGui','get','handles');

% If no mixture table is set up return from the function without updating
% olfactometerOdors.
if ~isfield(handles,'olfactometerMixtureTable')
    olfactometerOdors.mixtures.used = false;
    return
end

%%

olfactometerOdors.mixtures = struct('used',[],'mixtureTable',[]); % set up data structure which contains information about mixtures

% Mixtures
olfactometerOdors.mixtures.mixtureTable = get(handles.olfactometerMixtureTable.table,'Data');
present = [olfactometerOdors.mixtures.mixtureTable{:,1}]'; % extract 'Present' column - whether to present odor or not
olfactometerOdors.mixtures.used = sum(present) > 0.5; % see whether any mixture is selected as to 'Present', if nothing to present, mixtures are not used
if olfactometerOdors.mixtures.used
    disp('Mixtures of odors are used.')
else
    disp('No mixtures of odors are used.')
end

% Check whether all necessary information for a mixture was entered
for i = 1 : length(olfactometerOdors.mixtures.mixtureTable) % go through every row ofmixture table
    mixtureToPresent = olfactometerOdors.mixtures.mixtureTable{i,1}; % extract whether mixture is marked to be presented
    vial1Unspecified = isempty(olfactometerOdors.mixtures.mixtureTable{i,3}); % extract whether vial 1 information was entered
    concentration1Unspecified = isempty(olfactometerOdors.mixtures.mixtureTable{i,4});  % extract whether concentration 1 was entered
    vial2Unspecified = isempty(olfactometerOdors.mixtures.mixtureTable{i,5}); % extract whether vial 2 information was entered
    concentration2Unspecified = isempty(olfactometerOdors.mixtures.mixtureTable{i,6});% extract whether concentration 2 was entered
    % if mixture was selected to be presented but any of the necessary
    % information was not entered, give an error.
    if  mixtureToPresent && (vial1Unspecified || concentration1Unspecified ||  vial2Unspecified || concentration2Unspecified)
        error(['Mixture in row ' num2str(i) ' was marked to be presented. Please specify all necessary information.'])
    end
end
clear concentration1Unspecified; clear concentration2Unspecified;
clear vial1Unspecified; clear vial2Unspecified; clear mixtureToPresent

mixtureIndex = find(present); % index in which row of the mixtures table the to be presented mixtures are entered
clear present;
odorLibrary = odorLibraryGenerator;
for i = 1 : length(odorLibrary)
    odorLibrary(i).slave = [];
    odorLibrary(i).vial = [];
    odorLibrary(i).mixture = [];
end

%
for i = 1 : length(mixtureIndex) % go through every mixture that was marked to present in table
    fieldNames = fieldnames(odorLibrary);
    olfactometerOdors.mixtures.sessionOdors(i) = cell2struct(cell(1,length(fieldNames)),fieldNames,2); % set up structure
%     olfactometerOdors.mixtures.sessionOdors(i).sessionOdorNumber = [];
    
    for j = 1 : length(olfactometerOdors.slave) % go through the slaves
        columnNames = get(handles.olfactometerMixtureTable.table,'ColumnName'); % extract column names, general approach
        slaveColumnName = ['S' num2str(j) ' vial']; % create string that is the name of the column in the table that specifies the vial of the slave
        for k = 1 : length(columnNames)
            currentSlaveColumnIndex(k) = ~isempty(strmatch(slaveColumnName,columnNames{k},'exact')); % gives an index which column specifies the vial of the current slave
        end
        currentSlaveColumnIndex = find(currentSlaveColumnIndex);
        currentSlaveVial = olfactometerOdors.mixtures.mixtureTable{mixtureIndex(i),currentSlaveColumnIndex}; % extract the specified number of vial in the current slave
        currentSlaveOdorName = olfactometerOdors.slave(j).slaveTable(currentSlaveVial,3); % not general: indexing by number 3 instead of column name
        clear currentSlaveColumnIndex; clear slaveColumnName;
        
        % Find the odor in the odorLibrary
        for k = 1 : length(odorLibrary)
            currentOdorLibraryIndex(k) = ~isempty(strmatch(currentSlaveOdorName,odorLibrary(k).odorName,'exact'));
        end
        currentOdorLibraryIndex = find(currentOdorLibraryIndex);
        
        
        
        % Extract data from the odor library
        for k = 1 : length(fieldnames(odorLibrary)) % go through each field of odorLibrary structure
            if j == 1 % for the first slave overwrite values in olfactometerOdors.mixtures.sessionOdors
                currentSlaveFieldEntry = getfield(odorLibrary(currentOdorLibraryIndex),fieldNames{k});
                
                newFieldEntry = {currentSlaveFieldEntry}; % make current field into a cell

                olfactometerOdors.mixtures.sessionOdors(i) = setfield(olfactometerOdors.mixtures.sessionOdors(i),fieldNames{k},newFieldEntry); % write new field entry into field
                
                
            else % for all following slaves
                fieldEntry = getfield(olfactometerOdors.mixtures.sessionOdors(i),fieldNames{k});
                currentSlaveFieldEntry = getfield(odorLibrary(currentOdorLibraryIndex),fieldNames{k});
                currentSlaveFieldEntry = {currentSlaveFieldEntry};% make current field into a cell
                newFieldEntry = [fieldEntry currentSlaveFieldEntry];% concatenenate cells into cell array
                
                olfactometerOdors.mixtures.sessionOdors(i) = setfield(olfactometerOdors.mixtures.sessionOdors(i),fieldNames{k},newFieldEntry); % write new field entry into field
            end
        end
        clear fieldEntry;clear currentSlaveFieldEntry;clear newFieldEntry;
        
        olfactometerOdors.mixtures.sessionOdors(i).slave{j} = j; % update
        olfactometerOdors.mixtures.sessionOdors(i).vial{j} = currentSlaveVial;
        olfactometerOdors.mixtures.sessionOdors(i).odorantDilution{j} = olfactometerOdors.slave(j).slaveTable{currentSlaveVial,4}; % not general - 4 refers to column by number not by name
        
        for k = 1 : length(columnNames)
            concentrationColumnIndex(k) = ~isempty(strmatch('Conc',columnNames{k},'exact')); % gives an index which column specifies the concentration of the odors
        end
        concentrationColumnIndex = find(concentrationColumnIndex); % get numbers of columns which are called 'Conc'
        currentConcentrationColumnIndex = concentrationColumnIndex(j); % Get the index of the column which is defines conc for the current slave
        olfactometerOdors.mixtures.sessionOdors(i).concentrationAtPresentation{j} = olfactometerOdors.mixtures.mixtureTable{mixtureIndex(i),currentConcentrationColumnIndex}; % extract the concentration as set in the mixture table for the current odor and write it into the olfactometerOdors structure
        
        olfactometerOdors.mixtures.sessionOdors(i).mixture = logical(1);
        clear currentSlaveColumnIndex; clear currentOdorLibraryIndex;
        clear concentrationColumnIndex; clear columnNames; clear currentSlaveVial;
        clear currentConcentrationColumnIndex; clear currentSlaveOdorName
    end
end



try
    
    olfactometerOdors.sessionOdors = [olfactometerOdors.sessionOdors olfactometerOdors.mixtures.sessionOdors];
    
catch
    disp('No mixtures were chosen to be presented.')
end
end


function findCallback(hObject, eventdata)
% Callback for clicking the find button to get olfactometerOdors file

handles = appdataManager('odorSelectionGui','get','handles');

callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function
olfStimPath = which(callingFunctionName);
olfStimPath(length(olfStimPath)-length(callingFunctionName):length(olfStimPath))=[];
olfStimPath = [olfStimPath filesep 'User Data' filesep 'olfactometerOdors'];
[fileName,pathName,filterIndex] = uigetfile([olfStimPath filesep '*.mat'],'Select a .mat file, specifying the odors in the olfactometer.');
if fileName == 0
    return
end
set(handles.olfactometerOdorFilePath,'String', [pathName fileName])
loadCallback();
end


function loadCallback(hObject, eventdata)
% Callback for clicking the load button to load olfactometerOdors file and
% populate the tables

handles = appdataManager('odorSelectionGui','get','handles');

path = get(handles.olfactometerOdorFilePath,'String');
load(path);

%% Check whether we have enough odorant tables on the gui for the data
% If not set up new ones
numberOfSlaveTables = length(handles.olfactometerOdorTableSlave);
numberOfSlaves = find(1==[olfactometerOdors.slave.used]);
numberOfSlaves = max(numberOfSlaves);

if numberOfSlaves > numberOfSlaveTables
    missingNumberOfSlaveTables = numberOfSlaves - numberOfSlaveTables;
    for i = 1 : missingNumberOfSlaveTables
        addOdorTableForSlave();
    end
end


%% Check whether we need/have a mixture table
% If not set it up

if isfield(olfactometerOdors,'mixtures')
    if olfactometerOdors.mixtures.used
        if ~isfield(handles,'olfactometerMixtureTable')
            addMixtureTable();
        end
    end
end


%% Write updated handles to gui appdata
handles = appdataManager('odorSelectionGui','get','handles');

%% Populate the odor tables for all slaves

for i = 1 : length(find([olfactometerOdors.slave.used]))
    set(handles.olfactometerOdorTableSlave(i).table, 'Data', olfactometerOdors.slave(i).slaveTable);
end

%% Populate the mixture table
if olfactometerOdors.mixtures.used
    set(handles.olfactometerMixtureTable.table, 'Data', olfactometerOdors.mixtures.mixtureTable);
end
end

function populateOlfactometerTable()

end

function populateMixtureTable()

end

function updateOlfactometerTable(varargin)
% If an odor is chosen from the popup menu, find the odorant in the odor
% library and update the fields in the row from the database.

editInformation = varargin{2}; % includes information which cell was edited
tableHandle = varargin{1}; % the handle of the table in which cell was edited
tableData = get(tableHandle,'Data'); % extract the data currently in the table
if editInformation.Indices(2) == 3 % if column 3 (name of the odor) was changed do the following commands
    editedOdor = editInformation.NewData; % extract odor name of the edited odor
    odorLibrary=odorLibraryGenerator; % load the odor library
    odors = {odorLibrary.odorName}; % create a cell array containing all popular odor names within the library
    odorLibraryIndex = strmatch(editedOdor, odors,'exact'); % find the index 
    tableData{editInformation.Indices(1),4} = odorLibrary(odorLibraryIndex).odorantDilution;
    tableData{editInformation.Indices(1),5} = odorLibrary(odorLibraryIndex).concentrationAtPresentation;
    set(tableHandle, 'Data', tableData);
end
end

function updatedOdorMixtureTable(tableHandle,editInformation,handles)
% Checks whether the selected vials to use in mixtures were d
% function is defined when setting up the gui, see line 97. I define which
% inputs the function gets. 
% editInformation is a structure which includes information which cell was edited
% tableHandle is the handle of the table in which cell was edited
% handles includes all handles of the gui
editedVial = editInformation.NewData; % extract vial number of the edited vial
if editInformation.Indices(2) == 3 % if column 3 (number of Vial in Slave1) was changed do the following commands
    tableData = get(handles.olfactometerOdorTableSlave1,'Data'); % extract the data currently in the slave 1 table
    if isempty(tableData{editedVial,3})
        errordlg('Specify the odor in the selected vial of olfactometer slave 1')
        updatedMixtureTable = get(handles.olfactometerMixtureTable,'Data');
        updatedMixtureTable{editInformation.Indices(1),editInformation.Indices(2)} = [];
        set(handles.olfactometerMixtureTable,'Data',updatedMixtureTable);
    end
elseif editInformation.Indices(2) == 5 % if column 5 (number of Vial in Slave2) was changed do the following commands
    tableData = get(handles.olfactometerOdorTableSlave2,'Data'); % extract the data currently in the slave 2 table
    if isempty(tableData{editedVial,3})
        errordlg('Specify the odor in the selected vial of olfactometer slave 2')
        updatedMixtureTable = get(handles.olfactometerMixtureTable,'Data');
        updatedMixtureTable{editInformation.Indices(1),editInformation.Indices(2)} = [];
        set(handles.olfactometerMixtureTable,'Data',updatedMixtureTable);
    end
    
end
end

function saveCallback(hObject, eventdata,fhandles) % add fhandles to inputs in order to access other subfunctions within this script

% Get newest handles:
handles = appdataManager('odorSelectionGui','get','handles');

%%
olfactometerOdors = extractSlaveDataFromGui(hObject,eventdata);

% mixtureTable = get(handles.olfactometerMixtureTable,'Data');
% present = [mixtureTable{:,1}]'; % extract 'Present' column - whether to present odor or not
% mixturesUsed = sum(present) > 0.5; % see whether any mixture is selected as to 'Present', if nothing to present, mixtures are not used
% if mixturesUsed
    olfactometerOdors = extractMixtureDataFromGui(hObject,eventdata,olfactometerOdors);
% end
for i = 1 : length(olfactometerOdors.sessionOdors) % Hacked! At some point add the field nicely in the subfunctions
        olfactometerOdors.sessionOdors(i).sessionOdorNumber = i;
end
defaultTitle = [datestr(date,'yyyy.mm.dd') '_olfactometerOdors.mat'];

% Open olfStim directory
callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function
olfStimPath = which(callingFunctionName);
olfStimPath(length(olfStimPath)-length(callingFunctionName):length(olfStimPath))=[];
extendedPath = [olfStimPath filesep 'User Data' filesep 'olfactometerOdors' filesep]
[filename,pathname]=uiputfile('*.mat','Save olfactometer odors',[extendedPath defaultTitle]);
if ischar(filename) && ischar(pathname) % only if filename and path specified
    extendedPath = [pathname filename];
    save(extendedPath,'olfactometerOdors')
else
    disp('To save the olfactometer odors please select a filename and path.')
end
end

function goCallback(hObject, eventdata, handles)
uiresume(handles.main);
end