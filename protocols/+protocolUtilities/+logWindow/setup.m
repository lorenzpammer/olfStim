function h = setup(h,parentHandle,panelPosition)
% h = setup(h,parentHandle,panelPosition)
% h is the handle of all olfStim gui components
% parentHandle - defines the handle of the gui component, which will be
%       used as a parent for the logWindow. Default is h.guiHandle
% panelPosition - defines the position of the log window within the parent
% component. Default will be over the whole width on top of the gui.
% 
% Returned handle includes 
%   h.log.panel - the handle of the panel of the log
%   h.log.logWindow - the handle to the actual window containing the logs.
% 
% lorenzpammer 2013/03

%% Check the function parameters

if nargin < 2
    % If no further information is provided, we'll assume a standard
    % olfStim gui:
    parentHandle = h.guiHandle; 
end 

if nargin < 3
    % In case the 
    
    % Choose a position on top of gui:
    heightOfLog = 110;
    guiPos = get(h.guiHandle,'Position');
    % Expand the gui:
    set(h.guiHandle,'Position',guiPos+[0 0 0 heightOfLog])
    guiPos = get(h.guiHandle,'Position');
    panelPosition = [5 guiPos(4)-heightOfLog+5 guiPos(3)-10 heightOfLog-10];
end

%% Set up the actual gui components

% Set up the panel of the log:
h.log.panel = uipanel('Parent',parentHandle,'Title','Log',...
    'Tag','logPanel','FontSize',8,'TitlePosition','centertop',...
    'Units','pixels','Position',panelPosition); % 'Position',[x y width height]

% Calculate the position for the log window:
logPosition = [5 5 panelPosition(3)-10 panelPosition(4)-20];

% Set up the listbox as a child of the panel. This is where the warnings
% will be displayed.
h.log.logWindow = uicontrol('parent',h.log.panel,'Style','listbox','String','',...
    'Tag','logWindow','Position',logPosition);

% Calculate the position of the clearing button:
buttonPosition = [logPosition(3)-41 logPosition(4)-20 30 25];
h.log.clearButton = uicontrol('parent',h.log.panel,'Style','pushbutton','String','Clear',...
    'Position',buttonPosition,'Callback',@clearLogWindow);

end

function clearLogWindow(~,~)
%% Get a couple of needed variables

h = appdataManager('olfStimGui','get','h');

%% Clear the window
set(h.log.logWindow,'String','','Value',1);

%appdataManager('olfStimGui','get',h);
end