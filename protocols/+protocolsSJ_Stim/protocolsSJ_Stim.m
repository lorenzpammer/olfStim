function protocolsSJ_Stim

%% Todo
% -loadTrials: Check whether all odors (in the correct concentration
%              are actually present in the odor list
% -deleteTrialDef: Check if trial is being used by one or more
%                  sequences or protocols or in the todo list
% -trial definition: trigger setting is currently ignored
%% Set up needed variables

global smell
global trialNum

olfactometerOdors = smell.olfactometerOdors;
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
stimProtocol = 'protocolsSJ';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up common gui components for all stimulation paradigms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The order of setting up the components is important, because the
% placement of the components is relative to other components.

% 3. End session button
h = quitSession(h); % endSession is a function in the protocolUtilities package. Sets up a functional button to end the session, save the smell structure, disconnect from LASOM etc.

% 2. Notes field
h = notes.setupGui(h); % h = notes.setupGui(h,position);: position is an optional parameter.  sessionNotes is a function in the protocolUtilities package. Sets up a panel with possibilities for note taking

% % 4. Start session button % not necessary for manualStim
% h = startSession(h,'manualSessionProgrammingStim.startSessionCallback');

% 5. Olfactometer Settings
h = olfactometerSettings(h,'setUp'); % sets up all controls the user has over the olfactometer (valve times, MFC flow rates)

% 6. Session Settings
% All controls a user has over session parameters (inter trial interval etc)
h = sessionSettingsPanel(h,0); % sessionSettingsPanel(h,guiEnlarge).
usedSettingNames = {'scientist' 'animalName' 'interTrialInterval'};
h = sessionSettings(h,'setUp',usedSettingNames);
clear usedSettingNames;

% 7. Progress panel
h = progressPanel(h,'setUp'); % progressPanel is a function in the protocolUtilities package

% 8. Pause session button % not necessary for manualStim
% pauseSession; % pauseSession is a function in the protocolUtilities package. Sets up a functional button to pause the session


% Add protocol specific handles"
h.protocolSpecificHandles = [];

%% Reposition GUI elements
% Resize GUI
guiPos = [100 100 400 800];
panelWidth = [225 190];
guiPosLarge = [100 100 panelWidth(1)+3*panelWidth(2)+25 800];

set(h.guiHandle, 'Position', guiPos, 'NumberTitle','off');

% Reposition Stim Protocols panel
oldPos = get(h.panelProtocolChooser, 'Position');
newPos = [5 5];
posDiff = oldPos(1:2)-newPos(1:2);
hdl = [h.popupProtocols h.startWithSelectedProtocol h.staticText.popup h.panelProtocolChooser];
for i=1:numel(hdl)
    oldPos = get(hdl(i),'Position');
    set(hdl(i), 'Position',[oldPos(1:2)-posDiff oldPos(3:4)]);
end
set(h.panelProtocolChooser, 'Position',[5 5 oldPos(3) oldPos(4)-20]);
set(h.startWithSelectedProtocol, 'BackgroundColor',get(h.panelProtocolChooser, 'BackgroundColor'));

% Reposition End session panel
oldPos = get(h.quitSession, 'Position');
newPos = [120 5];
posDiff = oldPos(1:2)-newPos(1:2);
hdl = h.quitSession;
for i=1:numel(hdl)
    oldPos = get(hdl(i),'Position');
    set(hdl(i), 'Position',[oldPos(1:2)-posDiff oldPos(3:4)]);
end
set(h.quitSession, 'BackgroundColor',get(h.panelProtocolChooser, 'BackgroundColor'));
% Reposition Notes panel
oldPos = get(h.sessionNotes.panel, 'Position');
newPos = [120 35];
posDiff = oldPos(1:2)-newPos(1:2);
hdl = [h.sessionNotes.panel h.sessionNotes.pushButton h.sessionNotes.textField];
for i=1:numel(hdl)
    oldPos = get(hdl(i),'Position');
    set(hdl(i), 'Position',[oldPos(1:2)-posDiff oldPos(3:4)]);
end

% Reposition session settings panel
newSize = [panelWidth(1) 50];
set(h.sessionSettings.panel,'Position',[5 guiPos(4)-60 newSize])
newStrings = {'Scientist ID';'Animal ID'};
set(h.sessionSettings.edit, 'BackgroundColor','w');
set([h.sessionSettings.text(1:2) h.sessionSettings.edit(1:2)],'Parent',h.sessionSettings.panel);
for i=1
    set(h.sessionSettings.text(2*i-1), 'Position',[10 newSize(2)-18-i*22 60 20], 'String',newStrings{2*i-1},'HorizontalAlignment','left');
    set(h.sessionSettings.edit(2*i-1), 'Position',[70 newSize(2)-18-i*22 40 20]);
    if ~(2*i>numel(h.sessionSettings.text))
        set(h.sessionSettings.text(2*i), 'Position',[120 newSize(2)-18-i*22 60 20], 'String',newStrings{2*i},'HorizontalAlignment','left');
        set(h.sessionSettings.edit(2*i), 'Position',[175 newSize(2)-18-i*22 40 20]);
    end
end

% Reposition olfactometer settings panel
oldPos = get(h.olfactometerSettings.panel,'Position');
newSize =  [panelWidth(1) 300];
set(h.olfactometerSettings.panel,'Position', [5 guiPos(4)-newSize(2)-70 newSize]);
uicontrol('Style','Text','Parent',h.olfactometerSettings.panel, 'Position',[5 newSize(2)-40 80 20],'String','Valve name', 'FontWeight', 'bold','HorizontalAlignment','left');
uicontrol('Style','Text','Parent',h.olfactometerSettings.panel, 'Position',[90 newSize(2)-40 40 20],'String','On', 'FontWeight', 'bold');
uicontrol('Style','Text','Parent',h.olfactometerSettings.panel, 'Position',[135 newSize(2)-40 40 20],'String','Off', 'FontWeight', 'bold');
uicontrol('Style','Text','Parent',h.olfactometerSettings.panel, 'Position',[175 newSize(2)-40 40 20],'String','Enable', 'FontWeight', 'bold');
newStrings = {'Gating valve'; 'Final valve';'Suction valve';'Sniffing valve';'Humidity valve';'Purge'};
set(h.olfactometerSettings.text,'Parent',h.olfactometerSettings.panel,'HorizontalAlignment','left');
set(h.olfactometerSettings.edit(h.olfactometerSettings.edit>0),'Parent',h.olfactometerSettings.panel);
set(h.olfactometerSettings.check(h.olfactometerSettings.check>0),'Parent',h.olfactometerSettings.panel);
for i=2:6
    set(h.olfactometerSettings.text(2*i-1),'Position',[5 newSize(2)-40-(i-1)*22 80 20]);
    set(h.olfactometerSettings.text(2*i-1),'String',newStrings{i-1});
    set(h.olfactometerSettings.edit(2*i-1),'Position',[90 newSize(2)-40-(i-1)*22 40 20]);
    set(h.olfactometerSettings.edit(2*i),'Position',[135 newSize(2)-40-(i-1)*22 40 20]);
    set(h.olfactometerSettings.check(2*i-1),'Position',[185 newSize(2)-40-(i-1)*22 20 20]);
    set(h.olfactometerSettings.check(2*i-1),'BackgroundColor',get(h.olfactometerSettings.edit(2*i),'BackgroundColor'));
    set(h.olfactometerSettings.edit(2*i-1:2*i),'BackgroundColor','w');
    set(h.olfactometerSettings.text(2*i),'Visible','off')
end
set(h.olfactometerSettings.text(1),'Position',[5 newSize(2)-40-(i+1)*22 80 20], 'String','MFC Flow rate');  % MFC
set(h.olfactometerSettings.edit(1),'Position',[90 newSize(2)-40-(i+1)*22 40 20]); % MFC
set(h.olfactometerSettings.text(2),'Position',[135 newSize(2)-40-(i+1)*22 40 20]); % Purge
set(h.olfactometerSettings.check(2),'Position',[185 newSize(2)-40-(i+1)*22 20 20]); % Purge
set(h.olfactometerSettings.text(13),'Position',[5 newSize(2)-40-(i)*22 80 20]); % Clean nose
set(h.olfactometerSettings.edit(13),'Position',[90 newSize(2)-40-(i)*22 40 20]); % Clean nose
set(h.olfactometerSettings.check(13),'Position',[185 newSize(2)-40-(i)*22 20 20]); % Clean nose
set(h.olfactometerSettings.check(13),'BackgroundColor',get(h.olfactometerSettings.edit(13),'BackgroundColor')); % Clean nose
set(h.olfactometerSettings.edit([1 13]),'BackgroundColor','w');

% Add "wait after" (ie inter trial interval, originally belongs to session
% settings)
set(h.sessionSettings.text(3), 'String', 'Wait (ISI) [s]', 'Parent',h.olfactometerSettings.panel, 'Position',  [5 newSize(2)-40-(i+2)*22 80 20],'HorizontalAlignment','left');
set(h.sessionSettings.edit(3), 'String', '0', 'Parent',h.olfactometerSettings.panel, 'Position',  [90 newSize(2)-40-(i+2)*22 40 20]);

% Add trigger selection
h.olfactometerSettings.text(14) = uicontrol('Style','Text','Parent',h.olfactometerSettings.panel, 'Position',[133 newSize(2)-40-(i+2)*22 48 20], 'String','Triggered','HorizontalAlignment','left');
h.olfactometerSettings.check(14) = uicontrol('Style','checkbox','Parent',h.olfactometerSettings.panel,'Position',[185 newSize(2)-40-(i+2)*22 20 20], 'Value',0);

% Trial sequence button
set(h.olfactometerSettings.trialSeqButton,'Parent',h.olfactometerSettings.panel, 'Position',[5 newSize(2)-40-(i+3)*22 195 20]);

% Add odor selection controls
% Calculate max possible concentration for odor #1 (which will be selected
% in popup menu)
settingNames = get(h.olfactometerSettings.text,'Tag');
settingIndex = strcmp('mfcTotalFlow',settingNames);
totalFlow = str2double(get(h.olfactometerSettings.edit(settingIndex),'String'));
maximumPossibleConcentration = smell.olfactometerSettings.slave(1).maxFlowRateMfcNitrogen / totalFlow * smell.olfactometerOdors.slave(1).sessionOdors(1).odorantDilution;
h.olfactometerSettings.odorTxt = uicontrol('Style','Text','Parent',h.olfactometerSettings.panel,'Position',[5 newSize(2)-47-(i+4)*22 40 20],'String','Odor','HorizontalAlignment','left');
h.olfactometerSettings.odorPop = uicontrol('Style','popupmenu','Parent',h.olfactometerSettings.panel, 'Position',[50 newSize(2)-45-(i+4)*22 105 20],'String',{olfactometerOdors.sessionOdors.odorName},'Callback',@checkConcentration);
h.olfactometerSettings.odorEdt = uicontrol('Style','Edit','Parent',h.olfactometerSettings.panel, 'Position',[160 newSize(2)-47-(i+4)*22 40 20], 'String',num2str(maximumPossibleConcentration,'%6.3f'), 'BackgroundColor','w','Callback',@checkConcentration);

% Add Run controls
h.runControls.runTrialFromSettings = uicontrol('Style','Pushbutton','Parent',h.olfactometerSettings.panel, 'Position',[5 newSize(2)-50-(i+5)*22 70 20], 'String','Run trial','FontWeight','Bold','Callback',@runTrial);
h.protocolControls.addTrial2List = uicontrol('Style','Pushbutton','Parent',h.olfactometerSettings.panel, 'Position',[77 newSize(2)-50-(i+5)*22 70 20], 'String','Create trial','FontWeight','Bold', 'Callback', @newTrialDef);
h.protocolControls.updateCurrTrial = uicontrol('Style','Pushbutton','Parent',h.olfactometerSettings.panel, 'Position',[149 newSize(2)-50-(i+5)*22 70 20], 'String','Update trial','FontWeight','Bold','Callback',@updateTrial);

set([h.progress.panel h.progress.figure], 'Visible','off');

% Trial list
pos = [5 120 panelWidth(1) 300];
sizes.trials = pos;
h.protocolControls.trials.panel = uipanel('Parent',h.guiHandle,'Units','pixel','Position',pos, 'Title','Trial definitions','TitlePosition','centertop');
h.protocolControls.trials.listbox =  uicontrol('Style','listbox','parent',h.protocolControls.trials.panel,'Units','pixel','Position',[5 55 pos(3)-12  pos(4)-70], 'Callback', @updateTrialSelection,'Max',2);
h.protocolControls.trials.run =  uicontrol('Style','pushbutton','parent',h.protocolControls.trials.panel,'Units','pixel','Position',[5 5 50 20], 'String','Run', 'FontWeight','bold','Callback',@runTrial);
h.protocolControls.trials.delete =  uicontrol('Style','pushbutton','parent',h.protocolControls.trials.panel,'Units','pixel','Position',[5 27 50 20], 'String','Delete', 'FontWeight','bold','Callback', @deleteTrialDef,'Enable','off');
h.protocolControls.trials.add2Seq =  uicontrol('Style','pushbutton','parent',h.protocolControls.trials.panel,'Units','pixel','Position',[60 5 50 20], 'String','+Sequ', 'FontWeight','bold','Enable','off','Callback', @addTrial2SeqDef);
h.protocolControls.trials.add2Prot =  uicontrol('Style','pushbutton','parent',h.protocolControls.trials.panel,'Units','pixel','Position',[60 27 50 20], 'String','+Prot', 'FontWeight','bold','Enable','off','Callback', @addTrial2ProtDef);
h.protocolControls.trials.add2Todo =  uicontrol('Style','pushbutton','parent',h.protocolControls.trials.panel,'Units','pixel','Position',[115 27 50 20], 'String','+ToDo', 'FontWeight','bold','Enable','off');
h.protocolControls.trials.rename =  uicontrol('Style','pushbutton','parent',h.protocolControls.trials.panel,'Units','pixel','Position',[115 5 50 20], 'String','Rename', 'FontWeight','bold','Enable','off','Callback',@renameTrial);
h.protocolControls.trials.save=  uicontrol('Style','pushbutton','parent',h.protocolControls.trials.panel,'Units','pixel','Position',[170 5 50 20], 'String','Save', 'FontWeight','bold','Callback',@saveTrials);
h.protocolControls.trials.load =  uicontrol('Style','pushbutton','parent',h.protocolControls.trials.panel,'Units','pixel','Position',[170 27 50 20], 'String','Load', 'FontWeight','bold','Callback',@loadTrials);

% Done list
p = get(h.panelProtocolChooser, 'Position');
pos = [235 p(4)+10 guiPos(3)-235 guiPos(4)-p(4)-20];
sizes.donePanel.smallGui = pos;
sizes.donePanel.bigGui = [panelWidth(1)+20+2*panelWidth(2) 5 panelWidth(2) round((guiPos(4)+30)/2)];
sizes.doneList.bigGui = [5 30 panelWidth(2)-12 round((guiPos(4)+30)/2)-45];
sizes.doneList.smallGui = [5 30 pos(3)-12 pos(4)-45];
h.protocolControls.doneList.panel = uipanel('Parent',h.guiHandle,'Units','pixel','Position',pos, 'Title','Executed trials','TitlePosition','centertop');
h.protocolControls.doneList.list = uicontrol('Style','listbox','parent',h.protocolControls.doneList.panel ,'Units','pixel','Position',[5 30 pos(3)-12 pos(4)-45]);
h.protocolControls.doneList.clear = uicontrol('Style','pushbutton','parent',h.protocolControls.doneList.panel ,'Units','pixel','Position',[5 5 round((pos(3)-20)/3) 20], 'String','Clear', 'FontWeight', 'bold');
h.protocolControls.doneList.guiSize = uicontrol('Style','pushbutton','parent',h.protocolControls.doneList.panel ,'Units','pixel','Position',[15+2*round((pos(3)-20)/3) 5 round((pos(3)-20)/3) 20], 'String','>>>','Callback',@changeGuiSize, 'FontWeight', 'bold');
h.protocolControls.doneList.abort = uicontrol('Style','pushbutton','parent',h.protocolControls.doneList.panel ,'Units','pixel','Position',[10+round((pos(3)-20)/3) 5 round((pos(3)-20)/3) 20], 'String','Abort','Callback',@abortExecution, 'FontWeight', 'bold','ForegroundColor',[0.8 0 0]);

% Log panel
h = protocolUtilities.logWindow.setup(h,h.guiHandle, [235 5 guiPos(3)-235 p(4)]);
set(h.log.logWindow, 'ForeGroundColor','r');

sizes.logPanel.smallGui = [235 5 guiPos(3)-235 p(4)];
sizes.logPanel.bigGui = [235 5 panelWidth(2) p(4)];
sizes.logList.smallGui = get(h.log.logWindow, 'Position');
sizes.logList.bigGui = [sizes.logList.smallGui(1:2) panelWidth(2)-12 sizes.logList.smallGui(4)];
sizes.logClear.bigGui = [sizes.logPanel.bigGui(3)-24 2 20 20];
sizes.logClear.smallGui = [sizes.logPanel.smallGui(3)-24 2 20 20];
set(h.log.clearButton, 'Position', sizes.logClear.smallGui, 'String','X','FontWeight','bold');
% Output warnings in listbox: protocolUtilities.logWindow.issueLogMessage(logMessageString)

% Sequence definition list
h.protocolControls.sequencesDef.panel = uipanel('Parent',h.guiHandle,'Units','pixel','Position',[235 round((guiPos(4)+30)/2)+15 panelWidth(2) guiPos(4)-(round((guiPos(4)+30)/2))-25], 'Title','Sequence definition','TitlePosition','centertop','Visible','off');
h.protocolControls.sequencesDef.listbox =  uicontrol('Style','listbox','parent',h.protocolControls.sequencesDef.panel,'Units','pixel','Position',[5 30 panelWidth(2)-12  guiPos(4)-(round((guiPos(4)+30)/2))-70],'Max',2);
h.protocolControls.sequencesDef.delete = uicontrol('Style','pushbutton','parent',h.protocolControls.sequencesDef.panel,'Units','pixel','Position',[5 5 55 20], 'String', 'Delete', 'FontWeight', 'bold','Callback',@deleteSeqDef);
h.protocolControls.sequencesDef.newSeq = uicontrol('Style','pushbutton','parent',h.protocolControls.sequencesDef.panel,'Units','pixel','Position',[67 5 55 20], 'String', 'Create', 'FontWeight', 'bold','Callback',@newSequence);
h.protocolControls.sequencesDef.updateSeq = uicontrol('Style','pushbutton','parent',h.protocolControls.sequencesDef.panel,'Units','pixel','Position',[129 5 55 20], 'String', 'Update', 'FontWeight', 'bold','Callback',@updateSequence);

% Sequence list
h.protocolControls.sequences.panel = uipanel('Parent',h.guiHandle,'Units','pixel','Position',[235 p(4)+10 panelWidth(2) round((guiPos(4)+30)/2)-p(4)-5], 'Title','Sequences','TitlePosition','centertop','Visible','off');
h.protocolControls.sequences.listbox =  uicontrol('Style','listbox','parent',h.protocolControls.sequences.panel,'Units','pixel','Position',[5 55 panelWidth(2)-12 round((guiPos(4)+30)/2)-p(4)-75],'Callback',@updateSeqSelection);
h.protocolControls.sequences.run = uicontrol('Style','pushbutton','parent',h.protocolControls.sequences.panel,'Units','pixel','Position',[5 5 50 20], 'String', 'Run', 'FontWeight', 'bold','Callback',@runSelection);
h.protocolControls.sequences.delete = uicontrol('Style','pushbutton','parent',h.protocolControls.sequences.panel,'Units','pixel','Position',[5 27 50 20], 'String', 'Delete', 'FontWeight', 'bold','Callback',@deleteSequence);
h.protocolControls.sequences.add2Protocol = uicontrol('Style','pushbutton','parent',h.protocolControls.sequences.panel,'Units','pixel','Position',[57 27 50 20], 'String', '+Protocol', 'FontWeight', 'bold','Callback',@addSeq2Prot);
h.protocolControls.sequences.add2Todo = uicontrol('Style','pushbutton','parent',h.protocolControls.sequences.panel,'Units','pixel','Position',[57 5 50 20], 'String', '+ToDo', 'FontWeight', 'bold');
h.protocolControls.sequences.save = uicontrol('Style','pushbutton','parent',h.protocolControls.sequences.panel,'Units','pixel','Position',[109 5 50 20], 'String', 'Save', 'FontWeight', 'bold');
h.protocolControls.sequences.load= uicontrol('Style','pushbutton','parent',h.protocolControls.sequences.panel,'Units','pixel','Position',[109 27 50 20], 'String', 'Load', 'FontWeight', 'bold');

% Protocol definition list
h.protocolControls.protocolDef.panel = uipanel('Parent',h.guiHandle,'Units','pixel','Position',[panelWidth(1)+panelWidth(2)+15 round((guiPos(4)+30)/2)+15 panelWidth(2) guiPos(4)-(round((guiPos(4)+30)/2))-25], 'Title','Protocol definitions','TitlePosition','centertop','Visible','off');
h.protocolControls.protocolDef.listbox =  uicontrol('Style','listbox','parent',h.protocolControls.protocolDef.panel,'Units','pixel','Position',[5 30 panelWidth(2)-12  guiPos(4)-(round((guiPos(4)+30)/2))-70],'Max',2);
h.protocolControls.protocolDef.detete= uicontrol('Style','pushbutton','parent',h.protocolControls.protocolDef.panel,'Units','pixel','Position',[5 5 50 20], 'String', 'Delete', 'FontWeight', 'bold','Callback',@deleteProtDef,'max',2);
h.protocolControls.protocolDef.newProt = uicontrol('Style','pushbutton','parent',h.protocolControls.protocolDef.panel,'Units','pixel','Position',[67 5 50 20], 'String', 'Create', 'FontWeight', 'bold','Callback',@newProtocol);
h.protocolControls.protocolDef.updateProt = uicontrol('Style','pushbutton','parent',h.protocolControls.protocolDef.panel,'Units','pixel','Position',[129 5 50 20], 'String', 'Update', 'FontWeight', 'bold','Callback',@updateProtocol);

% Protocol list
h.protocolControls.protocols.panel = uipanel('Parent',h.guiHandle,'Units','pixel','Position',[panelWidth(1)+panelWidth(2)+15 5 panelWidth(2) round((guiPos(4)+30)/2)], 'Title','Protocols','TitlePosition','centertop','Visible','off');
h.protocolControls.protocols.listbox =  uicontrol('Style','listbox','parent',h.protocolControls.protocols.panel,'Units','pixel','Position',[5 55 panelWidth(2)-12 round((guiPos(4)+30)/2)-70],'Callback',@updateProtSelection);
h.protocolControls.protocols.run = uicontrol('Style','pushbutton','parent',h.protocolControls.protocols.panel,'Units','pixel','Position',[5 5 50 20], 'String', 'Run', 'FontWeight', 'bold','Callback',@runProtocol);
h.protocolControls.protocols.delete = uicontrol('Style','pushbutton','parent',h.protocolControls.protocols.panel,'Units','pixel','Position',[5 27 50 20], 'String', 'Delete', 'FontWeight', 'bold','Callback',@deleteProtocol);
h.protocolControls.protocols.add2Todo = uicontrol('Style','pushbutton','parent',h.protocolControls.protocols.panel,'Units','pixel','Position',[57 5 50 20], 'String', '+ToDo', 'FontWeight', 'bold');
h.protocolControls.protocols.save = uicontrol('Style','pushbutton','parent',h.protocolControls.protocols.panel,'Units','pixel','Position',[109 5 50 20], 'String', 'Save', 'FontWeight', 'bold','Callback',@saveProtocols);
h.protocolControls.protocols.load= uicontrol('Style','pushbutton','parent',h.protocolControls.protocols.panel,'Units','pixel','Position',[109 27 50 20], 'String', 'Load', 'FontWeight', 'bold','Callback',@loadProtocols);


% To do list
h.protocolControls.todo.panel = uipanel('Parent',h.guiHandle,'Units','pixel','Position',[panelWidth(1)+20+2*panelWidth(2) round((guiPos(4)+30)/2)+15 panelWidth(2) guiPos(4)-(round((guiPos(4)+30)/2))-25], 'Title','To do list','TitlePosition','centertop','Visible','off');
h.protocolControls.todo.listbox =  uicontrol('Style','listbox','parent',h.protocolControls.todo.panel,'Units','pixel','Position',[5 30 panelWidth(2)-12  guiPos(4)-(round((guiPos(4)+30)/2))-70]);
h.protocolControls.todo.run = uicontrol('Style','pushbutton','parent',h.protocolControls.todo.panel,'Units','pixel','Position',[5 5 50 20], 'String', 'Run', 'FontWeight', 'bold');
h.protocolControls.todo.delete = uicontrol('Style','pushbutton','parent',h.protocolControls.todo.panel,'Units','pixel','Position',[57 5 50 20], 'String', 'Delete', 'FontWeight', 'bold');
h.protocolControls.todo.clear = uicontrol('Style','pushbutton','parent',h.protocolControls.todo.panel,'Units','pixel','Position',[109 5 50 20], 'String', 'Clear', 'FontWeight', 'bold');

% Starting values
smallGui = 1; % Status of GUI
trialList = struct([]);
nTrials = 0;
currTrial = [];
sentTrialIdx = 0;
sequenceDef = struct([]);
nSeqDef = 0;
sequenceList = struct([]);
protocolDef = struct([]);
nProtDef = 0;
protocolList = struct([]);
toDoList = struct([]);
nToDo = 0;
sessionRunningFlag = 0;

%% Check which odor is in which vial in which slave
% Find which slaves are used
mixtures = [olfactometerOdors.sessionOdors.mixture]; % Find which session odors are mixtures
activeSlaves = {olfactometerOdors.sessionOdors.slave}; % Find for every session odor which slaves are used
activeSlaves = cell2mat(activeSlaves(~mixtures)); % Throw away the entries for the mixtures
activeSlaves = unique(activeSlaves); % Find all unique slaves which are used
ct = 0;
for j = 1 : length(activeSlaves)
    usedVials = [olfactometerOdors.slave(j).sessionOdors(:).vial];
    for i = 1 : 9 % go through every position of the olfactometer
        if sum(ismember(usedVials,i))>0.1 % checks whether there is an odor vial in the current (i) position of the olfactometer
            ct = ct+1;
            odorIdx(ct).slave = j;
            odorIdx(ct).vial = i;
        end
    end
end
%% Update h structure in the appdata
% Write the structure h containing all handles for the figure as appdata:
appdataManager('olfStimGui','set',h)
protocolUtilities.logWindow.issueLogMessage('Ready to go!')
%% Odor presentation functions
    function send2Olfactometer(sequence)
        appdataManager('olfStimGui','set',h)
        % This trial triggering function should be used in all stimulation
        % protocols.
        import protocolUtilities.*
        sentTrialIdx = sentTrialIdx+1;
        % Selected odor
        trialOdor = olfactometerOdors.sessionOdors(sequence.odorIdx);
        trialOdor.concentrationAtPresentation = sequence.odorConc;
        
        % Update the smell structure
        buildSmell('update',trialOdor,sentTrialIdx,stimProtocol); % update smell structure
        
        % Fill in correct values of current trial
        smell.trial(sentTrialIdx).olfactometerInstructions(1).value = sequence.value{1,1};  % MFC
        for ii=1:5
            smell.trial(sentTrialIdx).olfactometerInstructions(2*ii).value = sequence.value{1,ii+1};
            smell.trial(sentTrialIdx).olfactometerInstructions(2*ii+1).value = sequence.value{2,ii+1};
            smell.trial(sentTrialIdx).olfactometerInstructions(2*ii+1).value = sequence.value{2,ii+1};
            smell.trial(sentTrialIdx).olfactometerInstructions(2*ii).used = sequence.enable(ii+1);
            smell.trial(sentTrialIdx).olfactometerInstructions(2*ii+1).used = sequence.enable(ii+1);
        end
        smell.trial(sentTrialIdx).olfactometerInstructions(12).used = sequence.enable(7);  % Purge
        smell.trial(sentTrialIdx).olfactometerInstructions(13).value = sequence.value{1,8}; % Clean nose
        smell.trial(sentTrialIdx).olfactometerInstructions(13).used = sequence.enable(8);  % Clean nose
%         smell.trial(sentTrialIdx).olfactometerInstructions(14).used = sequence.enable{9}; % Triggered
%         smell.trial(sentTrialIdx).olfactometerInstructions(3).used = sequence.enable{1,9};  % ISI
        % Delete all but the input trigger. Change later for additional
        % trigger options.
        smell.trial(sentTrialIdx).io = [];
        smell.trial(sentTrialIdx).io(1).label = 'waitForTrigger';
        smell.trial(sentTrialIdx).io(1).type  = 'input';
        smell.trial(sentTrialIdx).io(1).value = 1;
        smell.trial(sentTrialIdx).io(1).time  = 0;
        smell.trial(sentTrialIdx).io(1).used  = get(h.olfactometerSettings.check(14), 'Value');

            
        
        set(h.guiHandle,'Name', ['Running trial ' num2str(sentTrialIdx,'%03d') '-' sequence.name]);
        % Start the new trial
        %   This will build the lsq file for the current trial, send the
        %   instructions to the olfactometer and trigger the trial.
        flag = 1;
        if sentTrialIdx > numel(smell.trial)
            a = 1;
%             global smell % sometimes there appears to be a non-global smell variable here that is not updated by the buildSmell function!?!?!?!
%             answ = questdlg('Too few elements in smell structure. Reset trial index to match size of smell structure?','Too few elements in smell structure.','Yes','No','Yes');
%             if strcmp(answ,'Yes')
%                 sentTrialIdx = numel(smell.trial);
%             end
        end
        %         try
        smell = olfStimStartTrial(sentTrialIdx, smell);
        %         catch me
        %             flag = 0;
        %             warndlg({['Error during trial execution: ' me.message];'Error message sent to base workspace (errorMessage).'});
        %             assignin('base','errorMessage',me);
        %         end
        % Update the progress panel on the gui
        doneStr = get(h.protocolControls.doneList.list,'String');
        if flag
            doneStr{end+1} = [num2str(sentTrialIdx,'%03d') '-' [sequence.namePrefix{:}] sequence.name];
        else
            doneStr{end+1} = [num2str(sentTrialIdx,'%03d') '*-' [sequence.namePrefix{:}] sequence.name];
        end
        set(h.protocolControls.doneList.list,'String',doneStr,'Value',numel(doneStr));
        set(h.guiHandle,'Name', 'olfStim');
    end

    function sequence = buildSequence(trial)
        % A "sequence" is in this module the smallest unit that can be sent
        % to the olfactometer. It can but does not have to consist of
        % several trials. Single executed trials will be first converted
        % into a sequence. Protocols and the to do-list simply consist of a
        % series of sequences, which can be separated by the indicated wait
        % (or ISI) time.
        sequence = trial;
    end
    function abortExecution(varargin)
        sessionRunningFlag = 0;
    end
%% Trial functions
    function runTrial(varargin)
        switch varargin{1}
            case h.runControls.runTrialFromSettings
                seq{1} = readTrialVal;
                seq{1}.namePrefix{1} = '';
            case  h.protocolControls.trials.run
                currTrial = get(h.protocolControls.trials.listbox, 'Value');
                for ii=1:numel(currTrial)
                    seq{ii} = buildSequence(trialList(currTrial(ii)));
                    seq{ii}.namePrefix{1} = '';
                end
        end
        sessionRunningFlag = 1;
        ii = 0;
        while sessionRunningFlag && ii<numel(seq)
            ii = ii+1;
            send2Olfactometer(seq{ii});
        end
        sessionRunningFlag = 0;
    end
    function newTrialDef(varargin)
        nTrials =  nTrials + 1;
        set([h.protocolControls.trials.rename h.protocolControls.trials.delete], 'Enable','on');
        if nTrials == 1
            trialList = readTrialVal;
        else
            trialList(nTrials) = readTrialVal;
        end
        trialStr = get(h.protocolControls.trials.listbox, 'String');
        trialStr{end+1} = trialList(nTrials).name;
        set(h.protocolControls.trials.listbox, 'String', trialStr);
        currTrial = nTrials;
        set(h.protocolControls.trials.listbox, 'Value', currTrial);
    end
    function newTrial = readTrialVal
        newTrial.value{1,1} = str2double(get(h.olfactometerSettings.edit(1),'String')); % MFC
        for ii = 1:5
            newTrial.value{1,ii+1} = eval(get(h.olfactometerSettings.edit(2*ii),'String'));
            newTrial.value{2,ii+1} = eval(get(h.olfactometerSettings.edit(2*ii+1),'String'));
            if numel(newTrial.value{1,ii+1}) ~= numel(newTrial.value{2,ii+1})
                warndlg('Number of valve on- and off-values are not identical.');
            end
            newTrial.enable(ii+1) = get(h.olfactometerSettings.check(2*ii),'Value');
        end
        newTrial.enable(7) = get(h.olfactometerSettings.check(12),'Value'); % Purge
        newTrial.value{1,8} = eval(get(h.olfactometerSettings.edit(13),'String')); % Clean nose
        newTrial.enable(8) = get(h.olfactometerSettings.check(13),'Value'); % Clean nose
        newTrial.enable(9) = get(h.olfactometerSettings.check(14),'Value'); % Triggered
        newTrial.value{1,9} = str2double(get(h.sessionSettings.edit(3),'String')); % ISI
        odorStr = get(h.olfactometerSettings.odorPop, 'String');
        odorIdx = get(h.olfactometerSettings.odorPop, 'Value');
        newTrial.odorName = odorStr{odorIdx};
        newTrial.odorIdx = odorIdx;
        newTrial.odorConc = str2double(get(h.olfactometerSettings.odorEdt, 'String'));
        newTrial.name = [newTrial.odorName ',c=' num2str(newTrial.odorConc)];
        newTrial.namePrefix{1} = '';
        if newTrial.enable(9)
            newTrial.name = [newTrial.name ' (T)'];
        end
    end
    function updateTrial(varargin)
        currTrial = get(h.protocolControls.trials.listbox, 'Value');
        trialList(currTrial) = readTrialVal;
        trialStr = get(h.protocolControls.trials.listbox, 'String');
        trialStr{currTrial} = trialList(currTrial).name;
        set(h.protocolControls.trials.listbox, 'String',trialStr);
    end
    function deleteTrialDef(varargin)
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % To do: Check if trial is being used by one or more
        %       sequences or protocols or in the todo list!!!
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        currTrial = get(h.protocolControls.trials.listbox, 'Value');
        trialStr = get(h.protocolControls.trials.listbox, 'String');
        if currTrial == numel(trialStr)
            set(h.protocolControls.trials.listbox, 'Value', currTrial-1);
        end
        trialList(currTrial) = [];
        trialStr(currTrial) = [];
        set(h.protocolControls.trials.listbox, 'String', trialStr);
        if isempty(trialList)
            set([h.protocolControls.trials.rename h.protocolControls.trials.delete], 'Enable','off');
        end
        nTrials = numel(trialList);
    end
    function renameTrial(varargin)
        currTrial = get(h.protocolControls.trials.listbox, 'Value');
        newName = inputdlg('Enter new name', 'New name:',1,{trialList(currTrial).name});
        newName = newName{1};
        trialList(currTrial).name = newName;
        trialStr = get(h.protocolControls.trials.listbox,'String');
        trialStr{currTrial} = newName;
        set(h.protocolControls.trials.listbox,'String', trialStr);
    end
    function saveTrials(varargin)
        [fn, pn] = uiputfile('*.mat', 'Save trials as');
        save([pn filesep fn], 'trialList');
    end
    function loadTrials(varargin)
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % To do: Check whether all odors (in the correct concentration
        %       are actually present in the odor list!!!
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        [fn, pn] = uigetfile('*.mat', 'Load trials from');
        if isempty(fn)
            return
        end
        newTrials = load([pn filesep fn]);
        newTrials = newTrials.trialList;
        answ = questdlg('Add to or replace existing trials?', 'Add or replace trials', 'Add', 'Replace', 'Cancel','Replace');
        switch answ
            case 'Replace'
                trialList = newTrials;
            case 'Add'
                if ~isempty(trialList)
                    trialList(end+1:end+numel(newTrials)) = newTrials;
                else
                    trialList = newTrials;
                end
        end
        set(h.protocolControls.trials.listbox, 'Value', 1);
        for ii = 1:numel(trialList)
            trialStr{ii} = trialList(ii).name;
        end
        set(h.protocolControls.trials.listbox, 'String', trialStr);
        set([h.protocolControls.trials.rename h.protocolControls.trials.delete], 'Enable','on');
        updateTrialSelection;
    end
    function updateTrialSelection(varargin)
        currTrial = get(h.protocolControls.trials.listbox, 'Value');
        if numel(currTrial) == 0
        elseif numel(currTrial) == 1
            set([h.protocolControls.updateCurrTrial h.protocolControls.trials.rename],'Enable','on');
            set(h.olfactometerSettings.edit(1),'String',num2str(trialList(currTrial).value{1,1})); % MFC
            for ii = 1:5
                if numel( trialList(currTrial).value{1,ii+1})>1
                    set(h.olfactometerSettings.edit(2*ii),'String', ['[' num2str(trialList(currTrial).value{1,ii+1}) ']']);
                    set(h.olfactometerSettings.edit(2*ii+1),'String',['[' num2str(trialList(currTrial).value{2,ii+1}) ']']);
                else
                    set(h.olfactometerSettings.edit(2*ii),'String', num2str(trialList(currTrial).value{1,ii+1}));
                    set(h.olfactometerSettings.edit(2*ii+1),'String',num2str(trialList(currTrial).value{2,ii+1}));
                end
                set(h.olfactometerSettings.check(2*ii),'Value', trialList(currTrial).enable(ii+1)) ;
            end
            set(h.olfactometerSettings.check(12),'Value', trialList(currTrial).enable(7)); % Purge
            set(h.olfactometerSettings.edit(13),'String', num2str(trialList(currTrial).value{1,8})); % Clean nose
            set(h.olfactometerSettings.check(13),'Value', trialList(currTrial).enable(8)); % Clean nose
            set(h.olfactometerSettings.check(14),'Value', trialList(currTrial).enable(9)); % Triggered
            set(h.sessionSettings.edit(3),'String', num2str(trialList(currTrial).value{1,9})); % ISI
            set(h.olfactometerSettings.odorPop, 'Value', trialList(currTrial).odorIdx);
            set(h.olfactometerSettings.odorEdt, 'String', num2str(trialList(currTrial).odorConc));
        else
            set([h.protocolControls.updateCurrTrial h.protocolControls.trials.rename],'Enable','off');
        end
    end
    function addTrial2SeqDef(varargin)
        currTrial = get(h.protocolControls.trials.listbox, 'Value');
        trialStr = get(h.protocolControls.trials.listbox, 'String');
        seqDefStr = get(h.protocolControls.sequenceDef.listbox, 'String');
        for ii=1:numel(currTrial)
            sequenceDef(nSeqDef+ii).name = trialStr{currTrial(ii)};
            seqDefStr{nSeqDef+ii} = sequenceDef(nSeqDef+ii).name;
            sequenceDef(nProtDef).def = trialList(currTrial(ii));
        end
        set(h.protocolControls.sequenceDef.listbox, 'String',seqDefStr );
        nSeqDef = nSeqDef + numel(currTrial);
    end
    function addTrial2ProtDef(varargin)
        currTrial = get(h.protocolControls.trials.listbox, 'Value');
        trialStr = get(h.protocolControls.trials.listbox, 'String');
        protDefStr = get(h.protocolControls.protocolDef.listbox, 'String');
        for ii=1:numel(currTrial)
            protocolDef(nProtDef+ii).name = trialStr{currTrial(ii)};
            protDefStr{nProtDef+ii} = protocolDef(nProtDef+ii).name;
            protocolDef(nProtDef+ii).def = trialList(currTrial(ii));
        end
        set(h.protocolControls.protocolDef.listbox, 'String',protDefStr );
        nProtDef = nProtDef + numel(currTrial);
    end
%% Sequence functions
    function newSequence(varargin)
        sds = '';
        for ii=1:numel(sequenceDef);
            sds = [sds ';' sequenceDef(ii).name];
        end
        sds(1) = '';
        sn = inputdlg('Enter sequence name:','Enter sequence name!',1,{sds},'on');
        if isempty(sn)
            return
        end
        sequenceList(end+1).name = sn{1};
        sequenceList(end).seqDef = sequenceDef;
        for ii = 1:numel(sequenceList(end).seqDef)
            sequenceList(end).seqDef(ii).def.namePrefix{2} = ['S' num2str(ii,'%01d') '/' num2str(numel(sequenceList(end).seqDef),'%01d') '-'];
        end
        seqStr = get(h.protocolControls.sequences.listbox,'String');
        seqStr{end+1} = sn{1};
        set(h.protocolControls.sequences.listbox,'String',seqStr);
    end
    function updateSequence(varargin)
        currSeq = get(h.protocolControls.sequences.listbox, 'Value');
        seqStr = get(h.protocolControls.sequences.listbox, 'String');
        sn = inputdlg('Enter sequence name:','Enter sequence name!',1,seqStr(currSeq),'on');
        if isempty(sn)
            return
        end
        sequenceList(currSeq).name = sn{1};
        sequenceList(currSeq).seqDef = sequenceDef;
        for ii = 1:numel(sequenceList(end).seqDef)
            sequenceList(end).seqDef(ii).def.namePrefix{2} = ['S' num2str(ii,'%01d') '/' num2str(numel(sequenceList(end).seqDef),'%01d') '-'];
        end
        seqStr{currSeq} = sn{1};
        set(h.protocolControls.sequences.listbox,'String',seqStr);
    end
    function updateSeqSelection(varargin)
        currSeq = get(h.protocolControls.sequences.listbox,'Value');
        sequenceDef = sequenceList(currSeq).seqDef;
        for ii=1:numel(sequenceDef)
            seqDefStr{ii} = [sequenceDef(ii).def.namePrefix{2} sequenceDef(ii).name];
        end
        set(h.protocolControls.sequencesDef.listbox, 'String', seqDefStr);
    end
    function deleteSeqDef(varargin)
        currSeq = get(h.protocolControls.sequencesDef.listbox,'Value');
        seqStr = get(h.protocolControls.sequencesDef.listbox, 'String');
        keepIdx = setdiff(1:numel(seqStr),currSeq);
        seqStr = seqStr(keepIdx);
        sequenceDef = sequenceDef(keepIdx);
        set(h.protocolControls.sequencesDef.listbox, 'Value', max(1,min(currSeq)-1),'String', seqStr);
        nSeqDef = numel(keepIdx);
    end
    function deleteSequence(varargin)
        if numel(sequenceList)
            currSeq = get(h.protocolControls.sequences.listbox, 'Value');
            seqStr = get(h.protocolControls.sequences.listbox, 'String');
            sequenceList(currSeq) = [];
            seqStr(currSeq) = [];
            set(h.protocolControls.sequences.listbox, 'Value', max(1,currSeq-1), 'String',seqStr);
        end
    end
    function runSelection(varargin)
        currSeq = get(h.protocolControls.sequences.listbox, 'Value');
        sessionRunningFlag = 1;
        ii = 0;
        while sessionRunningFlag && ii<numel(sequenceList(currSeq).seqDef)
            ii = ii+1;
            seq = buildSequence(sequenceList(currSeq).seqDef(ii).def);
            send2Olfactometer(seq);
        end
        sessionRunningFlag = 0;
    end
    function addSeq2Prot(varargin)
        currSeq = get(h.protocolControls.sequencesDef.listbox,'Value');
        nProtDef = nProtDef + numel(sequenceList(currSeq));
        seqStr = get(h.protocolControls.sequence.listbox, 'String');
        for ii=1:numel(sequenceList(currSeq))
            protocolDef(nProtDef).name = trialStr{currTrial};
            protDefStr = get(h.protocolControls.protocolDef.listbox, 'String');
            protDefStr{end+1} = protocolDef(nProtDef).name;
            set(h.protocolControls.protocolDef.listbox, 'String',protDefStr );
            protocolDef(nProtDef).def = trialList(currTrial);
        end
    end
%% Protocol functions
    function newProtocol(varargin)
        protDefStr = get(h.protocolControls.protocolDef.listbox, 'String');
        pds = '';
        for ii=1:numel(protDefStr);
            pds = [pds ';' protDefStr{ii}];
        end
        pds(1) = '';
        pn = inputdlg('Enter protocol name:','Enter protocol name!',1,{pds},'on');
        if isempty(pn)
            return
        end
        protocolList(end+1).name = pn{1};
        protocolList(end).protDef = protocolDef;
        for ii = 1:numel(protocolList(end).protDef)
            protocolList(end).protDef(ii).def.namePrefix{3} = ['P' num2str(ii,'%02d') '/' num2str(numel(protocolList(end).protDef),'%02d') '-'];
        end
        protStr = get(h.protocolControls.protocols.listbox,'String');
        protStr{end+1} = pn{1};
        set(h.protocolControls.protocols.listbox,'String',protStr);
    end
    function updateProtSelection(varargin)
        currProt = get(h.protocolControls.protocols.listbox,'Value');
        protocolDef = protocolList(currProt).protDef;
        for ii=1:numel(protocolDef)
            protDefStr{ii} = protocolDef(ii).name;
        end
        set(h.protocolControls.protocolDef.listbox, 'String', protDefStr);
    end
    function deleteProtDef(varargin)
        currProt = get(h.protocolControls.protocolDef.listbox,'Value');
        protStr = get(h.protocolControls.protocolDef.listbox, 'String');
        keepIdx = setdiff(1:numel(protStr),currProt);
        protStr = protStr(keepIdx);
        protocolDef = protocolDef(keepIdx);
        set(h.protocolControls.protocolDef.listbox, 'Value', max(1,min(currProt)-1),'String', protStr);
        nProtDef = numel(keepIdx);
    end
    function deleteProtocol(varargin)
        if numel(protocolList)
            currProt = get(h.protocolControls.protocols.listbox, 'Value');
            protStr = get(h.protocolControls.protocols.listbox, 'String');
            protocolList(currProt) = [];
            protStr(currProt) = [];
            set(h.protocolControls.protocols.listbox, 'Value', max(1,currProt-1), 'String',protStr);
        end
    end
    function runProtocol(varargin)
        currProt = get(h.protocolControls.protocols.listbox, 'Value');
        sessionRunningFlag = 1;
        ii = 0;
        while sessionRunningFlag && ii<numel(protocolList(currProt).protDef)
            ii = ii+1;
            seq = buildSequence(protocolList(currProt).protDef(ii).def);
            send2Olfactometer(seq);
        end
        sessionRunningFlag = 0;
    end
    function updateProtocol(varargin)
        currProt = get(h.protocolControls.protocols.listbox, 'Value');
        protStr = get(h.protocolControls.protocols.listbox, 'String');
        pn = inputdlg('Enter protocol name:','Enter protocol name!',1,protStr(currProt),'on');
        if isempty(pn)
            return
        end
        protocolList(currProt).name = pn{1};
        protocolList(currProt).protDef = protocolDef;
        for ii = 1:numel(protocolList(end).protDef)
            protocolList(end).protDef(ii).def.namePrefix{3} = ['P' num2str(ii,'%01d') '/' num2str(numel(protocolList(end).protDef),'%01d') '-'];
        end
        protStr{currProt} = pn{1};
        set(h.protocolControls.protocols.listbox,'String',protStr);
    end
    function loadProtocols(varargin)
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % To do: Check whether all odors (in the correct concentration
        %       are actually present in the odor list!!!
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        [fn, pn] = uigetfile('*.mat', 'Load protocols from');
        newProt = load([pn filesep fn]);
        newProt = newProt.protocolList;
        if isempty(protocolList)
            protocolList = newProt;
        else
            answ = questdlg('Add to or replace existing protocols?', 'Add or replace protocols', 'Add', 'Replace', 'Cancel','Replace');
            switch answ
                case 'Replace'
                    protocolList = newProt;
                case 'Add'
                    protocolList(end+1:end+numel(newProt)) = newProt;
            end
        end
        set(h.protocolControls.protocols.listbox, 'Value', 1);
        for ii = 1:numel(protocolList)
            protStr{ii} = protocolList(ii).name;
        end
        set(h.protocolControls.protocols.listbox, 'String', protStr);
        updateProtSelection;
    end
    function saveProtocols(varargin)
        [fn, pn] = uiputfile('*.mat', 'Save protocols as');
        save([pn filesep fn], 'protocolList');
    end
%% To do list functions

%% GUI functions
    function changeGuiSize(varargin)
        gp = get(h.guiHandle,'Position');
        p = get(h.panelProtocolChooser, 'Position');
        pos = [235 5 guiPos(3)-235 guiPos(4)-p(4)-20];
        if smallGui
            smallGui = 0;
            set(h.protocolControls.doneList.guiSize, 'String', '<<<');
            set(h.guiHandle, 'Position', [gp(1:2) guiPosLarge(3:4)]);
            set(h.protocolControls.doneList.panel, 'Position',sizes.donePanel.bigGui);
            set(h.protocolControls.doneList.list, 'Position', sizes.doneList.bigGui );
            set(h.log.panel, 'Position', sizes.logPanel.bigGui);
            set(h.log.logWindow, 'Position', sizes.logList.bigGui);
            set(h.log.clearButton, 'Position', sizes.logClear.bigGui);
            set([h.protocolControls.sequences.panel h.protocolControls.protocols.panel h.protocolControls.todo.panel h.protocolControls.sequencesDef.panel h.protocolControls.protocolDef.panel], 'Visible','on');
            set([h.protocolControls.trials.add2Seq h.protocolControls.trials.add2Prot h.protocolControls.trials.add2Todo], 'Enable','on');
        else
            smallGui = 1;
            set(h.protocolControls.doneList.guiSize, 'String', '>>>');
            set(h.guiHandle, 'Position', [gp(1:2) guiPos(3:4)]);
            set(h.protocolControls.doneList.panel, 'Position',sizes.donePanel.smallGui);
            set(h.protocolControls.doneList.list, 'Position', sizes.doneList.smallGui );
            set(h.log.panel, 'Position', sizes.logPanel.smallGui);
            set(h.log.logWindow, 'Position', sizes.logList.smallGui);
            set(h.log.clearButton, 'Position', sizes.logClear.smallGui);
            set([h.protocolControls.sequences.panel h.protocolControls.protocols.panel h.protocolControls.todo.panel h.protocolControls.sequencesDef.panel h.protocolControls.protocolDef.panel], 'Visible','off');
            set([h.protocolControls.trials.add2Seq h.protocolControls.trials.add2Prot h.protocolControls.trials.add2Todo], 'Enable','off');
        end
    end
%% Consistency checks
    function checkConcentration(varargin)
        import protocolUtilities.*
        %Does not work!!!!! Implement!!!
        oi = get(h.olfactometerSettings.odorPop, 'Value');
        h.protocolSpecificHandles.concentration(odorIdx(oi).slave,odorIdx(oi).vial) = h.olfactometerSettings.odorEdt;
        appdataManager('olfStimGui','set',h);
        concentrationEditCallback(0,0,odorIdx(oi).slave,odorIdx(oi).vial);
    end
end