function notes = extract(h)
% notes = getUserNotes(h) returns a string containing the text the user
% wrote into the notes field of the gui and will clear the notes field
% after it extracted the notes.
%

%% Check inputs

if nargin < 1
    error('Not enough input arguments.')
end

%% Get notes
    
if isfield(h,'sessionNotes')
% We have to do jump through some hoops, because if the user doesn't change
% focus from the notes figure to something else, the notes will not be
% extracted.
    % First make the main gui the focussed figure:
    figure(h.guiHandle)
    % Now change the focus to another uicontrol. This will result in the
    % notes field loosing its focus.
    uicontrol(h.sessionNotes.pushButton)
    notes = get(h.sessionNotes.notesFigureField,'String'); % Extract text in the notes field.
    set(h.sessionNotes.notesFigureField,'String',''); % Delete text of previous trial
else
    notes = [];
end

%% Send the notes to the log window in the main gui

% if the log window is present and if there have been notes taken:
if ~isempty(notes)
    % Append notes by 'User notes:'
    note2Log = ['User notes: ' notes];
    % send notes to the log window and suppress output to commandline
    protocolUtilities.logWindow.issueLogMessage(note2Log,false);
end

end