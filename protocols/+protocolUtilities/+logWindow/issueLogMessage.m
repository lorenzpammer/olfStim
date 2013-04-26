function success = issueLogMessage(logMessage,printToCommandLine)
% success = issueLogMessage(logMessage,printToCommandLine)
% Will print the logMessage to the log window if existent and to the
% command line. Returns true if log window is present, and false if not.
% Will issue log messages to the listbox defined in the h.log.logWindow
% handle.
%
% lorenzpammer 2013/03

%% Check inputs

if nargin < 2
    printToCommandLine = true;
end

%% Get a couple of needed variables

global olfStimScriptMode

if isempty(olfStimScriptMode)
    h = appdataManager('olfStimGui','get','h');
else % if we're in scripting mode
    h=[];
end


%% Write the new log message to the bottom of the logWindow

% Check whether the log field exists in the gui handle structure:
if isfield(h,'log')
    % Check whether the logWindow field exists in the h.log handle structure:
    if isfield(h.log,'logWindow')
        if ~isempty(h.log.logWindow)
            % Extract the current log from the window:
            log = get(h.log.logWindow,'String');
            % Add timestamp to the log message
            logMessage = [datestr(clock,'HH:MM:SS') ': ' logMessage];
            % Append the structure with the new message
            log{end+1} = logMessage;
            % Update the log:
            set(h.log.logWindow,'String',log);
            % Show the last log entry:
            set(h.log.logWindow,'ListboxTop',length(log),'Value',length(log));
            else success = false; 
        end
    else success = false;
    end 
else success = false;
end

% And print everything to the command line:
if printToCommandLine
    disp(logMessage);
end

end