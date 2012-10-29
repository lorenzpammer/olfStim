function odorSelectionGui


%%

position = [300 200 700 300];
guiHandle = figure('Visible','on','Position',position,'Name','odorSelectionGui', 'Tag', 'odorSelectionGui'); %'CloseRequestFcn',@myCloseFcn


%% Set up the gui components
  panelPosition = [5 220 660 50]
    % Note panel
    guiHandle.fileSelection.panel = uipanel('Parent',guiHandle,'Title','Load olfactometer odors file',...
        'FontSize',8,'TitlePosition','righttop',...
        'Units','pixels','Position',panelPosition); % 'Position',[x y width height]
    
    % Push Button
    % Define position:
    buttonPosition(3) = 70; % pushButtonWidth
    buttonPosition(4) = 25; % pushButtonHeight
    buttonPosition(1) = panelPosition(1) + (panelPosition(3)/2) - (buttonPosition(3)/2);
    buttonPosition(2) = panelPosition(2) + 3;
    % Set up the push button:
    guiHandle.sessionNotes.pushButton = uicontrol('Parent',guiHandle.guiHandle,'Style','togglebutton',...
        'String','Notes','Units','pixels','Position',buttonPosition,'Callback',@pushButton_Callback);
    
    % Text Field (not editable)
    % Define position
    notesFieldPosition(3) = panelPosition(3) - 6;
    notesFieldPosition(4) = panelPosition(4) - buttonPosition(2) - 3 - buttonPosition(4)+20;
    notesFieldPosition(1) = panelPosition(1) + 3;
    notesFieldPosition(2) = buttonPosition(2) + buttonPosition(4)+3;
    % Set up the non editable text field
    guiHandle.sessionNotes.textField = uicontrol('Style','text',...
        'String','Use "Notes" button for opening and closing.',...
        'Units','pixels','Position',notesFieldPosition,'Fontsize',7);
    
    % Create new figure for note taking.
    guiHandle.sessionNotes.notesFigure = figure('Visible','off','Name','NotePad','Tag','NotePad','Position',[158,560,200,300]);
    position = get(guiHandle.sessionNotes.notesFigure,'Position');
    notesFieldPosition(1) = 3;
    notesFieldPosition(2) = 3;
    notesFieldPosition(3) = position(3) - 6;
    notesFieldPosition(4) = position(4) - 6;
    guiHandle.sessionNotes.notesFigureField = uicontrol(guiHandle.sessionNotes.notesFigure,'Style','edit',...
        'String','','Units','pixels','Position',notesFieldPosition);
    %     set(guiHandle.sessionNotes.notesFigure,'CloseRequestFcn',@closeFcn)
    


end