function setUpGui(~,~,~)
% ioControl.setUpGui(h)
% This function sets up an additional gui next to the main olfStim gui. In
% this gui input and output triggers can be set.
%
% lorenzpammer


%% 
h = appdataManager('olfStimGui','get','h');
io = appdataManager('olfStimGui','get','io');
%%

if nargin < 3
    error('Not enough input arguments.') 
end

%% Open Gui
position = get(h.guiHandle,'Position');
position = [position(1) + position(3) + 10,...
    position(2) 200 position(4)];
h.ioControl.guiHandle = figure('Position',position,'MenuBar','none',...
    'NumberTitle','off','Name','I/OControl', 'tag','iocontrol');

%% Create panel

panelPosition(1) = 5;
panelPosition(2) = 5;
panelPosition(3:4) = [position(3)-10,position(4)-10];

h.ioControl.panel = uipanel('Parent',h.ioControl.guiHandle,'Title','I/O Control',...
    'FontSize',8,'TitlePosition','centertop',...
    'Units','pixels','Position',panelPosition);

%% Create Pop-Up Menu

popupWidth = 150;popupHeight = 25;
popupPosition(1) = (panelPosition(3)/2) - popupWidth/2;
popupPosition(2) = (panelPosition(4)*0.85) - popupHeight/2;
popupPosition(3:4) = [popupWidth,popupHeight];
h.ioControl.popup = uicontrol('Parent',h.ioControl.panel,'Style','popupmenu',...
    'String',{io.label},...
    'Position',popupPosition,'Callback',@popupMenuCallback); % 'Position',[x y width height]

popupPosition(2) = popupPosition(2) + popupPosition(4);
popupPosition(4) = 15;
h.ioControl.popupTitle = uicontrol('Parent',h.ioControl.panel,'Style','text','String','Select I/O action',...
    'Position',popupPosition);

clear popupHeight popupWidth

%% Create edit fields

editWidth = 120; editHeight = 25;
textWidth = 50; textHeight = 25;
panelPosition = get(h.ioControl.panel,'Position');

% value editing:
position = [panelPosition(3)-5-editWidth popupPosition(2) - 50 editWidth editHeight];
h.ioControl.edit(1) = uicontrol('Parent',h.ioControl.panel,...
    'Style','edit','String','','Position', position,...
    'Tag','value','Callback',@tempFun);

    function tempFun(~,~)
        warndlg('At the moment the value edit option doesn''t have any effect.','Warning')
    end

textPosition = [panelPosition(1)+5 position(2) textWidth textHeight];
h.ioControl.text(1) = uicontrol('Parent',h.ioControl.panel,...
                'Style','text','String','I/O Value',...
                'Position', textPosition,'Tag','value',...
                'Fontsize',7.5);
            
% time editing:
position = [position(1) position(2)-35 editWidth editHeight];
h.ioControl.edit(2) = uicontrol('Parent',h.ioControl.panel,...
                    'Style','edit','String','','Position', position,...
                    'Tag','time');

textPosition = [panelPosition(1)+5 position(2) textWidth textHeight];
h.ioControl.text(2) = uicontrol('Parent',h.ioControl.panel,...
                'Style','text','String','Time of action',...
                'Position', textPosition,'Tag','time',...
                'Fontsize',7.5);

% Used
position = [position(1) position(2)-35 editWidth editHeight];
h.ioControl.edit(3) = uicontrol('Parent',h.ioControl.panel,...
                    'Style','checkbox','Position', position,...
                    'Tag','used');

textPosition = [panelPosition(1)+5 position(2) textWidth textHeight];
h.ioControl.text(3) = uicontrol('Parent',h.ioControl.panel,...
                'Style','text','String','Used',...
                'Position', textPosition,'Tag','used',...
                'Fontsize',7.5);

%% Create Save button

buttonWidth = 100;buttonHeight = 25; 

position = [panelPosition(1)+panelPosition(3)/2-buttonWidth/2 position(2)-40 buttonWidth buttonHeight];
h.ioControl.saveButton = uicontrol('Parent',h.ioControl.panel,...
                    'Style','pushbutton','String','Save','Position', position,...
                    'Tag','ioSave','Callback',{@ioSaveButtonCallback,h});

%% Write updated handle into gui appdata

appdataManager('olfStimGui','set',h)

%% Populate fields with first I/O action

popupMenuCallback([],[])

end


function popupMenuCallback(source,eventdata)

h = appdataManager('olfStimGui','get','h');
% Extract the io variable from appdata:
io = appdataManager('olfStimGui','get','io');

% Find which io action is currently selected in the popup menu:
currentIo = get(h.ioControl.popup,'String');
index = get(h.ioControl.popup,'Value');
currentIo = currentIo{index};
index = strmatch(currentIo,{io.label});

if size(index)>1
    error('There are multiple io actions with the same name.')
end

% Update the values of io with values extracted from the Gui:
set(h.ioControl.edit(1),'String',num2str(io(index).value));
set(h.ioControl.edit(2),'String',num2str(io(index).time));
set(h.ioControl.edit(3),'Value',io(index).used);

end


function ioSaveButtonCallback(~,~,h)
% Extract io variable from appdata. Extract values from gui, write the
% values into io and update the io in appdata.

% Extract the io variable from appdata:
io = appdataManager('olfStimGui','get','io');

% Find which io action is currently selected in the popup menu:
currentIo = get(h.ioControl.popup,'String');
index = get(h.ioControl.popup,'Value');
currentIo = currentIo{index};
index = strmatch(currentIo,{io.label});

if size(index)>1
    error('There are multiple io actions with the same name.')
end

% Update the values of io with values extracted from the Gui:
io(index).value = str2num(get(h.ioControl.edit(1),'String'));
io(index).time = str2num(get(h.ioControl.edit(2),'String'));
io(index).used = logical(get(h.ioControl.edit(3),'Value'));

% Update io variable in appdata:
appdataManager('olfStimGui','set',io);

end
