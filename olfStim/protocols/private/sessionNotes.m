function notes = sessionNotes(instruction,panelPosition)
% sessionNotes(position) position is an optional input argument that
% defines the position of the panel for the notes. Expects a 4 element
% vector (x-position,y-position,width,height)
% sessionNotes creates a panel and handles, which allow taking notes during
% an experiment. The notes will be saved to the smell structure for every
% trial.

global h


if nargin < 1
    error('You have to define the input "instruction", to set up (setUp) the sessionNotes feature.')
end
    
if strncmp(instruction,'setUp',5)
    if nargin < 2
        % Define position for notes in respect to other panels in the gui
        stimProtocolPosition = get(h.panelProtocol,'Position');
        closeGuiButtonPosition = get(h.closeGuiButton,'Position');
        panelPosition(1) = stimProtocolPosition(1);
        panelPosition(2) = closeGuiButtonPosition(2) + closeGuiButtonPosition(4) + 5;
        panelPosition(3) = stimProtocolPosition(3);
        panelPosition(4) = stimProtocolPosition(2) - panelPosition(2) - 10;
    end
    clear stimProtocolPosition;clear closeGuiButtonPosition
    
    %%
    
    % Note panel
    h.sessionNotes.panel = uipanel('Parent',h.guiHandle,'Title','SessionNotes',...
        'FontSize',12,'TitlePosition','centertop',...
        'Units','pixels','Position',panelPosition); % 'Position',[x y width height]
    
    % Push Button
    
    % Define position:
    buttonPosition(3) = 70; % pushButtonWidth
    buttonPosition(4) = 25; % pushButtonHeight
    buttonPosition(1) = panelPosition(1) + (panelPosition(3)/2) - (buttonPosition(3)/2);
    buttonPosition(2) = panelPosition(2) + 3;
    % Set up the push button:
    h.sessionNotes.pushButton = uicontrol('Parent',h.guiHandle,'Style','togglebutton',...
        'String','Notes','Units','pixels','Position',buttonPosition,'Callback',@pushButton_Callback);
    
    % Text Field (not editable)
    % Define position
    notesFieldPosition(3) = panelPosition(3) - 6;
    notesFieldPosition(4) = panelPosition(4) - buttonPosition(2) - 3 - buttonPosition(4)+10;
    notesFieldPosition(1) = panelPosition(1) + 3;
    notesFieldPosition(2) = buttonPosition(2) + buttonPosition(4)+10;
    % Set up the non editable text field
    h.sessionNotes.textField = uicontrol('Style','text',...
        'String','Use "Notes" button for opening and closing.','Units','pixels','Position',notesFieldPosition);
    
    % Create new figure for note taking.
    h.sessionNotes.notesFigure = figure('Visible','off','Name','NotePad','Tag','NotePad','Position',[158,560,200,300]);
    position = get(h.sessionNotes.notesFigure,'Position');
    notesFieldPosition(1) = 3;
    notesFieldPosition(2) = 3;
    notesFieldPosition(3) = position(3) - 6;
    notesFieldPosition(4) = position(4) - 6;
    h.sessionNotes.notesFigureField = uicontrol(h.sessionNotes.notesFigure,'Style','edit',...
        'String','','Units','pixels','Position',notesFieldPosition);
%     set(h.sessionNotes.notesFigure,'CloseRequestFcn',@closeFcn)
    
    notes=[];
end

if strncmp(instruction,'get',3)
    notes = get(h.sessionNotes.notesFigureField,'string'); % extract notes which were typed into notes figure.
end

end


function pushButton_Callback(source,eventdata)
% When the "Notes" button is pushed 

global h

if strmatch(get(h.sessionNotes.notesFigure,'Visible'),'on')
    set(h.sessionNotes.notesFigure,'Visible','off');
elseif strmatch(get(h.sessionNotes.notesFigure,'Visible'),'off')
    set(h.sessionNotes.notesFigure,'Visible','on');
end

end
% 
% function closeFcn(~,~)
%     pushButton_Callback
% end
