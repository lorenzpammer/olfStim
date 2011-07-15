
function varargout = odorSelectionGui(varargin)
% ODORSELECTIONGUI M-file for odorSelectionGui.fig
%      ODORSELECTIONGUI, by itself, creates a new ODORSELECTIONGUI or raises the existing
%      singleton*.
%
%      H = ODORSELECTIONGUI returns the handle to a new ODORSELECTIONGUI or
%      the handle to
%      the existing singleton*.
%
%      ODORSELECTIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ODORSELECTIONGUI.M with the given input arguments.
%
%      ODORSELECTIONGUI('Property','Value',...) creates a new ODORSELECTIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before odorSelectionGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to odorSelectionGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help odorSelectionGui

% Last Modified by GUIDE v2.5 10-Jul-2011 16:02:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @odorSelectionGui_OpeningFcn, ...
                   'gui_OutputFcn',  @odorSelectionGui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before odorSelectionGui is made visible.
function odorSelectionGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to odorSelectionGui (see VARARGIN)

% Choose default command line output for odorSelectionGui
handles.output = hObject;

% UpdateSlave1 handles structure
guidata(hObject, handles);


% Following commands of this function set up the gui corectly:

% Define the olfactometer tables for the two olfactometer slaves
odorLibrary=odorLibraryGenerator;
popUpMenuOdors = {odorLibrary.odorName};
%columnDefinition = {'logical','numeric',[{'popupmenuChoice1'} {'popupmenuChoice1'}],'numeric','numeric'}
columnFormat = {'logical','numeric',popUpMenuOdors,'numeric','numeric'};
columnName =   {'Present', 'Vial', 'Odor','Dilution','Concentration'};
columnEditable = [true false true true true];
columnWidth = {40, 25, 95, 60,60};
set(handles.olfactometerOdorTableSlave1, 'ColumnFormat',columnFormat, ...
    'ColumnName',columnName,'ColumnEditable',columnEditable, 'ColumnWidth', columnWidth, ...
    'CellEditCallback',@updateOlfactometerTable)
set(handles.olfactometerOdorTableSlave2, 'ColumnFormat',columnFormat, ...
    'ColumnName',columnName,'ColumnEditable',columnEditable, 'ColumnWidth', columnWidth, ...
    'CellEditCallback',@updateOlfactometerTable)
tableData = cell(9,4);
for i = 1 : 9
    tableData{i,1} = logical(0);
    tableData{i,2} = i;
    tableData{i,3} = '';
end
set(handles.olfactometerOdorTableSlave1,'Data',tableData)
set(handles.olfactometerOdorTableSlave2,'Data',tableData)

% Defining mixtures
vials = {'1' '2' '3' '4' '5' '6' '7' '8' '9'};
columnFormat = {'logical','numeric',vials,'numeric',vials,'numeric'};
columnName =   {'Present','Mix', 'S1 vial', 'Conc', 'S2 vial','Conc'};
columnEditable = [true false true true true true];
columnWidth = {25, 23, 40, 45, 40, 45};
set(handles.olfactometerMixtureTable, 'ColumnFormat',columnFormat, ...
    'ColumnName',columnName,'ColumnEditable',columnEditable, 'ColumnWidth', columnWidth, ...
    'CellEditCallback',@(x,y) updatedOdorMixtureTable(x,y,handles));

tableData = cell(50,6);
for i = 1 : 50
    tableData{i,1} = logical(0);
    tableData{i,2} = i;
%     tableData{i,3} = '';
end
set(handles.olfactometerMixtureTable,'Data',tableData)


% UIWAIT makes odorSelectionGui wait for user response (see UIRESUME)
uiwait(handles.odorSelectionGui);


%%

% --- Outputs from this function are returned to the command line.
function varargout = odorSelectionGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    
    olfactometerOdors = extractSlaveDataFromGui(hObject,eventdata,handles); % extracts information entered into 2 slave tables
    
    mixtureTable = get(handles.olfactometerMixtureTable,'Data');
    present = [mixtureTable{:,1}]'; % extract 'Present' column - whether to present odor or not
    mixturesUsed = sum(present) > 0.5; % see whether any mixture is selected as to 'Present', if nothing to present, mixtures are not used
    if mixturesUsed
        olfactometerOdors = extractMixtureDataFromGui(hObject,eventdata,handles,olfactometerOdors);
    end
    varargout{1} = olfactometerOdors; % define output of the gui
    
    odorSelectionGui_CloseRequestFcn(hObject, eventdata, handles);





function olfactometerOdorFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to olfactometerOdorFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of olfactometerOdorFilePath as text
%        str2double(get(hObject,'String')) returns contents of olfactometerOdorFilePath as a double


% --- Executes during object creation, after setting all properties.
function olfactometerOdorFilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to olfactometerOdorFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Find.
function Find_Callback(hObject, eventdata, handles)
% hObject    handle to Find (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,pathName,filterIndex] = uigetfile('.mat','Select a .mat file, specifying the odors in the olfactometer.');
set(handles.olfactometerOdorFilePath,'String', [pathName fileName])


% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = get(handles.olfactometerOdorFilePath,'String');
load(path);
set(handles.olfactometerOdorTableSlave1, 'Data', olfactometerOdors.slave(1).slaveTable);
set(handles.olfactometerOdorTableSlave2, 'Data', olfactometerOdors.slave(2).slaveTable);
set(handles.olfactometerMixtureTable, 'Data', olfactometerOdors.mixtures.mixtureTable);



function updateOlfactometerTable(varargin)
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


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles,fhandles) % add fhandles to inputs in order to access other subfunctions within this script
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
olfactometerOdors = extractSlaveDataFromGui(hObject,eventdata,handles);

mixtureTable = get(handles.olfactometerMixtureTable,'Data');
present = [mixtureTable{:,1}]'; % extract 'Present' column - whether to present odor or not
mixturesUsed = sum(present) > 0.5; % see whether any mixture is selected as to 'Present', if nothing to present, mixtures are not used
if mixturesUsed
olfactometerOdors = extractMixtureDataFromGui(hObject,eventdata,handles,olfactometerOdors);
end
defaultTitle = [datestr(date,'yyyy.mm.dd') '_olfactometerOdors'];
[filename,pathname]=uiputfile('.mat','Save olfactometer odors',defaultTitle);
if ischar(filename) && ischar(pathname) % only if filename and path specified 
extendedPath = [pathname filename];
save(extendedPath,'olfactometerOdors')
else 
    disp('To save the olfactometer odors please select a filename and path.')
end


%columnName = get(handles.olfactometerOdorTableSlave1,'ColumnName');

    

% --- Executes on button press in Go.
function Go_Callback(hObject, eventdata, handles)
% hObject    handle to Go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% olfactometerOdors = extractSlaveDataFromGui(hObject,eventdata,handles); % extracts information entered into 2 slave tables
% 
% mixtureTable = get(handles.olfactometerMixtureTable,'Data');
% present = [mixtureTable{:,1}]'; % extract 'Present' column - whether to present odor or not
% mixturesUsed = sum(present) > 0.5; % see whether any mixture is selected as to 'Present', if nothing to present, mixtures are not used
% if mixturesUsed
% olfactometerOdors = extractMixtureDataFromGui(hObject,eventdata,handles,olfactometerOdors);
% end
% 
% eventdata.go = 1;
% eventdata.olfactometerOdors = olfactometerOdors;
% odorSelectionGui_OutputFcn(hObject, eventdata, handles) 

uiresume(handles.odorSelectionGui);







function olfactometerOdors = extractSlaveDataFromGui(hObject,eventdata,handles)
% This function is written specifically for the table structure of the slave gui.
% It looks at columns of the tables by their number not names. 
% To do: 
% - index into columns by names so code becomes more general. Also
% - make more general for it to be able to handle more than two slaves.

olfactometerOdors.slave(1:2) = struct('used',[],'slaveTable',[]); % set up data structure which contains information what's loaded in olfactometer modules and which odor/mixture to present
olfactometerOdors.slave(1).slaveTable = get(handles.olfactometerOdorTableSlave1,'Data'); % extract all data from table
olfactometerOdors.slave(2).slaveTable = get(handles.olfactometerOdorTableSlave2,'Data'); % extract all data from table
for i = 1 : length(olfactometerOdors.slave) % go through slaves
    present{i} = [olfactometerOdors.slave(i).slaveTable{:,1}]'; % extract 'Present' column - whether to present odor or not
    olfactometerOdors.slave(i).used = sum(present{i}) > 0.5; % see whether any vial is selected as to 'Present', if nothing to present, slave is not used
end
if olfactometerOdors.slave(1).used
    disp('Olfactometer Module 1 is used.')
end
if olfactometerOdors.slave(2).used
    disp('Olfactometer Module 2 is used.')
end

% For loop checks whether for every vial where 'Present' is chosen, also an
% odor is defined:
for i = 1 : 9 
   if olfactometerOdors.slave(1).slaveTable{i,1}  && isempty(olfactometerOdors.slave(1).slaveTable{i,3})
       error(['In olfactometer slave 1 no odor is defined in vial ' num2str(i) '. Please resolve, then save.'])
   end
   if  olfactometerOdors.slave(2).slaveTable{i,1} && isempty(olfactometerOdors.slave(2).slaveTable{i,3})
       error(['In olfactometer slave 2 no odor is defined in vial ' num2str(i) '.  Please resolve, then save.'])
   end
end

% 
odorLibrary = odorLibraryGenerator;
for i = 1 : length(odorLibrary)
   odorLibrary(i).slave = []; 
   odorLibrary(i).vial = [];
   odorLibrary(i).mixture = [];
end

for i = 1 : length(olfactometerOdors.slave) % write
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
            clear index;
        end
        
    end
    
end
try
    olfactometerOdors.sessionOdors = [olfactometerOdors.slave(1).sessionOdors olfactometerOdors.slave(2).sessionOdors];
catch
    warning('No odors were chosen to be presented.')
    olfactometerOdors.sessionOdors = []
end



function olfactometerOdors = extractMixtureDataFromGui(hObject,eventdata,handles,olfactometerOdors)
% This function is written specifically for the table structure of the slave gui.
% It looks at columns of the tables by their number not names.
% To do:
% - index into columns by names so code becomes more general. Also
% - make more general for it to be able to handle more than two slaves.
% - Don't know whether the code will work if there are say three slaves,
% but mixtures are drawn only from slave 1 and 3

olfactometerOdors.mixtures = struct('used',[],'mixtureTable',[]); % set up data structure which contains information about mixtures

% Mixtures
olfactometerOdors.mixtures.mixtureTable = get(handles.olfactometerMixtureTable,'Data');
present = [olfactometerOdors.mixtures.mixtureTable{:,1}]'; % extract 'Present' column - whether to present odor or not
olfactometerOdors.mixtures.used = sum(present) > 0.5; % see whether any mixture is selected as to 'Present', if nothing to present, mixtures are not used
if olfactometerOdors.mixtures.used
    disp('Mixtures of odors are used.')
else
    disp('No mixtures of odors are used.')
end

% Check whether all necessary information for a mixture was entered
for i = 1 : length(olfactometerOdors.mixtures.mixtureTable) % go through entire mixture table
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
% This is mostly written in a general way, if specific marked 'not general'
for i = 1 : length(mixtureIndex) % go through every mixture that was marked to present in table
    fieldNames = fieldnames(odorLibrary);
    olfactometerOdors.mixtures.sessionOdors(i) = cell2struct(cell(1,length(fieldNames)),fieldNames,2); % set up structure
    
    for j = 1 : length(olfactometerOdors.slave) % go through the slaves
        columnNames = get(handles.olfactometerMixtureTable,'ColumnName'); % extract column names, general approach
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
    warning('No odors were chosen to be presented.')
end


% --- Executes when user attempts to close odorSelectionGui.
function odorSelectionGui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to odorSelectionGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(handles.odorSelectionGui);
