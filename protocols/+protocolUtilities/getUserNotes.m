function notes = getUserNotes(h)
% notes = getUserNotes(h) returns a string containing the text the user
% wrote into the notes field of the gui.

%% 
if nargin < 1
    error('Not enough input arguments.')
end

%% Get notes
try
    notes = get(h.sessionNotes.notesFigureField,'String'); % Extract text in the notes field.
catch
    notes = [];
end
end